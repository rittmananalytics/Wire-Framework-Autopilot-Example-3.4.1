-- int__feature_usage
-- Unified feature events from Segment (transactional) and Mixpanel (discovery).
-- Segment is authoritative for transactional events; Mixpanel for discovery events.
-- Deduplication: on (user_pk, event_name, event_timestamp_utc) — Segment wins on conflict.

with s_segment_tracks as (
    select * from {{ ref('stg_segment__tracks') }}
),

s_mixpanel_events as (
    select * from {{ ref('stg_mixpanel__events') }}
),

s_corefm_users as (
    select * from {{ ref('stg_corefm__users') }}
),

s_feature_taxonomy as (
    select * from {{ ref('feature_taxonomy') }}
),

-- Segment transactional events (authoritative for overlapping event types)
segment_events as (
    select
        to_hex(sha256(cast('segment' as bytes) || cast(t.event_id as bytes))) as event_pk,
        to_hex(sha256(cast(lower(trim(t.user_id)) as bytes)))                as user_pk,
        u.account_pk,
        coalesce(ft.feature_id, 'feat_999')                                  as feature_id,
        coalesce(ft.feature_name, 'Unmapped Event')                          as feature_name,
        coalesce(ft.feature_group_id, 'fg_999')                              as feature_group_id,
        coalesce(ft.feature_group_name, 'Unmapped')                          as feature_group_name,
        coalesce(ft.module_id, 'mod_999')                                    as module_id,
        coalesce(ft.module_name, 'Other')                                    as module_name,
        t.event_name,
        t.event_timestamp_utc,
        date(t.event_timestamp_utc)                                          as event_date,
        'segment'                                                            as source_system,
        t.session_id
    from s_segment_tracks as t
    left join s_corefm_users as u
        on t.user_id = u.corefm_user_id
    left join s_feature_taxonomy as ft
        on t.event_name = ft.event_name
        and ft.source_system_authoritative = 'segment'
    where t.event_name in (
        select event_name from s_feature_taxonomy where source_system_authoritative = 'segment'
    )
),

-- Mixpanel discovery and workflow events (authoritative for non-Segment events)
mixpanel_events as (
    select
        to_hex(sha256(cast('mixpanel' as bytes) || cast(e.event_id as bytes))) as event_pk,
        to_hex(sha256(cast(lower(trim(e.distinct_id)) as bytes)))              as user_pk,
        u.account_pk,
        coalesce(ft.feature_id, 'feat_999')                                    as feature_id,
        coalesce(ft.feature_name, 'Unmapped Event')                            as feature_name,
        coalesce(ft.feature_group_id, 'fg_999')                                as feature_group_id,
        coalesce(ft.feature_group_name, 'Unmapped')                            as feature_group_name,
        coalesce(ft.module_id, 'mod_999')                                      as module_id,
        coalesce(ft.module_name, 'Other')                                      as module_name,
        e.event_name,
        e.event_timestamp_utc,
        date(e.event_timestamp_utc)                                            as event_date,
        'mixpanel'                                                             as source_system,
        cast(null as string)                                                   as session_id
    from s_mixpanel_events as e
    left join s_corefm_users as u
        on e.distinct_id = u.corefm_user_id
    left join s_feature_taxonomy as ft
        on e.event_name = ft.event_name
        and ft.source_system_authoritative = 'mixpanel'
    where e.event_name in (
        select event_name from s_feature_taxonomy where source_system_authoritative = 'mixpanel'
    )
),

combined as (
    select * from segment_events
    union all
    select * from mixpanel_events
),

-- Deduplicate: keep Segment record where both sources fired the same event
deduplicated as (
    select *
    from combined
    qualify row_number() over (
        partition by user_pk, event_name, event_timestamp_utc
        order by case source_system when 'segment' then 1 else 2 end
    ) = 1
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
        event_timestamp_utc,
        event_date,
        source_system,
        session_id
    from deduplicated
    where account_pk is not null  -- exclude users without a matching CoreFM account
)

select * from final
