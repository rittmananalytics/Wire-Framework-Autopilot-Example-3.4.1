{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
fct_expansion_signals
----------------------
Active expansion opportunity signals per account.
An expansion signal fires when:
  - Type 1 (high_engagement_low_util): feature_breadth_score > 70 AND licence_utilisation_pct < 80
  - Type 2 (upsell_opportunity): open Salesforce Upsell opportunity in stage Prospect/Qualify
  - Type 3 (feature_adoption): product module adoption < 50% (untapped modules)

A signal is deactivated (is_active = false) when criteria no longer apply or
when a Salesforce upsell opportunity moves to Closed Won.

Grain: account_pk × signal_date × signal_type (one row per signal occurrence)
Full refresh daily.
*/

with s_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_product_scores as (
    -- Most recent product score per account
    select
        account_pk,
        product_engagement_score,
        feature_breadth_score,
        licence_utilisation_pct,
        score_month
    from {{ source('mart_product', 'dim_account_product_score') }}
    where score_month = (
        select max(score_month)
        from {{ source('mart_product', 'dim_account_product_score') }}
    )
),

s_upsell_opps as (
    select
        account_pk,
        opportunity_pk,
        stage_name,
        close_date,
        amount
    from {{ ref('stg_salesforce__opportunities') }}
    where type = 'Upsell'
      and stage_name not in ('Closed Won', 'Closed Lost')
),

-- Signal 1: High engagement + low licence utilisation
signal_expansion as (
    select
        a.account_pk,
        current_date()                                              as signal_date,
        'high_engagement_low_util'                                  as signal_type,
        concat(
            'Feature breadth: ',
            cast(round(ps.feature_breadth_score, 0) as string),
            '% | Licence util: ',
            cast(round(ps.licence_utilisation_pct, 0) as string),
            '%'
        )                                                           as trigger_criteria,
        ps.feature_breadth_score,
        ps.licence_utilisation_pct,
        a.arr_usd,
        a.csm_owner,
        true                                                        as is_active
    from s_accounts as a
    inner join s_product_scores as ps
        on a.account_pk = ps.account_pk
    where ps.feature_breadth_score > 70
      and coalesce(ps.licence_utilisation_pct, 100) < 80
      and a.is_active = true
),

-- Signal 2: Upsell opportunity open in Salesforce
signal_upsell as (
    select
        a.account_pk,
        current_date()                                              as signal_date,
        'upsell_opportunity'                                        as signal_type,
        concat(
            'Salesforce upsell opp in stage: ',
            uo.stage_name,
            ' | Close date: ',
            cast(uo.close_date as string)
        )                                                           as trigger_criteria,
        ps.feature_breadth_score,
        ps.licence_utilisation_pct,
        a.arr_usd,
        a.csm_owner,
        true                                                        as is_active
    from s_accounts as a
    inner join s_upsell_opps as uo
        on a.account_pk = uo.account_pk
    left join s_product_scores as ps
        on a.account_pk = ps.account_pk
    where a.is_active = true
),

-- Signal 3: Low module adoption (feature adoption gap)
signal_feature_gap as (
    select
        a.account_pk,
        current_date()                                              as signal_date,
        'feature_adoption'                                          as signal_type,
        concat(
            'Feature breadth at ',
            cast(round(ps.feature_breadth_score, 0) as string),
            '% — 3+ modules unused'
        )                                                           as trigger_criteria,
        ps.feature_breadth_score,
        ps.licence_utilisation_pct,
        a.arr_usd,
        a.csm_owner,
        true                                                        as is_active
    from s_accounts as a
    inner join s_product_scores as ps
        on a.account_pk = ps.account_pk
    where ps.feature_breadth_score < 50  -- less than 50% feature breadth = adoption gap
      and a.is_active = true
),

all_signals as (
    select * from signal_expansion
    union all
    select * from signal_upsell
    union all
    select * from signal_feature_gap
),

with_pk as (
    select
        to_hex(sha256(cast(account_pk as bytes)
            || cast(signal_date as string)
            || cast(signal_type as bytes)))                         as signal_pk,
        *
    from all_signals
),

final as (
    select * from with_pk
)

select * from final
