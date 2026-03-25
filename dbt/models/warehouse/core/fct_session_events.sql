-- fct_session_events
-- Session records per user per account. Incremental; partitioned by session_date.

{{
    config(
        materialized='incremental',
        unique_key='session_pk',
        partition_by={
            'field': 'session_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk'],
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_int_account_sessions as (
    select * from {{ ref('int__account_sessions') }}
    {% if is_incremental() %}
    where session_date >= date_sub(current_date(), interval 3 day)
    {% endif %}
),

final as (
    select
        session_pk,
        user_pk,
        account_pk,
        session_date,
        session_start_ts,
        session_end_ts,
        duration_seconds,
        page_count,
        event_count
    from s_int_account_sessions
)

select * from final
