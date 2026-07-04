# Architecture Guide — Customer Analytics
## Release: 05-customer-analytics

**Date**: 2026-03-25 | **Author**: Sophie Tanner, Rittman Analytics

---

## Overview

Release 05 adds customer analytics on top of the data foundation. It integrates Salesforce (CRM), Zendesk (support), Intercom (NPS), ChurnZero (supplementary CS signals), and product engagement scores from Release 04 to produce a daily Customer Health Score per account, a BigQuery ML logistic regression churn prediction, NRR/GRR calculations, and three Looker dashboards for CS and Finance teams.

**Key design principle**: Salesforce is authoritative for financial events (ARR, renewals, churn). ChurnZero supplements but does not override. The Product Engagement Score from Release 04 is the largest single component (30%) of the Customer Health Score.

---

## Data Flow

```
Salesforce (6-hourly)          → salesforce        → stg_salesforce__*
Zendesk (6-hourly)             → zendesk           → stg_zendesk__*
Intercom (6-hourly)            → intercom          → stg_intercom__*
ChurnZero (daily)              → churnzero         → stg_churnzero__*
Release 04 dim_account_product_score → mart_product (cross-dataset)
            ↓
Integration Layer (intermediate_customer tag):
  int__account_health     — 5-signal assembly with 90-day date spine
  int__renewal_pipeline   — upcoming renewals + health enrichment
  int__csm_book           — per-CSM account summary + open actions
            ↓
Warehouse Layer (warehouse_customer tag, mart_customer dataset):
  dim_account_health      — incremental, partitioned by score_date
  fct_renewal_pipeline    — full refresh, 180-day lookahead
  fct_csm_book_of_business — full refresh, daily snapshot
  fct_nrr_grr             — full refresh, 24 months, finance-restricted
  fct_churn_events        — incremental, partitioned by event_date
  fct_expansion_signals   — full refresh, 3 signal types
            ↓
BigQuery ML (ml_models dataset):
  customer_churn_logistic_reg  — monthly retrain
  customer_churn_predictions   — daily inference; joined to dim_account_health
            ↓
Looker (customer.model.lkml):
  customer_health explore      → CA-01 Customer Health Command Centre
  csm_book_of_business explore → CA-02 CSM Book of Business (RLS)
  cs_leadership explore        → CA-03 CS Leadership Scorecard
```

---

## Customer Health Score

5-component composite score (0–100). Weights configurable via dbt vars.

| Signal | Weight | Source | Normalisation |
|--------|--------|--------|--------------|
| Product Engagement | 30% | dim_account_product_score (R04) | Score ÷ 100 |
| Financial Health | 25% | Salesforce renewal proximity + ARR | Renewal days → 0–1 scale |
| Support Health | 20% | Zendesk CSAT + resolution time + volume | Composite normalised |
| Relationship | 15% | QBR recency + exec sponsor | Days-since-QBR → 0–1 |
| NPS | 10% | Intercom NPS surveys | (NPS + 100) ÷ 200 |

Weights must sum to 1.0 — validated by `assert_customer_health_weights_sum` dbt test.

---

## BQML Churn Model

Logistic regression trained on 24 months of historical account health data. Training data includes Salesforce contract history proxy for months 15–24 (ChurnZero limited to 14 months).

- **Training cadence**: Monthly (1st of each month via Cloud Composer BranchPythonOperator)
- **Inference cadence**: Daily after `dim_account_health` is built
- **AUC-ROC target**: ≥ 0.75 on 20% holdout set
- **Risk bands**: Low (<20%), Medium (20–40%), High (40–65%), Critical (≥65%)
- **Fallback**: If AUC-ROC < 0.75, rule-based risk (health_score < 40 + renewal < 90 days)
- **Predictions stored**: `ml_models.customer_churn_predictions` (restricted IAM)

---

## Row-Level Security

CA-02 is protected by Looker user attribute-based RLS:
- Each CSM has `csm_owner` user attribute = their name (e.g., "Sarah Patel")
- `sql_always_where` in `csm_book_of_business` explore filters `fct_csm_book_of_business.csm_owner`
- Leadership users have `is_leadership = true` — bypass filter, see all accounts
- Provisioned by Greg Ellison in Looker Admin → User Attributes

Financial metrics (ARR, NRR, GRR) restricted via `required_access_grants` to `finance_viewers` and `leadership` groups.

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Health score frequency | Daily | CSM workflow needs daily visibility; monthly product score is interpolated |
| Financial signal definition | Renewal proximity (days) | Simpler and more predictive than ARR change which is noisy at account level |
| ChurnZero role | Supplementary signal only | Not authoritative; 14-month history limitation; BigQuery becomes SoR |
| BQML churn definition | Full churn only (binary) | Cleaner label; contraction modelled separately via NRR |
| NRR grain | Account × month | Enables cohort analysis, CSM attribution, Finance reconciliation |
| Cross-dataset join | mart_product.dim_account_product_score | Avoids model duplication; BigQuery cross-dataset queries performant at 312-account scale |
| Churn event source priority | Salesforce > ChurnZero | Salesforce is financial system of record; same approach as deduplication in Releases 03/04 |

---

## Cross-Release Dependencies

- **Depends on**: Release 02 (all staging models), Release 04 (`dim_account`, `dim_account_product_score`)
- **Feeds into**: Release 06 (operational analytics — cross-reference of support tickets with customer health)
- **Shared entity**: `dim_account` (account_pk consistent across releases 04 and 05)
- **Shared join key**: SHA-256(salesforce_account_id) — consistent in all downstream models
