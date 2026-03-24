{{
    config(
        materialized='table',
        cluster_by=['channel'],
        tags=['warehouse', 'warehouse_marketing']
    )
}}

with s_salesforce_campaigns as (
    select * from {{ source('staging', 'stg_salesforce__campaigns') }}
),

s_google_campaigns as (
    select * from {{ source('staging', 'stg_google_ads__campaigns') }}
),

s_linkedin_campaigns as (
    select * from {{ source('staging', 'stg_linkedin_ads__campaigns') }}
),

s_meta_campaigns as (
    select * from {{ source('staging', 'stg_meta_ads__campaigns') }}
),

-- Salesforce campaigns
sf_campaigns as (
    select
        {{ dbt_utils.generate_surrogate_key(["'salesforce'", 'campaign_pk']) }} as campaign_pk,
        'salesforce' as source_system,
        campaign_pk as source_campaign_id,
        campaign_name,
        campaign_type as channel,
        campaign_type,
        target_segment,
        start_date,
        end_date,
        budget_usd as total_budget_usd,
        is_active,
        'salesforce' as platform
    from s_salesforce_campaigns
),

-- Google Ads campaigns
google_campaigns as (
    select
        {{ dbt_utils.generate_surrogate_key(["'google_ads'", 'campaign_id']) }} as campaign_pk,
        'google_ads' as source_system,
        campaign_id as source_campaign_id,
        campaign_name,
        'paid_search' as channel,
        'paid_search' as campaign_type,
        null as target_segment,
        start_date,
        end_date,
        null as total_budget_usd,
        is_active,
        'google_ads' as platform
    from s_google_campaigns
),

-- LinkedIn Ads campaigns
linkedin_campaigns as (
    select
        {{ dbt_utils.generate_surrogate_key(["'linkedin_ads'", 'campaign_id']) }} as campaign_pk,
        'linkedin_ads' as source_system,
        campaign_id as source_campaign_id,
        campaign_name,
        'paid_social' as channel,
        'paid_social' as campaign_type,
        null as target_segment,
        start_date,
        end_date,
        null as total_budget_usd,
        is_active,
        'linkedin_ads' as platform
    from s_linkedin_campaigns
),

-- Meta Ads campaigns
meta_campaigns as (
    select
        {{ dbt_utils.generate_surrogate_key(["'meta_ads'", 'campaign_id']) }} as campaign_pk,
        'meta_ads' as source_system,
        campaign_id as source_campaign_id,
        campaign_name,
        'paid_social' as channel,
        'paid_social' as campaign_type,
        null as target_segment,
        start_date,
        end_date,
        null as total_budget_usd,
        is_active,
        'meta_ads' as platform
    from s_meta_campaigns
),

-- Union all campaign sources
all_campaigns as (
    select * from sf_campaigns
    union all
    select * from google_campaigns
    union all
    select * from linkedin_campaigns
    union all
    select * from meta_campaigns
),

final as (
    select
        campaign_pk,
        source_system,
        source_campaign_id,
        campaign_name,
        channel,
        campaign_type,
        target_segment,
        start_date,
        end_date,
        total_budget_usd,
        is_active,
        platform,
        current_timestamp() as _loaded_at
    from all_campaigns
)

select * from final
