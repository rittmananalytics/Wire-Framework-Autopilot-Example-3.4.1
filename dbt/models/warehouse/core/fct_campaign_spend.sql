{{
    config(
        materialized='incremental',
        unique_key='spend_pk',
        partition_by={
            'field': 'spend_date',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['platform', 'campaign_fk'],
        tags=['warehouse', 'warehouse_marketing'],
        incremental_strategy='merge'
    )
}}

with s_spend as (
    select * from {{ ref('int__campaign_spend__normalised') }}

    {% if is_incremental() %}
        -- Ad platforms do full refresh daily, so reload the last 7 days to catch late corrections
        where spend_date >= date_sub(current_date(), interval 7 day)
    {% endif %}
),

s_campaigns as (
    select campaign_pk, source_campaign_id, platform as campaign_source
    from {{ ref('dim_campaign') }}
),

final as (
    select
        s.spend_pk,
        s.spend_date,
        s.platform,

        -- FK join: match spend to dim_campaign by platform + source campaign ID
        dc.campaign_pk as campaign_fk,
        s.campaign_name,

        s.ad_group_id,
        s.ad_group_name,
        s.impressions,
        s.clicks,
        s.spend_usd,
        s.ctr,
        s.cpc,
        current_timestamp() as _loaded_at
    from s_spend s
    left join s_campaigns dc
        on s.campaign_id = dc.source_campaign_id
        and s.platform = dc.campaign_source
)

select * from final
