{{
    config(
        materialized='incremental',
        unique_key='touch_pk',
        partition_by={
            'field': 'touch_date',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['channel', 'touch_type'],
        tags=['warehouse', 'warehouse_marketing'],
        incremental_strategy='merge'
    )
}}

with s_touches as (
    select * from {{ ref('int__marketing_touches__all_channels') }}

    {% if is_incremental() %}
        where touch_date >= (
            select date_sub(max(touch_date), interval 3 day)
            from {{ this }}
        )
    {% endif %}
),

s_campaigns as (
    select campaign_pk, source_campaign_id, platform as campaign_source, source_system
    from {{ ref('dim_campaign') }}
),

s_asset_mapping as (
    -- Form-to-asset mapping from Niamh Collins
    select form_id, asset_name, asset_category
    from {{ ref('form_asset_mapping') }}
),

final as (
    select
        t.touch_pk,
        t.contact_pk,
        t.touch_ts,
        t.touch_date,
        t.touch_type,
        t.channel,
        t.source_system,

        -- FK to dim_campaign
        dc.campaign_pk as campaign_fk,
        t.campaign_name,

        -- Asset enrichment
        t.asset_id,
        coalesce(am.asset_category, null) as asset_category,

        t.is_attributed,
        t.utm_source,
        t.utm_medium,
        current_timestamp() as _loaded_at
    from s_touches t
    left join s_campaigns dc
        on t.campaign_id = dc.source_campaign_id
    left join s_asset_mapping am
        on t.asset_id = am.form_id
        and t.touch_type = 'form_submit'
)

select * from final
