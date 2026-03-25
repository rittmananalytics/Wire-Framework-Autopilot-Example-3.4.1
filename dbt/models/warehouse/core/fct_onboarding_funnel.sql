-- fct_onboarding_funnel
-- Onboarding step progress per account with stalled flags.
-- Full table rebuild (small table; onboarding state can change for any account).

{{
    config(
        materialized='table',
        cluster_by=['account_pk'],
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_int_onboarding as (
    select * from {{ ref('int__onboarding') }}
),

s_dim_account as (
    select * from {{ ref('dim_account') }}
),

with_account_context as (
    select
        o.onboarding_pk,
        o.account_pk,
        o.account_name,
        a.csm_name,
        a.segment,
        o.step_id,
        o.step_name,
        o.step_order,
        o.is_core_step,
        o.is_complete,
        o.completed_at,
        o.days_since_signup,
        o.is_stalled,
        -- At-risk flag: account score below threshold (joined if score table exists)
        -- Note: dim_account_product_score is built after this model, so we use a proxy
        -- The CS team sees is_stalled as the primary intervention signal
        false as is_at_risk  -- placeholder; populated by Looker derived dimension in Release 05
    from s_int_onboarding as o
    left join s_dim_account as a
        on o.account_pk = a.account_pk
),

final as (
    select
        onboarding_pk,
        account_pk,
        account_name,
        csm_name,
        segment,
        step_id,
        step_name,
        step_order,
        is_core_step,
        is_complete,
        completed_at,
        days_since_signup,
        is_stalled,
        is_at_risk
    from with_account_context
)

select * from final
