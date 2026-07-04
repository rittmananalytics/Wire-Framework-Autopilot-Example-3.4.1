{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_marketing']
    )
}}

with s_google_campaigns as (
    select * from {{ source('staging', 'stg_google_ads__campaigns') }}
),

s_google_ad_groups as (
    select * from {{ source('staging', 'stg_google_ads__ad_groups') }}
),

s_linkedin_campaigns as (
    select * from {{ source('staging', 'stg_linkedin_ads__campaigns') }}
),

s_linkedin_creatives as (
    select * from {{ source('staging', 'stg_linkedin_ads__creatives') }}
),

s_meta_campaigns as (
    select * from {{ source('staging', 'stg_meta_ads__campaigns') }}
),

s_meta_ad_sets as (
    select * from {{ source('staging', 'stg_meta_ads__ad_sets') }}
),

s_campaign_type_map as (
    select * from {{ ref('meta_campaign_type_mapping') }}
),

-- Google Ads: ad group level, campaign_type = paid_search by definition
google_spend as (
    select
        {{ dbt_utils.generate_surrogate_key(["'google_ads'", 'ag.campaign_id', 'ag.ad_group_id', 'ag.spend_date']) }} as spend_pk,
        ag.spend_date,
        'google_ads' as platform,
        ag.campaign_id,
        c.campaign_name,
        ag.ad_group_id,
        ag.ad_group_name,
        ag.impressions,
        ag.clicks,
        ag.spend_usd,
        safe_divide(ag.clicks, nullif(ag.impressions, 0)) as ctr,
        safe_divide(ag.spend_usd, nullif(ag.clicks, 0)) as cpc,
        'paid_search' as campaign_type_derived
    from s_google_ad_groups ag
    inner join s_google_campaigns c on ag.campaign_id = c.campaign_id
),

-- LinkedIn Ads: creative level maps to campaign via campaign_group_id
linkedin_spend as (
    select
        {{ dbt_utils.generate_surrogate_key(["'linkedin_ads'", 'cr.campaign_id', 'cr.creative_id', 'cr.spend_date']) }} as spend_pk,
        cr.spend_date,
        'linkedin_ads' as platform,
        cr.campaign_id,
        c.campaign_name,
        cr.creative_id as ad_group_id,
        cr.creative_name as ad_group_name,
        cr.impressions,
        cr.clicks,
        cr.spend_usd,
        safe_divide(cr.clicks, nullif(cr.impressions, 0)) as ctr,
        safe_divide(cr.spend_usd, nullif(cr.clicks, 0)) as cpc,
        'paid_social' as campaign_type_derived
    from s_linkedin_creatives cr
    inner join s_linkedin_campaigns c on cr.campaign_id = c.campaign_id
),

-- Meta Ads: ad set level; campaign_type derived from naming convention
meta_spend as (
    select
        {{ dbt_utils.generate_surrogate_key(["'meta_ads'", 'ads.campaign_id', 'ads.ad_set_id', 'ads.spend_date']) }} as spend_pk,
        ads.spend_date,
        'meta_ads' as platform,
        ads.campaign_id,
        c.campaign_name,
        ads.ad_set_id as ad_group_id,
        ads.ad_set_name as ad_group_name,
        ads.impressions,
        ads.clicks,
        ads.spend_usd,
        safe_divide(ads.clicks, nullif(ads.impressions, 0)) as ctr,
        safe_divide(ads.spend_usd, nullif(ads.clicks, 0)) as cpc,
        coalesce(cm.campaign_type, 'paid_social') as campaign_type_derived
    from s_meta_ad_sets ads
    inner join s_meta_campaigns c on ads.campaign_id = c.campaign_id
    left join s_campaign_type_map cm
        on regexp_contains(lower(ads.ad_set_name), lower(cm.ad_set_pattern))
),

final as (
    select * from google_spend
    union all
    select * from linkedin_spend
    union all
    select * from meta_spend
)

select * from final
