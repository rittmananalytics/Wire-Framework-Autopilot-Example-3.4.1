{{
    config(
        materialized='incremental',
        unique_key='funnel_event_pk',
        partition_by={
            'field': 'stage_entered_date',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['stage_name', 'channel'],
        tags=['warehouse', 'warehouse_marketing'],
        incremental_strategy='merge'
    )
}}

with s_funnel_events as (
    select * from {{ ref('int__funnel_events__staged') }}

    {% if is_incremental() %}
        where stage_entered_ts >= (
            select date_sub(max(stage_entered_date), interval 3 day)
            from {{ this }}
        )
    {% endif %}
),

final as (
    select
        funnel_event_pk,
        contact_pk,
        account_fk,
        stage_name,
        stage_order,
        stage_entered_ts,
        stage_exited_ts,
        date(stage_entered_ts) as stage_entered_date,
        days_in_stage,
        is_converted,
        channel,
        campaign_id,
        is_current_stage,
        current_timestamp() as _loaded_at
    from s_funnel_events
)

select * from final
