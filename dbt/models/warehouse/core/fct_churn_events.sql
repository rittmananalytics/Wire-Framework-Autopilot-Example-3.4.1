{{
    config(
        materialized='incremental',
        unique_key='churn_event_pk',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_pk'],
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
fct_churn_events
----------------
Churn and contraction events from Salesforce (closed-lost renewals) and
ChurnZero (churn events). Salesforce takes priority where both fire for
the same account on the same date.

Grain: churn_event_pk (one row per discrete churn/contraction event)
Incremental: append new events by event_date
*/

with s_sf_churn as (
    select * from {{ ref('stg_salesforce__churn_events') }}
    {% if is_incremental() %}
    where event_date > (select max(event_date) from {{ this }})
    {% endif %}
),

s_cz_churn as (
    select * from {{ ref('stg_churnzero__churn_events') }}
    {% if is_incremental() %}
    where event_date > (select max(event_date) from {{ this }})
    {% endif %}
),

-- Salesforce churn events (authoritative)
sf_events as (
    select
        to_hex(sha256(cast('salesforce' as bytes)
            || cast(source_event_id as bytes)))                     as churn_event_pk,
        account_pk,
        event_date,
        churn_type,
        arr_impacted,
        reason_category,
        reason_detail,
        csm_owner,
        'salesforce'                                                as source_system,
        source_event_id
    from s_sf_churn
),

-- ChurnZero events — deduped against Salesforce (exclude if SF already has same account+month)
cz_events_deduped as (
    select
        to_hex(sha256(cast('churnzero' as bytes)
            || cast(cz.source_event_id as bytes)))                  as churn_event_pk,
        cz.account_pk,
        cz.event_date,
        cz.churn_type,
        cz.arr_impacted,
        cz.reason_category,
        cz.reason_detail,
        cz.csm_owner,
        'churnzero'                                                 as source_system,
        cz.source_event_id
    from s_cz_churn as cz
    where not exists (
        select 1
        from sf_events as sf
        where sf.account_pk = cz.account_pk
          and date_trunc(sf.event_date, month) = date_trunc(cz.event_date, month)
    )
),

unioned as (
    select * from sf_events
    union all
    select * from cz_events_deduped
),

final as (
    select * from unioned
)

select * from final
