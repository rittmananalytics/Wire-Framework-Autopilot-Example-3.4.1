{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
fct_renewal_pipeline
---------------------
Upcoming renewals within the configured pipeline window (default 180 days).
Full refresh daily — renewal pipeline is always current as of today.

Grain: opportunity_pk (one row per renewal opportunity)
Financial metrics (arr_usd, weighted_arr_usd, arr_at_risk_usd) are
marked as restricted in the semantic layer (finance_viewers + leadership only).
*/

with s_int as (
    select * from {{ ref('int__renewal_pipeline') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['opportunity_pk']) }}   as opportunity_pk,
        account_pk,
        account_name,
        csm_owner,
        segment,
        region,
        renewal_date,
        arr_usd,
        weighted_arr_usd,
        arr_at_risk_usd,
        renewal_stage,
        days_to_renewal,
        renewal_bucket,
        latest_health_score                                          as health_score,
        health_band,
        churn_probability,
        churn_risk_band,
        is_at_risk,
        current_timestamp()                                          as _loaded_at
    from s_int
)

select * from final
