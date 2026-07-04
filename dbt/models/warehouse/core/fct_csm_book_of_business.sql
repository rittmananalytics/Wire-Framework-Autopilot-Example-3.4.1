{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
fct_csm_book_of_business
-------------------------
Daily snapshot of each CSM's book of business — one row per active account,
showing health score, churn risk, renewal context, and open action indicators.

The csm_owner column is the Looker RLS filter field.
Each CSM sees only rows where csm_owner = their Looker user attribute value.
Tara Obinna (is_leadership = true) sees all CSMs.

Grain: account_pk (one row per active account — current snapshot)
Full refresh daily.
*/

with s_int as (
    select * from {{ ref('int__csm_book') }}
),

final as (
    select
        to_hex(sha256(cast(account_pk as bytes)
            || cast(current_date() as string)))                     as account_csm_pk,
        account_pk,
        current_date()                                              as snapshot_date,
        csm_owner,
        account_name,
        segment,
        region,
        arr_usd,
        health_score,
        health_band,
        health_score_7d_change,
        churn_probability,
        churn_risk_band,
        is_at_risk,
        renewal_date,
        days_to_renewal,
        open_support_tickets,
        overdue_onboarding_steps,
        nps_score_latest,
        expansion_signal_active,
        last_qbr_date,
        days_since_qbr,
        current_timestamp()                                         as _loaded_at
    from s_int
)

select * from final
