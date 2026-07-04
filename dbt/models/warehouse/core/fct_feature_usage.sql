-- fct_feature_usage
-- Deduplicated feature usage events with 3-level taxonomy applied.
-- Materialized incrementally; partitioned by event_date; clustered by account_pk, module_id.

{{
    config(
        materialized='incremental',
        unique_key='event_pk',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk', 'module_id'],
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_int_feature_usage as (
    select * from {{ ref('int__feature_usage') }}
    {% if is_incremental() %}
    where event_date >= date_sub(current_date(), interval 3 day)
    {% endif %}
),

final as (
    select
        event_pk,
        user_pk,
        account_pk,
        feature_id,
        feature_name,
        feature_group_id,
        feature_group_name,
        module_id,
        module_name,
        event_name,
        event_date,
        event_timestamp_utc,
        source_system,
        session_id
    from s_int_feature_usage
)

select * from final
