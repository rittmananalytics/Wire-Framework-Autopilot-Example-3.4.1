{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_customer']
    )
}}

/*
int__csm_book
-------------
Per-CSM book of business: every active account with health summary,
churn risk, renewal context, and open action indicators.

The csm_owner column is the RLS filter field in Looker (user attribute:
csm_owner). Each CSM sees only their rows.

Grain: account_pk (one row per account — current point-in-time snapshot)
*/

with s_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_health as (
    select
        account_pk,
        health_score,
        health_band,
        churn_probability,
        churn_risk_band,
        is_at_risk,
        score_trend_7d,
        score_change_7d,
        score_date
    from {{ source('mart_customer', 'dim_account_health') }}
    where score_date = (
        select max(score_date)
        from {{ source('mart_customer', 'dim_account_health') }}
    )
),

s_renewals as (
    select
        account_pk,
        min(close_date)                         as next_renewal_date,
        date_diff(min(close_date), current_date(), day) as days_to_renewal
    from {{ ref('stg_salesforce__opportunities') }}
    where type = 'Renewal'
      and close_date >= current_date()
    group by 1
),

s_zendesk_open as (
    select
        account_pk,
        count(distinct ticket_pk)               as open_support_tickets
    from {{ ref('stg_zendesk__tickets') }}
    where status not in ('solved', 'closed')
    group by 1
),

s_nps as (
    select
        account_pk,
        nps_score,
        survey_date
    from {{ ref('stg_intercom__nps_surveys') }}
    where survey_date = (
        select max(n2.survey_date)
        from {{ ref('stg_intercom__nps_surveys') }} as n2
        where n2.account_pk = stg_intercom__nps_surveys.account_pk
    )
),

-- Overdue onboarding steps from Release 04
s_onboarding as (
    select
        account_pk,
        countif(is_stalled and not is_completed)    as overdue_onboarding_steps
    from {{ source('mart_product', 'fct_onboarding_funnel') }}
    group by 1
),

-- Expansion signals from warehouse (if available, else default to false)
s_expansion as (
    select
        account_pk,
        logical_or(is_active)                       as expansion_signal_active
    from {{ source('mart_customer', 'fct_expansion_signals') }}
    group by 1
),

assembled as (
    select
        a.account_pk,
        a.account_name,
        a.csm_owner,
        a.segment,
        a.region,
        a.arr_usd,
        a.last_qbr_date,
        date_diff(current_date(), a.last_qbr_date, day)         as days_since_qbr,

        -- Health
        coalesce(h.health_score, null)                          as health_score,
        h.health_band,
        h.churn_probability,
        h.churn_risk_band,
        h.is_at_risk,
        h.score_change_7d                                       as health_score_7d_change,

        -- Renewal
        r.next_renewal_date                                     as renewal_date,
        r.days_to_renewal,

        -- Open actions
        coalesce(z.open_support_tickets, 0)                     as open_support_tickets,
        coalesce(ob.overdue_onboarding_steps, 0)                as overdue_onboarding_steps,

        -- NPS
        nps.nps_score                                           as nps_score_latest,

        -- Expansion
        coalesce(ex.expansion_signal_active, false)             as expansion_signal_active

    from s_accounts as a
    left join s_health as h
        on a.account_pk = h.account_pk
    left join s_renewals as r
        on a.account_pk = r.account_pk
    left join s_zendesk_open as z
        on a.account_pk = z.account_pk
    left join s_nps as nps
        on a.account_pk = nps.account_pk
    left join s_onboarding as ob
        on a.account_pk = ob.account_pk
    left join s_expansion as ex
        on a.account_pk = ex.account_pk
    where a.is_active = true
),

final as (
    select * from assembled
)

select * from final
