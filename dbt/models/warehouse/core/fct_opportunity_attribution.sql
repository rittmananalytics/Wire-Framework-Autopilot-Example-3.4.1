{{
    config(
        materialized='table',
        partition_by={
            'field': 'opportunity_created_date',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['attribution_model', 'channel'],
        tags=['warehouse', 'warehouse_marketing']
    )
}}

-- Attribution window and weight parameters from dbt_project.yml vars
{% set attribution_window = var('marketing_attribution_window_days', 180) %}
{% set u_first = var('u_shaped_first_touch_weight', 0.40) %}
{% set u_conversion = var('u_shaped_lead_conversion_weight', 0.40) %}
{% set u_middle = var('u_shaped_middle_weight', 0.20) %}
{% set td_half_life = var('time_decay_half_life_days', 30) %}

with s_attributed as (
    select * from {{ ref('int__opportunities__attributed') }}
),

s_campaigns as (
    select campaign_pk, source_campaign_id
    from {{ ref('dim_campaign') }}
),

-- Calculate time-decay raw weights (before normalisation)
time_decay_raw as (
    select
        opportunity_pk,
        touch_pk,
        pow(0.5, days_before_opportunity / cast({{ td_half_life }} as float64)) as raw_decay_weight
    from s_attributed
),

-- Normalise time-decay weights so they sum to 1.0 per opportunity
time_decay_normalised as (
    select
        opportunity_pk,
        touch_pk,
        raw_decay_weight / nullif(sum(raw_decay_weight) over (partition by opportunity_pk), 0) as time_decay_weight
    from time_decay_raw
),

-- Calculate u-shaped weights
u_shaped_weights as (
    select
        opportunity_pk,
        touch_pk,
        is_first_touch,
        is_last_touch,
        is_lead_conversion_touch,
        is_middle_touch,
        total_touches_in_window,
        case
            -- Edge case: only 1 touch — gets 100%
            when total_touches_in_window = 1 then 1.0
            -- Edge case: first touch IS the lead conversion touch — combined 80%
            when is_first_touch and is_lead_conversion_touch then cast({{ u_first }} + {{ u_conversion }} as float64)
            -- First touch: 40%
            when is_first_touch then cast({{ u_first }} as float64)
            -- Lead conversion touch (not first): 40%
            when is_lead_conversion_touch then cast({{ u_conversion }} as float64)
            -- 2-touch journey fallback (no middle touches): 50/50
            when total_touches_in_window = 2 then 0.5
            -- Middle touches: split 20% evenly
            when is_middle_touch
            then cast({{ u_middle }} as float64) / cast(nullif(total_touches_in_window - 2, 0) as float64)
            else 0.0
        end as u_shaped_weight
    from s_attributed
),

-- Assemble all 5 attribution models as separate rows
all_models as (
    select
        {{ dbt_utils.generate_surrogate_key(['a.opportunity_pk', 'a.touch_pk', "'first_touch'"]) }} as attribution_pk,
        a.opportunity_pk,
        a.touch_pk,
        a.contact_pk,
        'first_touch' as attribution_model,
        case when a.is_first_touch then a.opportunity_arr_usd else 0.0 end as attributed_revenue_usd,
        case when a.is_first_touch then a.opportunity_pipeline_usd else 0.0 end as attributed_pipeline_usd,
        case when a.is_first_touch then 1.0 else 0.0 end as touch_weight,
        a.touch_rank_asc as touch_rank,
        a.days_before_opportunity,
        a.is_marketing_sourced,
        a.is_marketing_influenced,
        a.is_closed_won,
        a.opportunity_arr_usd,
        a.opportunity_created_date,
        a.opportunity_close_date,
        a.channel,
        a.campaign_id
    from s_attributed a

    union all

    select
        {{ dbt_utils.generate_surrogate_key(['a.opportunity_pk', 'a.touch_pk', "'last_touch'"]) }} as attribution_pk,
        a.opportunity_pk,
        a.touch_pk,
        a.contact_pk,
        'last_touch' as attribution_model,
        case when a.is_last_touch then a.opportunity_arr_usd else 0.0 end as attributed_revenue_usd,
        case when a.is_last_touch then a.opportunity_pipeline_usd else 0.0 end as attributed_pipeline_usd,
        case when a.is_last_touch then 1.0 else 0.0 end as touch_weight,
        a.touch_rank_asc as touch_rank,
        a.days_before_opportunity,
        a.is_marketing_sourced,
        a.is_marketing_influenced,
        a.is_closed_won,
        a.opportunity_arr_usd,
        a.opportunity_created_date,
        a.opportunity_close_date,
        a.channel,
        a.campaign_id
    from s_attributed a

    union all

    select
        {{ dbt_utils.generate_surrogate_key(['a.opportunity_pk', 'a.touch_pk', "'linear'"]) }} as attribution_pk,
        a.opportunity_pk,
        a.touch_pk,
        a.contact_pk,
        'linear' as attribution_model,
        a.opportunity_arr_usd / cast(a.total_touches_in_window as float64) as attributed_revenue_usd,
        a.opportunity_pipeline_usd / cast(a.total_touches_in_window as float64) as attributed_pipeline_usd,
        1.0 / cast(a.total_touches_in_window as float64) as touch_weight,
        a.touch_rank_asc as touch_rank,
        a.days_before_opportunity,
        a.is_marketing_sourced,
        a.is_marketing_influenced,
        a.is_closed_won,
        a.opportunity_arr_usd,
        a.opportunity_created_date,
        a.opportunity_close_date,
        a.channel,
        a.campaign_id
    from s_attributed a

    union all

    select
        {{ dbt_utils.generate_surrogate_key(['a.opportunity_pk', 'a.touch_pk', "'time_decay'"]) }} as attribution_pk,
        a.opportunity_pk,
        a.touch_pk,
        a.contact_pk,
        'time_decay' as attribution_model,
        a.opportunity_arr_usd * td.time_decay_weight as attributed_revenue_usd,
        a.opportunity_pipeline_usd * td.time_decay_weight as attributed_pipeline_usd,
        td.time_decay_weight as touch_weight,
        a.touch_rank_asc as touch_rank,
        a.days_before_opportunity,
        a.is_marketing_sourced,
        a.is_marketing_influenced,
        a.is_closed_won,
        a.opportunity_arr_usd,
        a.opportunity_created_date,
        a.opportunity_close_date,
        a.channel,
        a.campaign_id
    from s_attributed a
    inner join time_decay_normalised td
        on a.opportunity_pk = td.opportunity_pk
        and a.touch_pk = td.touch_pk

    union all

    select
        {{ dbt_utils.generate_surrogate_key(['a.opportunity_pk', 'a.touch_pk', "'u_shaped'"]) }} as attribution_pk,
        a.opportunity_pk,
        a.touch_pk,
        a.contact_pk,
        'u_shaped' as attribution_model,
        a.opportunity_arr_usd * uw.u_shaped_weight as attributed_revenue_usd,
        a.opportunity_pipeline_usd * uw.u_shaped_weight as attributed_pipeline_usd,
        uw.u_shaped_weight as touch_weight,
        a.touch_rank_asc as touch_rank,
        a.days_before_opportunity,
        a.is_marketing_sourced,
        a.is_marketing_influenced,
        a.is_closed_won,
        a.opportunity_arr_usd,
        a.opportunity_created_date,
        a.opportunity_close_date,
        a.channel,
        a.campaign_id
    from s_attributed a
    inner join u_shaped_weights uw
        on a.opportunity_pk = uw.opportunity_pk
        and a.touch_pk = uw.touch_pk
),

final as (
    select
        am.attribution_pk,
        am.opportunity_pk,
        am.touch_pk,
        am.contact_pk,
        am.attribution_model,
        am.attributed_revenue_usd,
        am.attributed_pipeline_usd,
        am.touch_weight,
        am.touch_rank,
        am.days_before_opportunity,
        am.is_marketing_sourced,
        am.is_marketing_influenced,
        am.is_closed_won,
        am.opportunity_arr_usd,
        am.opportunity_created_date,
        am.opportunity_close_date,
        am.channel,
        dc.campaign_pk as campaign_fk,
        current_timestamp() as _loaded_at
    from all_models am
    left join s_campaigns dc on am.campaign_id = dc.source_campaign_id
)

select * from final
