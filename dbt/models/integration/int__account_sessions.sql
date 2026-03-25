-- int__account_sessions
-- Session-level records from Segment, linked to CoreFM accounts.

with s_segment_sessions as (
    select * from {{ ref('stg_segment__sessions') }}
),

s_corefm_users as (
    select * from {{ ref('stg_corefm__users') }}
),

sessions_with_account as (
    select
        to_hex(sha256(cast(s.session_id as bytes)))                           as session_pk,
        to_hex(sha256(cast(lower(trim(s.user_id)) as bytes)))                 as user_pk,
        u.account_pk,
        s.session_id,
        s.session_start_ts,
        s.session_end_ts,
        date(s.session_start_ts)                                              as session_date,
        timestamp_diff(s.session_end_ts, s.session_start_ts, second)         as duration_seconds,
        s.page_count,
        s.event_count
    from s_segment_sessions as s
    left join s_corefm_users as u
        on s.user_id = u.corefm_user_id
),

final as (
    select
        session_pk,
        user_pk,
        account_pk,
        session_start_ts,
        session_end_ts,
        session_date,
        duration_seconds,
        page_count,
        event_count
    from sessions_with_account
    where account_pk is not null
)

select * from final
