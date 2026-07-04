-- int__onboarding
-- Onboarding step completion per account, sourced from Intercom checklist events.
-- One row per account × onboarding step (7 steps per account = full cross join).

with s_intercom_events as (
    select * from {{ ref('stg_intercom__events') }}
),

s_salesforce_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_salesforce_contracts as (
    select * from {{ ref('stg_salesforce__contracts') }}
),

s_onboarding_steps as (
    select * from {{ ref('onboarding_steps') }}
),

-- All accounts with a contract start date
accounts_with_contract as (
    select
        to_hex(sha256(cast(a.account_id as bytes))) as account_pk,
        a.account_id,
        a.account_name,
        min(c.start_date)                           as contract_start_date
    from s_salesforce_accounts as a
    inner join s_salesforce_contracts as c
        on a.account_id = c.account_id
    group by 1, 2, 3
),

-- Completion events from Intercom
intercom_completions as (
    select
        to_hex(sha256(cast(e.company_id as bytes))) as account_pk,
        e.event_name                                as step_id,
        min(e.event_timestamp_utc)                  as completed_at  -- first time step was completed
    from s_intercom_events as e
    where e.event_name in (
        select step_id from s_onboarding_steps
    )
    group by 1, 2
),

-- Cross join all accounts × all steps, then left join completions
account_step_matrix as (
    select
        to_hex(sha256(cast(acc.account_pk as bytes) || cast(os.step_id as bytes))) as onboarding_pk,
        acc.account_pk,
        acc.account_name,
        acc.contract_start_date,
        os.step_id,
        os.step_name,
        os.step_order,
        os.is_core_step,
        os.target_days_max,
        ic.completed_at
    from accounts_with_contract as acc
    cross join s_onboarding_steps as os
    left join intercom_completions as ic
        on acc.account_pk = ic.account_pk
        and os.step_id = ic.step_id
),

-- Calculate days_since_signup and stalled flag
with_signals as (
    select
        onboarding_pk,
        account_pk,
        account_name,
        step_id,
        step_name,
        step_order,
        is_core_step,
        completed_at is not null                                                as is_complete,
        completed_at,
        case
            when completed_at is not null
            then date_diff(date(completed_at), contract_start_date, day)
            else null
        end                                                                     as days_since_signup,
        case
            when completed_at is null
            and date_diff(current_date(), contract_start_date, day) > (
                coalesce(
                    date_diff(current_date(), contract_start_date, day),
                    0
                )
            )
            -- Stalled: step not complete AND account has been live > stalled threshold
            and date_diff(current_date(), contract_start_date, day) > {{ var('product_stalled_days_threshold') }}
            then true
            else false
        end                                                                     as is_stalled
    from account_step_matrix
),

final as (
    select
        onboarding_pk,
        account_pk,
        account_name,
        step_id,
        step_name,
        step_order,
        is_core_step,
        is_complete,
        completed_at,
        days_since_signup,
        is_stalled
    from with_signals
)

select * from final
