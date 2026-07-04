{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_marketing']
    )
}}

with s_hubspot_contacts as (
    select * from {{ source('staging', 'stg_hubspot__contacts') }}
),

s_contacts_unified as (
    select contact_pk, account_fk from {{ ref('int__contacts__unified') }}
),

s_funnel_stage_config as (
    select * from {{ ref('funnel_stage_config') }}
),

-- Unpivot HubSpot lifecycle stage timestamps into one row per stage per contact
-- HubSpot native fields used where available; nulls are expected for stages not reached
contact_stages as (
    select
        h.contact_pk,
        cu.account_fk,
        stage_def.stage_name,
        stage_def.stage_order,

        -- stage entry timestamp (native HubSpot fields)
        case stage_def.stage_name
            when 'subscriber'  then h.became_subscriber_date
            when 'lead'        then h.became_lead_date
            when 'mql'         then h.became_mql_date
            when 'sal'         then coalesce(h.became_sal_date, h.hs_became_sal_date)
            when 'sql'         then h.became_sql_date
        end as stage_entered_ts,

        -- next stage entry (for calculating stage_exited_ts)
        case stage_def.stage_name
            when 'subscriber'  then h.became_lead_date
            when 'lead'        then h.became_mql_date
            when 'mql'         then coalesce(h.became_sal_date, h.hs_became_sal_date)
            when 'sal'         then h.became_sql_date
            when 'sql'         then null  -- exits when opportunity is created in Salesforce
        end as stage_exited_ts,

        h.hubspot_lifecycle_stage as current_lifecycle_stage

    from s_hubspot_contacts h
    cross join (
        select stage_name, stage_order
        from s_funnel_stage_config
        where stage_name in ('subscriber', 'lead', 'mql', 'sal', 'sql')
    ) stage_def
    inner join s_contacts_unified cu on h.contact_pk = cu.contact_pk
),

-- Only include stages the contact has actually reached
stages_reached as (
    select
        {{ dbt_utils.generate_surrogate_key(['contact_pk', 'stage_name']) }} as funnel_event_pk,
        contact_pk,
        account_fk,
        stage_name,
        stage_order,
        stage_entered_ts,
        stage_exited_ts,
        case
            when stage_exited_ts is not null
            then date_diff(date(stage_exited_ts), date(stage_entered_ts), day)
        end as days_in_stage,
        case
            when stage_exited_ts is not null then true
            else false
        end as is_converted,
        stage_name = current_lifecycle_stage as is_current_stage
    from contact_stages
    where stage_entered_ts is not null
),

final as (
    select
        funnel_event_pk,
        contact_pk,
        account_fk,
        stage_name,
        stage_order,
        stage_entered_ts,
        stage_exited_ts,
        days_in_stage,
        is_converted,
        is_current_stage,
        -- channel and campaign to be joined from touches at warehouse layer
        null as channel,
        null as campaign_id
    from stages_reached
)

select * from final
