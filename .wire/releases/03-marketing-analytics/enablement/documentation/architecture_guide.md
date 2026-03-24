# Architecture Guide — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Version**: 1.0
**Date**: 2026-03-24
**Author**: Sophie Tanner, Rittman Analytics
**Audience**: Data team, analytics engineers, future developers

---

## 1. System Overview

The Marketing Analytics release (03-marketing-analytics) adds a multi-touch attribution layer on top of the data foundation established in Release 02. It connects marketing touchpoint data from HubSpot, Google Ads, LinkedIn, Meta, and Outreach to Salesforce opportunity outcomes, enabling revenue attribution across five models.

### What This Release Delivers

| Component | Description |
|-----------|-------------|
| 5 integration models | Cross-source contact and touchpoint unification |
| 6 warehouse models | Fact and dimension tables for marketing analytics |
| LookML semantic layer | 6 views, 3 explores for self-service analytics |
| 3 Looker dashboards | MA-01, MA-02, MA-03 for demand gen, attribution, pipeline |
| Cloud Composer extension | 2 new DAG phases for marketing models |

---

## 2. Data Flow

```
[HubSpot]  [Salesforce]  [Google Ads]  [LinkedIn]  [Meta]  [Outreach]
     ↓            ↓            ↓            ↓         ↓         ↓
     └────────────┴────────────┴────────────┴─────────┴─────────┘
                              Fivetran
                                ↓
                    core-dynamics-analytics-dev (BigQuery)
                    └── staging/  (02-data-foundation; not changed)
                                ↓
                    intermediate/  (NEW in this release)
                    ├── int__contacts__unified
                    ├── int__marketing_touches__all_channels
                    ├── int__campaign_spend__normalised
                    ├── int__funnel_events__staged
                    └── int__opportunities__attributed
                                ↓
                    mart_marketing/  (NEW in this release)
                    ├── fct_lead_funnel_events
                    ├── fct_campaign_spend
                    ├── fct_attribution_touches
                    ├── fct_opportunity_attribution
                    ├── dim_campaign
                    └── dim_contact
                                ↓
                    Looker (semantic layer + dashboards)
                    ├── MA-01 Demand Generation Performance
                    ├── MA-02 Multi-Touch Attribution Explore
                    └── MA-03 Pipeline Contribution
```

---

## 3. Data Sources

All source data is ingested by Fivetran connectors deployed in Release 02. This release adds no new connectors — it only transforms existing raw data.

| Source | BigQuery Dataset | Key Tables Used |
|--------|----------------|-----------------|
| HubSpot | `hubspot` | contacts, form_submissions, engagements, owners, lifecycle_stage_changes |
| Salesforce | `salesforce` | contacts, accounts, opportunities, opportunity_stage_history |
| Google Ads | `google_ads` | campaigns, ad_groups, ads, campaign_stats |
| LinkedIn Ads | `linkedin_ads` | campaigns, campaign_groups, creatives, ad_analytics |
| Meta Ads | `meta_ads` | campaigns, ad_sets, ads, insights |
| Outreach | `outreach` | prospects, sequences, sequence_steps, calls, meetings |
| Clearbit | `clearbit` | enrichment (joined on HubSpot contact) |

---

## 4. dbt Model Architecture

### Layer Structure

```
dbt/models/
├── staging/          (from 02-data-foundation — not modified)
│   ├── hubspot/
│   ├── salesforce/
│   ├── google_ads/
│   ├── linkedin_ads/
│   ├── meta_ads/
│   └── outreach/
├── integration/      (NEW — marketing-specific)
│   ├── int__contacts__unified.sql
│   ├── int__marketing_touches__all_channels.sql
│   ├── int__campaign_spend__normalised.sql
│   ├── int__funnel_events__staged.sql
│   └── int__opportunities__attributed.sql
└── warehouse/
    └── core/         (NEW — marketing warehouse models)
        ├── fct_lead_funnel_events.sql
        ├── fct_campaign_spend.sql
        ├── fct_attribution_touches.sql
        ├── fct_opportunity_attribution.sql
        ├── dim_campaign.sql
        └── dim_contact.sql
```

### Integration Layer Design

The integration layer resolves two key cross-system challenges:

**Contact deduplication (int__contacts__unified)**
HubSpot and Salesforce maintain separate contact records. This model joins them via:
1. SHA-256(email) exact match (primary method; ~88% of contacts)
2. Company domain fallback for contacts without email match
3. Unmatched contacts from each system are preserved as `LEFT JOIN` records
4. Match method recorded in `match_method` column for quality monitoring

**Touch unification (int__marketing_touches__all_channels)**
Creates a single canonical touch record per marketing interaction:
- HubSpot form fills → channel from `utm_channel_mapping` seed; asset from `form_asset_mapping` seed
- LinkedIn, Google Ads, Meta → ad impressions/clicks from ad platform staging models
- SDR Outreach touches → tagged as `channel = 'sdr'`; excluded from marketing attribution but included for context
- Unattributed touches (no UTM) → `channel = 'unattributed'`; included in attribution denominator

### Warehouse Layer Design

**fct_opportunity_attribution** — the core attribution table
- Grain: one row per opportunity × attribution model × marketing touch
- 5 attribution models stored as rows (not columns) — enables flexible model comparison
- Full table rebuild (not incremental) — attribution across all 5 models requires processing the complete touch history
- Attribution weights calculated from dbt vars: `u_shaped_first_touch_weight`, `u_shaped_lead_conversion_weight`, etc.
- Time-decay formula: `pow(0.5, days_before_opportunity / half_life)` normalised per opportunity

**fct_lead_funnel_events** — funnel progression tracking
- Grain: one row per contact per funnel stage transition
- Stages: subscriber → lead → mql → sal → sql → opportunity
- SAL is a Core Dynamics-specific stage (HubSpot lifecycle field); not standard HubSpot default

---

## 5. Attribution Logic

### The 180-Day Window

All attribution in this release uses a 180-day lookback window. Only marketing touches that occurred within 180 days before the opportunity creation date are considered. This was confirmed with Rachel Summers and reflects Core Dynamics' approximately 4-month average enterprise sales cycle.

### U-Shaped Weight Distribution

| Touch Type | Weight |
|-----------|--------|
| First touch | 40% |
| Lead conversion touch (closest to SAL date) | 40% |
| All middle touches | 20% split equally |

**Edge cases**:
- 1 touch: 100% to that touch
- 2 touches (no middle): 50% each
- First touch = lead conversion touch: 80% combined (40+40)

Weights are configurable via dbt project variables — see `dbt/dbt_project.yml`.

### Time-Decay Half-Life

Default: 30 days. A touch 30 days before opportunity creation receives half the weight of a touch on the day of opportunity creation. Configurable via `time_decay_half_life_days` dbt var.

---

## 6. PII and Security

### Email Pseudonymisation

No plain-text email addresses are stored in any warehouse model. All email references use SHA-256 hash:
```sql
{{ hash_email('email') }} as email_pseudonymised
```

The `dim_contact` table contains `email_pseudonymised` (64-character hex string). Plain-text email is never stored.

**Validation**: `assert_marketing_no_plain_text_email` Dataform assertion runs on every pipeline execution. If it fails, the pipeline alerts to `#data-platform-alerts` at CRITICAL severity.

**Looker**: The `email_pseudonymised` dimension is not exposed in the LookML views. End users cannot query email hashes.

---

## 7. Seed Files

| Seed | Path | Purpose | Owner |
|------|------|---------|-------|
| `attribution_models` | `dbt/seeds/attribution_models.csv` | Lists 5 models with default flag | Sophie Tanner |
| `utm_channel_mapping` | `dbt/seeds/utm_channel_mapping.csv` | Maps UTM source/medium → channel name | Marketing Ops |
| `funnel_stage_config` | `dbt/seeds/funnel_stage_config.csv` | Funnel stage ordering and display labels | Sophie Tanner |
| `meta_campaign_type_mapping` | `dbt/seeds/meta_campaign_type_mapping.csv` | Regex patterns to classify Meta ad sets | Owen Brady |
| `form_asset_mapping` | `dbt/seeds/form_asset_mapping.csv` | Maps HubSpot form IDs → content asset names | Niamh Collins |

**Important**: `form_asset_mapping.csv` contains placeholder form IDs as of Release 03. Niamh Collins must update this with real HubSpot form IDs before deployment. Until then, form-based touches will show `asset_category = 'unknown'`.

---

## 8. Technology Stack

| Component | Technology | Version / Details |
|-----------|-----------|------------------|
| Data warehouse | Google BigQuery | Project: core-dynamics-analytics-prod |
| Data ingestion | Fivetran | Deployed in 02-data-foundation |
| Transformation | dbt Core | 1.7+; project: core_dynamics_analytics |
| Orchestration | Cloud Composer / Apache Airflow | DAG: dataform_run_dag.py |
| Assertions | Dataform | Tags: data_quality_marketing |
| BI layer | Looker | Project: core_dynamics; model: marketing |

---

## 9. Design Decisions

| Decision | Choice Made | Rationale |
|----------|------------|-----------|
| Attribution model storage | 5 models as rows, not columns | Enables dynamic model switching in Looker without schema changes |
| fct_opportunity_attribution materialization | Full table (not incremental) | Attribution requires reprocessing all historical data when weights change |
| Attribution window | 180 days | Confirmed with Rachel Summers; reflects ~4-month enterprise sales cycle |
| U-shaped lead conversion event | SAL date | Agreed with Rachel Summers as the marketing-to-sales handoff event |
| Email storage | SHA-256 hash only | GDPR/CCPA compliance; no consent framework for analytics email storage |
| Outreach touches | Excluded from marketing attribution | SDR activities are sales motions, not marketing; tracked separately as context |
| Unattributed touches | Included as `channel='unattributed'` | Dropping them would inflate channel metrics; surface in data quality tile |
