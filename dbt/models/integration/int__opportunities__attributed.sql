{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_marketing']
    )
}}

with s_opportunities as (
    select * from {{ source('staging', 'stg_salesforce__opportunities') }}
),

s_contacts_unified as (
    select
        contact_pk,
        salesforce_contact_id,
        is_sal,
        sal_date,
        is_mql,
        mql_date
    from {{ ref('int__contacts__unified') }}
),

s_touches as (
    select
        touch_pk,
        contact_pk,
        touch_ts,
        touch_date,
        touch_type,
        channel,
        source_system,
        campaign_id
    from {{ ref('int__marketing_touches__all_channels') }}
),

-- Join opportunities to their primary contacts
opportunity_contacts as (
    select
        o.opportunity_pk,
        o.created_date as opportunity_created_date,
        o.close_date as opportunity_close_date,
        o.arr as opportunity_arr_usd,
        o.pipeline_value as opportunity_pipeline_usd,
        o.stage = 'Closed Won' as is_closed_won,
        c.contact_pk,
        c.sal_date,
        c.mql_date
    from s_opportunities o
    inner join s_contacts_unified c
        on o.primary_contact_id = c.salesforce_contact_id
),

-- All touches within the 180-day influence window for each opportunity
touches_in_window as (
    select
        oc.opportunity_pk,
        oc.opportunity_created_date,
        oc.opportunity_close_date,
        oc.opportunity_arr_usd,
        oc.opportunity_pipeline_usd,
        oc.is_closed_won,
        oc.sal_date,
        oc.mql_date,
        t.touch_pk,
        t.contact_pk,
        t.touch_ts,
        t.touch_date,
        t.channel,
        t.source_system,
        t.campaign_id,
        date_diff(date(oc.opportunity_created_date), t.touch_date, day) as days_before_opportunity
    from opportunity_contacts oc
    inner join s_touches t
        on oc.contact_pk = t.contact_pk
        and t.touch_date <= date(oc.opportunity_created_date)
        and t.touch_date >= date_sub(date(oc.opportunity_created_date), interval {{ var('marketing_attribution_window_days') }} day)
),

-- Add ranking and attribution helper flags
ranked_touches as (
    select
        *,
        row_number() over (
            partition by opportunity_pk
            order by touch_ts asc
        ) as touch_rank_asc,
        row_number() over (
            partition by opportunity_pk
            order by touch_ts desc
        ) as touch_rank_desc,
        count(*) over (partition by opportunity_pk) as total_touches_in_window
    from touches_in_window
),

-- Identify the lead conversion touch (closest touch to SAL date; fallback MQL)
lead_conversion_candidates as (
    select
        opportunity_pk,
        touch_pk,
        case
            when sal_date is not null
            then abs(date_diff(touch_date, sal_date, day))
            else abs(date_diff(touch_date, mql_date, day))
        end as days_from_conversion_event,
        row_number() over (
            partition by opportunity_pk
            order by
                case
                    when sal_date is not null
                    then abs(date_diff(touch_date, sal_date, day))
                    else abs(date_diff(touch_date, mql_date, day))
                end asc
        ) as conversion_rank
    from ranked_touches
),

lead_conversion_touch as (
    select opportunity_pk, touch_pk as lead_conversion_touch_pk
    from lead_conversion_candidates
    where conversion_rank = 1
),

-- Marketing-sourced/influenced flags per opportunity
opportunity_flags as (
    select
        opportunity_pk,
        countif(channel not in ('sdr')) > 0 as is_marketing_influenced,
        -- sourced = first touch is a marketing (non-SDR) channel
        max(case when touch_rank_asc = 1 and channel not in ('sdr') then true else false end) as is_marketing_sourced
    from ranked_touches
    group by 1
),

final as (
    select
        rt.opportunity_pk,
        rt.touch_pk,
        rt.contact_pk,
        rt.opportunity_created_date,
        rt.opportunity_close_date,
        rt.opportunity_arr_usd,
        rt.opportunity_pipeline_usd,
        rt.is_closed_won,
        rt.touch_ts,
        rt.touch_date,
        rt.days_before_opportunity,
        rt.channel,
        rt.source_system,
        rt.campaign_id,
        rt.touch_rank_asc,
        rt.touch_rank_desc,
        rt.total_touches_in_window,
        rt.touch_rank_asc = 1 as is_first_touch,
        rt.touch_rank_desc = 1 as is_last_touch,
        lct.lead_conversion_touch_pk = rt.touch_pk as is_lead_conversion_touch,
        rt.touch_rank_asc > 1
            and rt.touch_rank_desc > 1
            and (lct.lead_conversion_touch_pk != rt.touch_pk or lct.lead_conversion_touch_pk is null)
            as is_middle_touch,
        of.is_marketing_sourced,
        of.is_marketing_influenced
    from ranked_touches rt
    left join lead_conversion_touch lct on rt.opportunity_pk = lct.opportunity_pk
    inner join opportunity_flags of on rt.opportunity_pk = of.opportunity_pk
)

select * from final
