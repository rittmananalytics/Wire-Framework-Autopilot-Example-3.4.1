{{
    config(
        materialized='incremental',
        unique_key='incident_pk',
        partition_by={
            'field': 'created_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['severity'],
        tags=['warehouse', 'warehouse_operations']
    )
}}

/*
fct_incident_response
---------------------
PagerDuty incidents with MTTR calculation and weekly support ticket correlation.
The concurrent_support_tickets field enables DO-02 correlation analysis.

Grain: incident_pk (one row per PagerDuty incident)
Incremental: append by created_date
*/

with s_incidents as (
    select * from {{ ref('stg_pagerduty__incidents') }}
    {% if is_incremental() %}
    where cast(created_at as date) > (select max(created_date) from {{ this }})
    {% endif %}
),

-- Weekly support ticket counts for correlation
s_weekly_tickets as (
    select
        date_trunc(created_date, week(monday))       as ticket_week,
        count(*)                                     as ticket_count
    from {{ ref('stg_zendesk__tickets') }}
    group by 1
),

-- MTTR targets by severity
mttr_targets as (
    select 'P1' as severity, {{ var('ops_mttr_p1_target_hours', 2) }} as target_hours
    union all select 'P2', {{ var('ops_mttr_p2_target_hours', 8) }}
),

enriched as (
    select
        to_hex(sha256(cast(i.incident_pk as bytes)))                as incident_pk,
        i.incident_number,
        cast(i.created_at as date)                                  as created_date,
        cast(i.resolved_at as date)                                 as resolved_date,
        i.severity,
        i.status,
        i.resolution_minutes / 60.0                                 as resolution_hours,
        mt.target_hours                                             as mttr_target_hours,
        case
            when i.resolved_at is null then false
            when i.resolution_minutes / 60.0 <= coalesce(mt.target_hours, 999)
                then true
            else false
        end                                                         as is_within_mttr_target,
        i.service_name,
        -- ISO week start for correlation join
        date_trunc(cast(i.created_at as date), week(monday))       as incident_week,
        -- Concurrent support tickets in same week
        coalesce(wt.ticket_count, 0)                               as concurrent_support_tickets
    from s_incidents as i
    left join mttr_targets as mt
        on i.severity = mt.severity
    left join s_weekly_tickets as wt
        on date_trunc(cast(i.created_at as date), week(monday)) = wt.ticket_week
),

final as (
    select * from enriched
)

select * from final
