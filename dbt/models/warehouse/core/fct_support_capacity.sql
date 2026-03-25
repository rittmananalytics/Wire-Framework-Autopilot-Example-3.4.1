{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_operations']
    )
}}

/*
fct_support_capacity
--------------------
Monthly support capacity metrics per CSM — ticket volumes, CSAT,
SLA compliance, and account count for capacity planning.

Grain: csm_owner × month_start (one row per CSM per month)
Full refresh daily.
*/

with s_tickets as (
    select * from {{ ref('fct_support_tickets') }}
    where created_date >= date_sub(
        date_trunc(current_date(), month),
        interval 12 month
    )
),

s_accounts as (
    select
        csm_owner,
        count(distinct account_pk)  as account_count
    from {{ ref('stg_salesforce__accounts') }}
    where is_active = true
    group by 1
),

-- Month spine: 12 months
month_spine as (
    select
        date_trunc(
            date_sub(current_date(), interval n month),
            month
        ) as month_start
    from unnest(generate_array(0, 11)) as n
),

-- All CSMs × months
csm_months as (
    select distinct
        a.csm_owner,
        m.month_start
    from s_accounts as a
    cross join month_spine as m
),

-- Ticket metrics per CSM per month
ticket_metrics as (
    select
        csm_owner,
        date_trunc(created_date, month)             as month_start,
        countif(created_date >= date_trunc(created_date, month)
            and created_date < date_add(date_trunc(created_date, month), interval 1 month))
                                                    as tickets_opened,
        countif(resolved_date is not null
            and date_trunc(resolved_date, month) = date_trunc(created_date, month))
                                                    as tickets_resolved,
        countif(status not in ('solved', 'closed')
            and date_trunc(created_date, month) <= date_trunc(current_date(), month))
                                                    as tickets_open_eom,
        avg(case when resolution_hours is not null then resolution_hours end)
                                                    as avg_resolution_hours,
        avg(csat_score)                             as avg_csat,
        safe_divide(
            countif(is_within_sla = true),
            countif(resolved_date is not null)
        ) * 100                                     as sla_compliance_pct
    from s_tickets
    group by 1, 2
),

assembled as (
    select
        to_hex(sha256(cast(cm.csm_owner as bytes)
            || cast(cm.month_start as string)))     as capacity_pk,
        cm.csm_owner,
        cm.month_start,
        coalesce(tm.tickets_opened, 0)              as tickets_opened,
        coalesce(tm.tickets_resolved, 0)            as tickets_resolved,
        coalesce(tm.tickets_open_eom, 0)            as tickets_open_eom,
        tm.avg_resolution_hours,
        tm.avg_csat,
        coalesce(tm.sla_compliance_pct, 100.0)      as sla_compliance_pct,
        coalesce(a.account_count, 0)                as account_count,
        safe_divide(
            coalesce(tm.tickets_opened, 0),
            coalesce(a.account_count, 1)
        )                                           as tickets_per_account
    from csm_months as cm
    left join ticket_metrics as tm
        on cm.csm_owner = tm.csm_owner
        and cm.month_start = tm.month_start
    left join s_accounts as a
        on cm.csm_owner = a.csm_owner
),

final as (
    select * from assembled
)

select * from final
