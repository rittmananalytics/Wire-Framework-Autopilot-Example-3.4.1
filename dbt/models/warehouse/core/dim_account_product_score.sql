-- dim_account_product_score
-- Monthly product engagement score per account. Full table rebuild.
-- Composite score from 7 weighted signals (weights configurable via dbt vars).
-- Score range: 0–100. Historical monthly scores retained for trending.

{{
    config(
        materialized='table',
        cluster_by=['account_pk', 'score_month'],
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_dim_account as (
    select * from {{ ref('dim_account') }}
),

s_fct_feature_usage as (
    select * from {{ ref('fct_feature_usage') }}
),

s_fct_session_events as (
    select * from {{ ref('fct_session_events') }}
),

s_fct_onboarding_funnel as (
    select * from {{ ref('fct_onboarding_funnel') }}
),

s_feature_taxonomy as (
    select * from {{ ref('feature_taxonomy') }}
    where feature_id != 'feat_999'  -- exclude unmapped events from breadth calculation
),

s_nps as (
    -- NPS responses from Intercom (most recent per account within 180-day window)
    select * from {{ ref('stg_intercom__nps_surveys') }}
),

s_corefm_work_orders as (
    select * from {{ ref('stg_corefm__work_orders') }}
),

-- Generate a month spine (last 24 months)
month_spine as (
    select
        date_trunc(
            date_add(date_trunc(current_date(), month),
            interval -n month),
            month
        ) as score_month
    from unnest(generate_array(0, 23)) as n
),

-- All active accounts × all months
account_months as (
    select
        a.account_pk,
        a.salesforce_account_id,
        a.contract_start_date,
        a.contracted_user_seats,
        ms.score_month
    from s_dim_account as a
    cross join month_spine as ms
    where a.is_active = true
    and ms.score_month >= date_trunc(a.contract_start_date, month)
),

-- Signal 1: DAU/MAU ratio (30-day rolling within each scoring month)
dau_mau as (
    select
        account_pk,
        date_trunc(session_date, month)                                     as score_month,
        count(distinct case
            when session_date >= date_sub(date_trunc(session_date, month), interval 1 day)
            then user_pk end)                                               as dau_numerator,
        count(distinct user_pk)                                             as mau,
        safe_divide(
            count(distinct user_pk),
            date_diff(
                last_day(date_trunc(session_date, month)),
                date_trunc(session_date, month),
                day
            ) + 1
        )                                                                   as dau_mau_ratio,
        count(distinct user_pk)                                             as active_users
    from s_fct_session_events
    group by 1, 2
),

-- Signal 2: Feature breadth
feature_breadth as (
    select
        account_pk,
        date_trunc(event_date, month)                                       as score_month,
        count(distinct feature_id)                                          as distinct_features_used,
        safe_divide(
            count(distinct feature_id),
            (select count(*) from s_feature_taxonomy)
        )                                                                   as feature_breadth_normalised
    from s_fct_feature_usage
    group by 1, 2
),

-- Signal 3: Core feature activation (% of core features used at least once)
core_features as (
    select count(*) as total_core_features
    from s_feature_taxonomy
    where feature_group_id in ('fg_001', 'fg_002', 'fg_003')  -- Work Order, Asset, Reporting = core
),

core_activation as (
    select
        account_pk,
        date_trunc(event_date, month)                                       as score_month,
        safe_divide(
            count(distinct case
                when feature_group_id in ('fg_001', 'fg_002', 'fg_003')
                then feature_id end),
            (select total_core_features from core_features)
        )                                                                   as core_activation_score
    from s_fct_feature_usage
    group by 1, 2
),

-- Signal 4: Work order created within first 30 days of contract
work_order_signal as (
    select
        to_hex(sha256(cast(a.account_id as bytes)))                         as account_pk,
        exists (
            select 1 from s_corefm_work_orders as wo
            where wo.account_id = a.account_id
            and date_diff(wo.created_date, a.contract_start_date, day) <= 30
        )                                                                   as work_order_within_30_days
    from {{ ref('stg_salesforce__accounts') }} as a
    inner join {{ ref('stg_salesforce__contracts') }} as c
        on a.account_id = c.account_id
    where c.status = 'Activated'
    qualify row_number() over (partition by a.account_id order by c.start_date) = 1
),

-- Signal 5: Licence utilisation
licence_util as (
    select
        to_hex(sha256(cast(wo.account_id as bytes)))                        as account_pk,
        date_trunc(current_date(), month)                                   as score_month,  -- current month only; historical via snapshot
        safe_divide(
            count(distinct s.user_pk),
            max(a.contracted_user_seats)
        )                                                                   as licence_utilisation_pct
    from s_fct_session_events as s
    inner join {{ ref('stg_corefm__users') }} as u
        on s.user_pk = to_hex(sha256(cast(u.corefm_user_id as bytes)))
    inner join {{ ref('stg_corefm__accounts') }} as wo
        on u.account_id = wo.account_id
    inner join s_dim_account as a
        on to_hex(sha256(cast(wo.account_id as bytes))) = a.account_pk
    where s.session_date >= date_sub(current_date(), interval 30 day)
    group by 1, 2
),

-- Signal 6: NPS (most recent in last 180 days)
nps_scores as (
    select
        to_hex(sha256(cast(n.account_id as bytes)))                         as account_pk,
        n.nps_score,
        safe_divide(n.nps_score, 10)                                        as nps_normalised,
        n.responded_at
    from s_nps as n
    where n.responded_at >= timestamp_sub(current_timestamp(), interval 180 day)
    qualify row_number() over (partition by n.account_id order by n.responded_at desc) = 1
),

-- Signal 7: Onboarding completion
onboarding_completion as (
    select
        account_pk,
        countif(is_core_step and is_complete)                               as core_steps_completed,
        safe_divide(
            countif(is_core_step and is_complete),
            countif(is_core_step)
        )                                                                   as onboarding_completion_pct
    from s_fct_onboarding_funnel
    group by 1
),

-- Assemble final score
score_assembly as (
    select
        to_hex(sha256(cast(am.account_pk as bytes) || cast(am.score_month as bytes))) as score_pk,
        am.account_pk,
        am.score_month,

        -- Component scores (null-safe; missing signal = 0 contribution)
        coalesce(dm.dau_mau_ratio, 0)                                       as dau_mau_ratio,
        coalesce(dm.active_users, 0)                                        as active_users_30d,
        coalesce(fb.feature_breadth_normalised, 0)                          as feature_breadth_normalised,
        coalesce(fb.distinct_features_used, 0)                              as distinct_features_used,
        coalesce(ca.core_activation_score, 0)                               as core_activation_score,
        coalesce(ws.work_order_within_30_days, false)                       as work_order_within_30_days,
        am.contracted_user_seats,
        coalesce(lu.licence_utilisation_pct, null)                          as licence_utilisation_pct,
        np.nps_score                                                        as nps_score_last_response,
        coalesce(np.nps_normalised, 0)                                      as nps_normalised,
        coalesce(oc.onboarding_completion_pct, 0)                           as onboarding_completion_pct,
        coalesce(oc.core_steps_completed, 0)                                as core_steps_completed,

        -- Composite score
        least(100, greatest(0, cast(round(
            (coalesce(dm.dau_mau_ratio, 0)               * 100 * {{ var('product_score_dau_mau_weight') }})
          + (coalesce(fb.feature_breadth_normalised, 0)  * 100 * {{ var('product_score_feature_breadth_weight') }})
          + (coalesce(ca.core_activation_score, 0)       * 100 * {{ var('product_score_core_activation_weight') }})
          + (case when coalesce(ws.work_order_within_30_days, false) then 100 else 0 end
                                                         * {{ var('product_score_work_order_signal_weight') }})
          + (coalesce(lu.licence_utilisation_pct, 0)     * 100 * {{ var('product_score_licence_util_weight') }})
          + (coalesce(np.nps_normalised, 0)              * 100 * {{ var('product_score_nps_weight') }})
          + (coalesce(oc.onboarding_completion_pct, 0)   * 100 * {{ var('product_score_onboarding_weight') }})
        , 0) as int64)))                                                     as product_engagement_score

    from account_months as am
    left join dau_mau as dm
        on am.account_pk = dm.account_pk
        and am.score_month = dm.score_month
    left join feature_breadth as fb
        on am.account_pk = fb.account_pk
        and am.score_month = fb.score_month
    left join core_activation as ca
        on am.account_pk = ca.account_pk
        and am.score_month = ca.score_month
    left join work_order_signal as ws
        on am.account_pk = ws.account_pk
    left join licence_util as lu
        on am.account_pk = lu.account_pk
    left join nps_scores as np
        on am.account_pk = np.account_pk
    left join onboarding_completion as oc
        on am.account_pk = oc.account_pk
),

final as (
    select
        score_pk,
        account_pk,
        score_month,
        product_engagement_score,
        dau_mau_ratio,
        active_users_30d,
        feature_breadth_normalised,
        distinct_features_used,
        core_activation_score,
        work_order_within_30_days,
        contracted_user_seats,
        licence_utilisation_pct,
        nps_score_last_response,
        nps_normalised,
        onboarding_completion_pct,
        core_steps_completed,
        product_engagement_score < {{ var('product_at_risk_score_threshold') }} as is_at_risk
    from score_assembly
)

select * from final
