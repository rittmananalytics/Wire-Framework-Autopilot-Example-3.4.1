# dbt Models Summary
## Release: 03-marketing-analytics

**Generated**: 2026-03-24
**dbt project**: dbt/ (repository root)

## Model Counts

| Layer | Count | Location |
|-------|-------|----------|
| Staging (sources only — no new models, using 02-data-foundation) | 17 source refs | dbt/models/staging/ |
| Integration (intermediate) | 5 models | dbt/models/integration/ |
| Warehouse | 6 models | dbt/models/warehouse/core/ |
| **Total new models** | **11** | |

## Staging Layer (Source References Only)

All staging models were created in 02-data-foundation. This release adds source YAML definitions in sub-folders to provide freshness checks and documentation context.

| Source | Staging Models Referenced |
|--------|--------------------------|
| Salesforce | stg_salesforce__contacts, stg_salesforce__accounts, stg_salesforce__opportunities, stg_salesforce__campaigns |
| HubSpot | stg_hubspot__contacts, stg_hubspot__form_submissions, stg_hubspot__email_sends, stg_hubspot__page_views |
| Google Ads | stg_google_ads__campaigns, stg_google_ads__ad_groups |
| LinkedIn Ads | stg_linkedin_ads__campaigns, stg_linkedin_ads__creatives |
| Meta Ads | stg_meta_ads__campaigns, stg_meta_ads__ad_sets |
| Outreach | stg_outreach__mailings, stg_outreach__calls |
| Clearbit (raw_hubspot) | clearbit_enrichment |

## Integration Layer

| Model | Materialisation | Tags | Description |
|-------|----------------|------|-------------|
| int__contacts__unified | view | intermediate_marketing | HubSpot + Salesforce unified with fuzzy match + Clearbit enrichment |
| int__marketing_touches__all_channels | view | intermediate_marketing | All touch events from HubSpot + Outreach, normalised with channel assignment |
| int__campaign_spend__normalised | view | intermediate_marketing | Ad spend from 3 platforms at campaign/ad-group level |
| int__funnel_events__staged | view | intermediate_marketing | HubSpot lifecycle stage transitions with timestamps |
| int__opportunities__attributed | view | intermediate_marketing | Opportunities × touches within 180-day window, with attribution helper flags |

## Warehouse Layer

| Model | Materialisation | Tags | Grain |
|-------|----------------|------|-------|
| fct_lead_funnel_events | incremental (merge) | warehouse_marketing | contact × stage transition |
| fct_campaign_spend | incremental (merge) | warehouse_marketing | platform × campaign × ad_group × date |
| fct_attribution_touches | incremental (merge) | warehouse_marketing | contact × touch event |
| fct_opportunity_attribution | table (full rebuild) | warehouse_marketing | opportunity × touch × attribution_model |
| dim_campaign | table (full rebuild) | warehouse_marketing | campaign (per source system) |
| dim_contact | table (full rebuild) | warehouse_marketing | contact |

## Seeds

| Seed | Description | Rows |
|------|-------------|------|
| attribution_models | Reference table for 5 attribution models | 5 |
| utm_channel_mapping | UTM source/medium → channel mapping rules | 24 |
| funnel_stage_config | Funnel stage order and display names | 6 |
| meta_campaign_type_mapping | Meta ad set name patterns → campaign_type | 7 |
| form_asset_mapping | HubSpot form ID → asset name + category (placeholder; to be updated by Niamh Collins) | 7 |

## Custom Tests

| Test | Location | Purpose |
|------|----------|---------|
| assert_attribution_weights_sum_to_one | tests/generic/ | Validates sum(touch_weight) = 1.0 per opp per model |
| assert_email_is_hashed | tests/generic/ | Validates email_pseudonymised is SHA-256 hex (64 chars), not plain text |

## Custom Macros

| Macro | File | Purpose |
|-------|------|---------|
| hash_email(email_field) | macros/marketing_utils.sql | SHA-256 hash of lowercased, trimmed email |
| extract_domain(email_field) | macros/marketing_utils.sql | Extract domain from email for fuzzy matching |
| majority_stage(stage_col, partition_col) | macros/marketing_utils.sql | Mode calculation for majority_pipeline_stage in MA-01 |

## Test Coverage Summary

| Category | Count |
|----------|-------|
| not_null tests | 18 |
| unique tests | 11 |
| accepted_values tests | 10 |
| relationships tests | 7 |
| expression_is_true tests | 4 |
| custom (generic) tests | 2 |
| **Total** | **52** |

## dbt Variables (dbt_project.yml)

| Variable | Default | Description |
|----------|---------|-------------|
| marketing_attribution_window_days | 180 | Attribution influence window in days |
| u_shaped_first_touch_weight | 0.40 | U-shaped: first touch weight |
| u_shaped_lead_conversion_weight | 0.40 | U-shaped: lead conversion touch weight |
| u_shaped_middle_weight | 0.20 | U-shaped: remaining weight for middle touches |
| time_decay_half_life_days | 30 | Time-decay half-life in days |
