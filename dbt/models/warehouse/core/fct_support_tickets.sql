{{
    config(
        materialized='incremental',
        unique_key='ticket_pk',
        partition_by={
            'field': 'created_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk', 'priority'],
        tags=['warehouse', 'warehouse_operations']
    )
}}

/*
fct_support_tickets
-------------------
Zendesk support tickets enriched with account context, SLA flags,
and CSM attribution. Joins to dim_account for segment and csm_owner.

Grain: ticket_pk (one row per Zendesk ticket)
Incremental: append by created_date
*/

with s_tickets as (
    select * from {{ ref('stg_zendesk__tickets') }}
    {% if is_incremental() %}
    where cast(created_at as date) > (select max(created_date) from {{ this }})
    {% endif %}
),

s_accounts as (
    select
        account_pk,
        account_name,
        csm_owner,
        segment
    from {{ ref('stg_salesforce__accounts') }}
),

-- SLA targets by priority (from dbt vars)
sla_targets as (
    select 'P1' as priority, {{ var('ops_p1_sla_hours', 4) }} as sla_hours
    union all select 'P2', {{ var('ops_p2_sla_hours', 24) }}
    union all select 'P3', {{ var('ops_p3_sla_hours', 72) }}
    union all select 'P4', {{ var('ops_p4_sla_hours', 168) }}
),

enriched as (
    select
        to_hex(sha256(cast(t.ticket_pk as bytes)))                  as ticket_pk,
        t.account_pk,
        cast(t.created_at as date)                                  as created_date,
        cast(t.resolved_at as date)                                 as resolved_date,
        t.priority,
        t.status,
        t.csat_score,
        -- Resolution time in hours
        timestamp_diff(t.resolved_at, t.created_at, minute) / 60.0 as resolution_hours,
        sl.sla_hours                                                as sla_target_hours,
        -- SLA compliance
        case
            when t.resolved_at is null then false  -- unresolved = SLA not met
            when timestamp_diff(t.resolved_at, t.created_at, minute) / 60.0
                <= sl.sla_hours then true
            else false
        end                                                         as is_within_sla,
        -- Stale: open ticket >7 days without resolution
        case
            when t.status not in ('solved', 'closed')
              and date_diff(current_date(), cast(t.created_at as date), day)
                > {{ var('ops_stale_ticket_days', 7) }}
            then true
            else false
        end                                                         as is_stale,
        a.csm_owner,
        a.segment,
        t.ticket_type                                               as ticket_category
    from s_tickets as t
    left join s_accounts as a
        on t.account_pk = a.account_pk
    left join sla_targets as sl
        on t.priority = sl.priority
),

final as (
    select * from enriched
)

select * from final
