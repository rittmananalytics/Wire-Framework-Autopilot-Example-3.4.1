-- fct_workflow_completion
-- Workflow completions from Mixpanel. Incremental; partitioned by completed_date.

{{
    config(
        materialized='incremental',
        unique_key='workflow_pk',
        partition_by={
            'field': 'completed_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk'],
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_mixpanel_events as (
    select * from {{ ref('stg_mixpanel__events') }}
    where event_name like 'workflow_%completed'
    {% if is_incremental() %}
    and date(event_timestamp_utc) >= date_sub(current_date(), interval 3 day)
    {% endif %}
),

s_corefm_users as (
    select * from {{ ref('stg_corefm__users') }}
),

workflow_events as (
    select
        to_hex(sha256(cast(e.event_id as bytes)))                             as workflow_pk,
        to_hex(sha256(cast(lower(trim(e.distinct_id)) as bytes)))             as user_pk,
        u.account_pk,
        e.properties.workflow_id                                              as workflow_id,
        e.properties.workflow_name                                            as workflow_name,
        e.event_timestamp_utc                                                 as completed_at,
        date(e.event_timestamp_utc)                                           as completed_date,
        cast(e.properties.duration_seconds as int64)                          as duration_seconds,
        cast(e.properties.step_count as int64)                                as step_count
    from s_mixpanel_events as e
    left join s_corefm_users as u
        on e.distinct_id = u.corefm_user_id
),

final as (
    select
        workflow_pk,
        user_pk,
        account_pk,
        workflow_id,
        workflow_name,
        completed_at,
        completed_date,
        duration_seconds,
        step_count
    from workflow_events
    where account_pk is not null
)

select * from final
