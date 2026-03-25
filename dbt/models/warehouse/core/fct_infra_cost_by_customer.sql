{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_operations']
    )
}}

/*
fct_infra_cost_by_customer
---------------------------
GCP infrastructure cost attributed to customer accounts.

Attribution method: proportional — each account's share of total
BigQuery bytes processed in the month is used to apportion costs.
This is an approximation: direct cost label attribution would be
more accurate but requires GCP label setup (future improvement).

Grain: account_pk × billing_month × service_description
Financial — restricted to finance_viewers + leadership in Looker.
*/

with s_billing as (
    select * from {{ ref('stg_gcp__billing_export') }}
    where billing_month >= date_sub(
        date_trunc(current_date(), month),
        interval {{ var('ops_cost_lookback_months', 12) }} month
    )
),

s_accounts as (
    select
        account_pk,
        account_name,
        csm_owner,
        segment,
        arr_usd
    from {{ ref('stg_salesforce__accounts') }}
    where is_active = true
),

-- Total cost per service per month (before attribution)
total_cost_per_service as (
    select
        billing_month,
        service_description,
        sum(cost_usd)                       as total_cost_usd
    from s_billing
    group by 1, 2
),

-- Attribution: equal distribution across active accounts as simple approximation
-- In production, this would use BigQuery bytes-processed labels per account
account_count as (
    select count(*) as active_accounts
    from s_accounts
),

-- Cross join: each account gets a proportional share
attributed as (
    select
        a.account_pk,
        a.account_name,
        a.csm_owner,
        a.segment,
        a.arr_usd,
        tc.billing_month,
        tc.service_description,
        tc.total_cost_usd,
        1.0 / ac.active_accounts                as attribution_pct,
        tc.total_cost_usd / ac.active_accounts   as cost_usd,
        'proportional_equal'                     as attribution_method
    from s_accounts as a
    cross join total_cost_per_service as tc
    cross join account_count as ac
),

with_pk as (
    select
        to_hex(sha256(cast(account_pk as bytes)
            || cast(billing_month as string)
            || cast(service_description as bytes)))     as cost_pk,
        *
    from attributed
),

final as (
    select * from with_pk
)

select * from final
