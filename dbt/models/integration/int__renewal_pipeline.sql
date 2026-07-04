{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_customer']
    )
}}

/*
int__renewal_pipeline
---------------------
Upcoming renewal opportunities enriched with account health context.
Scoped to renewals within the configured pipeline window (default: 180 days).

Grain: opportunity_pk (one row per renewal opportunity)
*/

with s_opportunities as (
    select * from {{ ref('stg_salesforce__opportunities') }}
    where type = 'Renewal'
      and close_date between current_date()
                         and date_add(current_date(), interval {{ var('renewal_pipeline_days_forward', 180) }} day)
),

s_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_health as (
    -- Most recent health score per account
    select
        account_pk,
        health_score,
        health_band,
        churn_probability,
        churn_risk_band,
        score_date
    from {{ source('mart_customer', 'dim_account_health') }}
    where score_date = (
        select max(score_date)
        from {{ source('mart_customer', 'dim_account_health') }}
    )
),

enriched as (
    select
        o.opportunity_pk,
        o.account_pk,
        a.account_name,
        a.csm_owner,
        a.segment,
        a.region,
        o.close_date                                                    as renewal_date,
        o.amount                                                        as arr_usd,
        o.stage_name                                                    as renewal_stage,
        date_diff(o.close_date, current_date(), day)                    as days_to_renewal,
        case
            when date_diff(o.close_date, current_date(), day) <= 30  then '0-30'
            when date_diff(o.close_date, current_date(), day) <= 60  then '31-60'
            when date_diff(o.close_date, current_date(), day) <= 90  then '61-90'
            when date_diff(o.close_date, current_date(), day) <= 180 then '91-180'
            else '180+'
        end                                                             as renewal_bucket,
        coalesce(h.health_score, null)                                  as latest_health_score,
        h.health_band,
        h.churn_probability,
        h.churn_risk_band,
        h.health_score < {{ var('customer_health_at_risk_threshold', 40) }}
                                                                        as is_at_risk,
        -- Weighted ARR = ARR × (1 - churn_probability)
        round(
            o.amount * (1 - coalesce(h.churn_probability, 0.0)),
            2
        )                                                               as weighted_arr_usd,
        round(
            o.amount * coalesce(h.churn_probability, 0.0),
            2
        )                                                               as arr_at_risk_usd
    from s_opportunities as o
    inner join s_accounts as a
        on o.account_pk = a.account_pk
    left join s_health as h
        on o.account_pk = h.account_pk
),

final as (
    select * from enriched
)

select * from final
