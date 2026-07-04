{{
    config(
        materialized='incremental',
        unique_key='account_health_pk',
        partition_by={
            'field': 'score_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk', 'health_band'],
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
dim_account_health
------------------
Daily Customer Health Score per account — composite of 5 normalised signals.
Also stores churn_probability joined from ml_models.customer_churn_predictions.

Signal weights are configurable via dbt vars:
  - customer_health_product_weight     (default: 0.30)
  - customer_health_support_weight     (default: 0.20)
  - customer_health_financial_weight   (default: 0.25)
  - customer_health_relationship_weight (default: 0.15)
  - customer_health_nps_weight         (default: 0.10)

Grain: account_pk × score_date (one row per account per day)
Incremental: append new score_date partitions daily
*/

with s_int as (
    select * from {{ ref('int__account_health') }}
    {% if is_incremental() %}
    where score_date > (select max(score_date) from {{ this }})
    {% endif %}
),

s_churn_predictions as (
    select
        account_pk,
        churn_probability,
        churn_risk_band,
        prediction_date
    from {{ source('ml_models', 'customer_churn_predictions') }}
    where prediction_date = date_sub(current_date(), interval 1 day)
),

-- Signal 1: Product normalisation (already 0–100, divide by 100)
product_normalised as (
    select
        account_pk,
        score_date,
        coalesce(product_signal_raw / 100.0, 0.0)                  as product_signal_normalised
    from s_int
),

-- Signal 2: Support normalisation
-- CSAT: 0–5 scale → normalise to 0–1 (target: 4.2/5)
-- Resolution hours: lower is better; normalise 0–1 (target: 24hrs max)
-- Ticket volume: lower is better relative to baseline
support_normalised as (
    select
        account_pk,
        score_date,
        greatest(0.0, least(1.0,
            (
                coalesce(support_csat_avg, 3.0) / 5.0
                    * {{ var('support_health_csat_weight', 0.50) }}
            )
            + (
                greatest(0.0, 1.0 - coalesce(support_resolution_hrs_avg, 48) / 96.0)
                    * {{ var('support_health_resolution_weight', 0.30) }}
            )
            + (
                greatest(0.0, 1.0 - (coalesce(support_ticket_count, 0) / 10.0))
                    * {{ var('support_health_volume_weight', 0.20) }}
            )
        ))                                                          as support_signal_normalised
    from s_int
),

-- Signal 3: Financial normalisation
-- ARR stability: no contraction = 1.0; mild contraction = 0.5; churn_risk = 0.1
-- Renewal proximity: >180 days = 1.0; <30 days at risk = 0.3
financial_normalised as (
    select
        account_pk,
        score_date,
        greatest(0.0, least(1.0,
            case
                when financial_arr_usd is null then 0.5
                when financial_renewal_days is null then 0.7
                when financial_renewal_days >= 180 then 1.0
                when financial_renewal_days >= 90  then 0.8
                when financial_renewal_days >= 60  then 0.65
                when financial_renewal_days >= 30  then 0.5
                else 0.3
            end
        ))                                                          as financial_signal_normalised
    from s_int
),

-- Signal 4: Relationship normalisation
-- QBR within 180 days: 1.0; older: 0.5; never: 0.2
-- Exec sponsor: +0.2 bonus
-- Open escalations: -0.3 per escalation (min 0)
relationship_normalised as (
    select
        account_pk,
        score_date,
        greatest(0.0, least(1.0,
            case
                when relationship_qbr_days_since is null then 0.2
                when relationship_qbr_days_since <= 90  then 1.0
                when relationship_qbr_days_since <= 180 then 0.75
                when relationship_qbr_days_since <= 365 then 0.5
                else 0.2
            end
            + case when relationship_exec_sponsor = true then 0.2 else 0.0 end
            - (coalesce(0, 0) * 0.3)  -- open escalation placeholder (Zendesk P1 count)
        ))                                                          as relationship_signal_normalised
    from s_int
),

-- Signal 5: NPS normalisation
-- NPS -100 to 100 → normalise to 0–1: (nps + 100) / 200
-- NULL (no recent survey) = 0.5 neutral
nps_normalised as (
    select
        account_pk,
        score_date,
        case
            when nps_score_latest is null then 0.5
            else greatest(0.0, least(1.0, (coalesce(nps_score_latest, 0) + 100.0) / 200.0))
        end                                                         as nps_signal_normalised
    from s_int
),

-- Combine all signals into health score
health_scored as (
    select
        to_hex(sha256(cast(s.account_pk as bytes)
            || cast(s.score_date as string)))                       as account_health_pk,
        s.account_pk,
        s.score_date,

        -- Individual signal contributions (normalised 0–1)
        pn.product_signal_normalised                                as product_component,
        sn.support_signal_normalised                                as support_component,
        fn.financial_signal_normalised                              as financial_component,
        rn.relationship_signal_normalised                           as relationship_component,
        nn.nps_signal_normalised                                    as nps_component,

        -- Composite health score (weighted sum → 0–100)
        least(100, greatest(0, cast(round(
            (pn.product_signal_normalised * 100 * {{ var('customer_health_product_weight', 0.30) }})
          + (sn.support_signal_normalised * 100 * {{ var('customer_health_support_weight', 0.20) }})
          + (fn.financial_signal_normalised * 100 * {{ var('customer_health_financial_weight', 0.25) }})
          + (rn.relationship_signal_normalised * 100 * {{ var('customer_health_relationship_weight', 0.15) }})
          + (nn.nps_signal_normalised * 100 * {{ var('customer_health_nps_weight', 0.10) }})
        , 0) as int64)))                                            as health_score,

        -- Churn prediction (joined from BQML output)
        cp.churn_probability,
        cp.churn_risk_band

    from s_int as s
    left join product_normalised as pn
        on s.account_pk = pn.account_pk and s.score_date = pn.score_date
    left join support_normalised as sn
        on s.account_pk = sn.account_pk and s.score_date = sn.score_date
    left join financial_normalised as fn
        on s.account_pk = fn.account_pk and s.score_date = fn.score_date
    left join relationship_normalised as rn
        on s.account_pk = rn.account_pk and s.score_date = rn.score_date
    left join nps_normalised as nn
        on s.account_pk = nn.account_pk and s.score_date = nn.score_date
    left join s_churn_predictions as cp
        on s.account_pk = cp.account_pk
),

-- Add score band, is_at_risk, and 7-day trend
with_bands as (
    select
        account_health_pk,
        account_pk,
        score_date,
        health_score,
        case
            when health_score < {{ var('customer_health_at_risk_threshold', 40) }}
                then 'At Risk'
            when health_score < {{ var('customer_health_needs_attention_threshold', 60) }}
                then 'Needs Attention'
            when health_score < {{ var('customer_health_healthy_threshold', 80) }}
                then 'Healthy'
            else 'Excellent'
        end                                                         as health_band,
        product_component,
        support_component,
        financial_component,
        relationship_component,
        nps_component,
        churn_probability,
        coalesce(churn_risk_band, 'Low')                            as churn_risk_band,
        health_score < {{ var('customer_health_at_risk_threshold', 40) }}
                                                                    as is_at_risk,
        -- 7-day trend
        health_score - lag(health_score, 7) over (
            partition by account_pk
            order by score_date
        )                                                           as score_change_7d,
        current_timestamp()                                         as _loaded_at
    from health_scored
),

with_trend_label as (
    select
        *,
        case
            when score_change_7d > 5  then 'improving'
            when score_change_7d < -5 then 'declining'
            else 'stable'
        end                                                         as score_trend_7d
    from with_bands
),

final as (
    select * from with_trend_label
)

select * from final
