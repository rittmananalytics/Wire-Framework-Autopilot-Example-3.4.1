# Architecture Guide — Product Analytics
## Release: 04-product-analytics

**Date**: 2026-03-25 | **Author**: Sophie Tanner, Rittman Analytics

---

## Overview

Release 04 adds product usage analytics on top of the data foundation. It integrates event data from Segment (server-side), Mixpanel (client-side), Intercom (onboarding/NPS), and CoreFM's own PostgreSQL database to produce a monthly Product Engagement Score per account and three Looker dashboards for product and CS teams.

**Key design principle**: Segment is authoritative for transactional events (work orders, assets); Mixpanel for discovery and workflow events. Where both fire for the same action, Segment wins. No double-counting.

---

## Data Flow

```
CoreFM PostgreSQL (CDC 15-min) → raw_corefm_db → stg_corefm__*
Segment (streaming)            → segment_events  → stg_segment__*
Mixpanel (daily)               → mixpanel         → stg_mixpanel__*
Intercom (6-hourly)            → intercom         → stg_intercom__*
Salesforce (6-hourly)          → salesforce        → stg_salesforce__*
              ↓
Integration Layer (intermediate_product tag):
  int__feature_usage         — deduped events + feature taxonomy
  int__account_sessions      — session records linked to accounts
  int__onboarding            — onboarding step completions per account
              ↓
Warehouse Layer (warehouse_product tag, mart_product dataset):
  fct_feature_usage          — incremental, partitioned by event_date
  fct_session_events         — incremental, partitioned by session_date
  fct_onboarding_funnel      — full table, all accounts × 7 steps
  fct_workflow_completion    — incremental, partitioned by completed_date
  dim_account                — SCD Type 1, shared with Release 05
  dim_account_product_score  — full rebuild monthly, 7-signal composite
              ↓
Looker (product.model.lkml):
  feature_adoption explore   → PB-01 Product Adoption Overview
  account_product_usage      → PB-02 Account-Level Usage
  onboarding_funnel          → PB-03 Onboarding Funnel Analysis
```

---

## Product Engagement Score

7-component composite score (0–100). Weights configurable via dbt vars. Full model rebuild monthly — `dim_account_product_score` retains 24 months of history for trending.

The **work_order_within_30_days** signal (10% weight) is the most predictive churn indicator identified by Claire Ashworth. Accounts that don't create a work order in the first 30 days have significantly higher 12-month churn rates.

---

## PII Controls

User IDs are stored as `SHA-256(user_id)` — 64-character hex hashes. No plain-text user IDs in any warehouse model. The `assert_product_no_plain_text_user_id` Dataform assertion validates this on every pipeline run. Looker does not expose `user_pk` dimensions.

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Event source priority | Segment for transactional; Mixpanel for discovery | Segment is server-side, more reliable for core actions |
| Feature taxonomy storage | Seed CSV | Leon Yip can update without code changes |
| Stalled threshold | 14 days (configurable via dbt var) | Balances urgency vs. noise; adjustable by CS team |
| Score materialization | Full table rebuild monthly | Rolling windows make incremental complex; 312 accounts × 24 months = manageable |
| dim_account shared key | SHA-256(salesforce_account_id) | Consistent with Release 05 customer analytics joins |
| Licence utilisation null | Show NULL (not 0) | Honest; `User_Seats__c` missing for older contracts |

---

## Cross-Release Dependencies

- **Depends on**: Release 02 (staging models for all 5 source systems)
- **Feeds into**: Release 05 (customer analytics) — `dim_account_product_score.product_engagement_score` is a component in the customer health score
- **Shared entity**: `dim_account` (account_pk consistent across releases 04 and 05)
