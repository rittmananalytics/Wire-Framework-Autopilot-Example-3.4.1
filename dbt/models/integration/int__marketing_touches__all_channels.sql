{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_marketing']
    )
}}

with s_form_submissions as (
    select * from {{ source('staging', 'stg_hubspot__form_submissions') }}
),

s_email_sends as (
    select * from {{ source('staging', 'stg_hubspot__email_sends') }}
),

s_page_views as (
    select * from {{ source('staging', 'stg_hubspot__page_views') }}
),

s_outreach_mailings as (
    select * from {{ source('staging', 'stg_outreach__mailings') }}
),

s_outreach_calls as (
    select * from {{ source('staging', 'stg_outreach__calls') }}
),

s_contacts as (
    select contact_pk, email_hash from {{ ref('int__contacts__unified') }}
),

-- UTM to channel mapping from seed
s_channel_map as (
    select * from {{ ref('utm_channel_mapping') }}
),

-- HubSpot form submissions
form_touches as (
    select
        {{ dbt_utils.generate_surrogate_key(['contact_fk', 'submitted_at', "'form_submit'", "'hubspot'"]) }} as touch_pk,
        contact_fk as contact_pk,
        submitted_at as touch_ts,
        date(submitted_at) as touch_date,
        'form_submit' as touch_type,
        utm_source,
        utm_medium,
        utm_campaign,
        form_id as asset_id,
        campaign_id,
        campaign_name,
        'hubspot' as source_system
    from s_form_submissions
),

-- HubSpot email engagements (opens and clicks)
email_touches as (
    select
        {{ dbt_utils.generate_surrogate_key(['contact_fk', 'engaged_at', 'engagement_type', "'hubspot'"]) }} as touch_pk,
        contact_fk as contact_pk,
        engaged_at as touch_ts,
        date(engaged_at) as touch_date,
        case
            when engagement_type = 'OPEN' then 'email_open'
            when engagement_type = 'CLICK' then 'email_click'
        end as touch_type,
        null as utm_source,
        null as utm_medium,
        null as utm_campaign,
        email_id as asset_id,
        campaign_id,
        campaign_name,
        'hubspot' as source_system
    from s_email_sends
    where engagement_type in ('OPEN', 'CLICK')
),

-- HubSpot page views
page_view_touches as (
    select
        {{ dbt_utils.generate_surrogate_key(['contact_fk', 'viewed_at', "'page_view'", "'hubspot'"]) }} as touch_pk,
        contact_fk as contact_pk,
        viewed_at as touch_ts,
        date(viewed_at) as touch_date,
        'page_view' as touch_type,
        utm_source,
        utm_medium,
        utm_campaign,
        page_url as asset_id,
        campaign_id,
        campaign_name,
        'hubspot' as source_system
    from s_page_views
),

-- Outreach email touches
outreach_email_touches as (
    select
        {{ dbt_utils.generate_surrogate_key(['prospect_email_hash', 'sent_at', "'outreach_email'", "'outreach'"]) }} as touch_pk,
        c.contact_pk,
        m.sent_at as touch_ts,
        date(m.sent_at) as touch_date,
        'outreach_email' as touch_type,
        null as utm_source,
        null as utm_medium,
        null as utm_campaign,
        m.sequence_id as asset_id,
        null as campaign_id,
        null as campaign_name,
        'outreach' as source_system
    from s_outreach_mailings m
    left join s_contacts c
        on m.prospect_email_hash = c.email_hash
),

-- Outreach call touches
outreach_call_touches as (
    select
        {{ dbt_utils.generate_surrogate_key(['prospect_email_hash', 'called_at', "'outreach_call'", "'outreach'"]) }} as touch_pk,
        c.contact_pk,
        oc.called_at as touch_ts,
        date(oc.called_at) as touch_date,
        'outreach_call' as touch_type,
        null as utm_source,
        null as utm_medium,
        null as utm_campaign,
        oc.sequence_id as asset_id,
        null as campaign_id,
        null as campaign_name,
        'outreach' as source_system
    from s_outreach_calls oc
    left join s_contacts c
        on oc.prospect_email_hash = c.email_hash
),

-- Union all touch types
all_raw_touches as (
    select * from form_touches
    union all
    select * from email_touches
    union all
    select * from page_view_touches
    union all
    select * from outreach_email_touches
    union all
    select * from outreach_call_touches
),

-- Assign channel from UTM mapping or source system
final as (
    select
        t.touch_pk,
        t.contact_pk,
        t.touch_ts,
        t.touch_date,
        t.touch_type,

        -- channel assignment
        case
            when t.source_system = 'outreach' then 'sdr'
            when t.touch_type = 'email_open' or t.touch_type = 'email_click' then 'email'
            when t.utm_source is null and t.utm_medium is null then 'unattributed'
            else coalesce(cm.channel, 'unattributed')
        end as channel,

        t.source_system,
        t.campaign_id,
        t.campaign_name,
        t.asset_id,
        null as asset_category,  -- populated later via seed join in warehouse layer
        t.utm_source,
        t.utm_medium,
        t.utm_campaign,
        case
            when t.source_system = 'outreach' then false
            when t.utm_source is null and t.utm_medium is null and t.touch_type not in ('email_open', 'email_click') then false
            else true
        end as is_attributed

    from all_raw_touches t
    left join s_channel_map cm
        on lower(t.utm_source) = lower(cm.utm_source)
        and lower(t.utm_medium) = lower(cm.utm_medium)
    where t.contact_pk is not null  -- exclude touches without a matched contact
)

select * from final
