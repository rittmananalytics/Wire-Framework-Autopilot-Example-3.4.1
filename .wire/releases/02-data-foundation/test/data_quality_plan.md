# Data Quality Plan
## Release: 02-data-foundation
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0

---

## 1. Overview

This document specifies the data quality assertions for the Core Dynamics data foundation. All assertions are implemented as Dataform native assertions and run as part of the `data_quality_dag` in Cloud Composer. Assertion failures block downstream transformation runs.

### Quality Dimensions Covered
- **Freshness**: Data arrives on time and meets latency SLAs
- **Completeness**: No unexpected null rates on critical fields
- **Consistency**: Referential integrity between related tables
- **Accuracy**: Business logic sanity checks on key measures
- **Volume**: Row count anomaly detection

---

## 2. Freshness Assertions

### Purpose
Confirm that each source system's data has landed in BigQuery within the expected latency window.

### Assertions

```sql
-- assert_salesforce_freshness.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "freshness", "salesforce"]
}

SELECT COUNT(*) as violations
FROM `core-dynamics-analytics-prod.staging.stg_salesforce__accounts`
WHERE _fivetran_synced < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 HOUR)
  AND DATE(_fivetran_synced) = CURRENT_DATE()
HAVING COUNT(*) > 0
```

| Source | Expected Latency | Max Allowed | Alert Threshold |
|--------|-----------------|-------------|----------------|
| Salesforce | Within 6.5 hours | 7 hours from last sync | 0 violations |
| HubSpot | Within 1.5 hours | 2 hours | 0 violations |
| Zendesk | Within 1.5 hours | 2 hours | 0 violations |
| CoreFM PostgreSQL | Within 20 minutes | 30 minutes | 0 violations |
| Google Ads | By 7am UTC | 10am UTC | 0 violations |
| LinkedIn Ads | By 7am UTC | 10am UTC | 0 violations |
| Meta Ads | By 7am UTC | 10am UTC | 0 violations |
| Mixpanel | By 8am UTC | 10am UTC | 0 violations |
| NetSuite | By 7am UTC | 10am UTC | 0 violations |
| BambooHR | By 7am UTC | 10am UTC | 0 violations |
| ChurnZero | By 8am UTC | 10am UTC | 0 violations |

---

## 3. Completeness Assertions

### Purpose
Ensure critical fields do not exceed acceptable null rates.

```sql
-- assert_salesforce_accounts_completeness.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "completeness", "salesforce"]
}

SELECT
  COUNT(CASE WHEN account_pk IS NULL THEN 1 END) as null_pk_count,
  COUNT(CASE WHEN account_name IS NULL THEN 1 END) as null_name_count,
  COUNT(CASE WHEN arr IS NULL THEN 1 END) as null_arr_count,
  COUNT(*) as total_rows,
  ROUND(COUNT(CASE WHEN account_pk IS NULL THEN 1 END) / COUNT(*), 4) as null_pk_rate
FROM `core-dynamics-analytics-prod.staging.stg_salesforce__accounts`
HAVING null_pk_count > 0
    OR ROUND(COUNT(CASE WHEN account_name IS NULL THEN 1 END) / COUNT(*), 4) > 0.01
    OR ROUND(COUNT(CASE WHEN arr IS NULL THEN 1 END) / COUNT(*), 4) > 0.15
```

### Critical Field Null Rate Thresholds

| Table | Field | Max Null Rate | Notes |
|-------|-------|--------------|-------|
| stg_salesforce__accounts | account_pk | 0% | PK — never null |
| stg_salesforce__accounts | account_name | < 1% | Business rule |
| stg_salesforce__accounts | arr | < 15% | Some accounts may have null ARR (new/churned) |
| stg_salesforce__accounts | renewal_date | < 20% | Known issue: ~15% null pre-2023 — documented exception |
| stg_salesforce__opportunities | opportunity_pk | 0% | PK |
| stg_salesforce__opportunities | account_fk | < 1% | Should always link to account |
| stg_salesforce__opportunities | close_date | < 5% | |
| stg_hubspot__contacts | contact_pk | 0% | PK |
| stg_hubspot__contacts | email | < 2% | Most contacts have emails |
| stg_corefm_db__accounts | account_pk | 0% | PK |
| stg_corefm_db__users | pseudonymised_user_id | 0% | PK — pseudonymised, never null |
| stg_corefm_db__feature_events | account_pk | 0% | Must always link to account |
| stg_churnzero__health_scores | account_pk | 0% | PK |
| stg_zendesk__tickets | ticket_pk | 0% | PK |

---

## 4. Referential Integrity Assertions

### Purpose
Ensure foreign keys resolve to valid primary keys in referenced tables.

```sql
-- assert_opportunities_account_fk.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "referential_integrity"]
}

SELECT COUNT(*) as orphaned_opportunities
FROM `core-dynamics-analytics-prod.staging.stg_salesforce__opportunities` o
LEFT JOIN `core-dynamics-analytics-prod.staging.stg_salesforce__accounts` a
  ON o.account_fk = a.account_pk
WHERE a.account_pk IS NULL
  AND o.account_fk IS NOT NULL
HAVING COUNT(*) > 0
```

### Referential Integrity Checks

| Child Table | FK Column | Parent Table | PK Column | Tolerance |
|------------|-----------|-------------|----------|-----------|
| stg_salesforce__opportunities | account_fk | stg_salesforce__accounts | account_pk | 0% orphans |
| stg_salesforce__contacts | account_fk | stg_salesforce__accounts | account_pk | < 1% orphans |
| stg_hubspot__form_submissions | contact_fk | stg_hubspot__contacts | contact_pk | < 5% orphans (known dedup issue) |
| stg_corefm_db__feature_events | account_pk | stg_corefm_db__accounts | account_pk | 0% orphans |
| stg_corefm_db__work_orders | account_pk | stg_corefm_db__accounts | account_pk | 0% orphans |
| stg_zendesk__tickets | account_pk | stg_salesforce__accounts | account_pk | < 2% orphans |
| stg_churnzero__health_scores | account_pk | stg_salesforce__accounts | account_pk | < 5% orphans |

---

## 5. Business Logic Assertions

### Purpose
Catch data that violates known business rules — these indicate either upstream system data quality issues or pipeline bugs.

```sql
-- assert_arr_non_negative.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "business_logic"]
}

SELECT COUNT(*) as negative_arr_accounts
FROM `core-dynamics-analytics-prod.mart_customer.dim_account_health`
WHERE arr < 0
HAVING COUNT(*) > 0
```

### Business Logic Checks

| Check | Description | Expected | Alert If |
|-------|-------------|---------|---------|
| ARR non-negative | No account has negative ARR | ARR ≥ 0 for all active contracts | Any ARR < 0 |
| NPS score range | NPS scores within valid range | -100 ≤ NPS ≤ 100 | Any NPS outside range |
| Churn probability range | BQML output in valid range | 0 ≤ churn_probability ≤ 1 | Any value outside [0,1] |
| Product engagement score range | Score within defined range | 0 ≤ engagement_score ≤ 100 | Any value outside [0,100] |
| Renewal date in future | Upcoming renewals have future dates | renewal_date > CURRENT_DATE for open contracts | Any renewal_date < 60 days past CURRENT_DATE for active contracts |
| Contract ACV positive | Active contracts have positive ACV | ACV > 0 | Any active contract with ACV ≤ 0 |
| SLA response time positive | Support ticket response times positive | resolution_minutes > 0 | Any resolution_minutes ≤ 0 |

---

## 6. Volume Anomaly Detection

### Purpose
Flag unexpected drops or spikes in row counts that might indicate pipeline failures.

```sql
-- assert_salesforce_accounts_row_count.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "volume"]
}

WITH today_count AS (
  SELECT COUNT(*) as rows_today
  FROM `core-dynamics-analytics-prod.staging.stg_salesforce__accounts`
  WHERE DATE(_fivetran_synced) = CURRENT_DATE()
),
yesterday_count AS (
  SELECT COUNT(*) as rows_yesterday
  FROM `core-dynamics-analytics-prod.staging.stg_salesforce__accounts`
  WHERE DATE(_fivetran_synced) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
)
SELECT
  today_count.rows_today,
  yesterday_count.rows_yesterday,
  ABS(today_count.rows_today - yesterday_count.rows_yesterday) / NULLIF(yesterday_count.rows_yesterday, 0) as change_rate
FROM today_count, yesterday_count
HAVING change_rate > 0.10  -- Flag if row count changes by more than 10%
```

### Volume Thresholds

| Table | Min Rows | Max Day-over-Day Change | Notes |
|-------|---------|------------------------|-------|
| stg_salesforce__accounts | 300 | 10% | ~312 enterprise accounts |
| stg_salesforce__opportunities | 1000 | 15% | Active + historical opps |
| stg_hubspot__contacts | 50000 | 5% | ~200K contacts |
| stg_corefm_db__feature_events | 10000 | 25% | Daily event volume varies |
| stg_zendesk__tickets | 500 | 20% | ~2K tickets/month |

---

## 7. Pipeline Health Dashboard Specification

### Dashboard: Pipeline Health & Observability

**Location**: Looker; pipeline_health model
**Audience**: Amara Diallo, Kofi Asante, Sean Murphy
**Refresh**: Hourly

### Tiles

| Tile | Metric | Chart Type |
|------|--------|------------|
| Last Sync Status | Per-source: last sync timestamp + status (success/failed) | Table with RAG indicators |
| Row Count Trend | Daily row count for each staging table (last 14 days) | Line chart (small multiples) |
| Failed Assertions | Count of failed assertions today; list of failures | KPI tile + table |
| DAG Run History | Cloud Composer DAG success/failure (last 7 days) | Calendar heatmap |
| Source Freshness | Time since last successful sync per source | Bar chart |
| Alert History | Count of alerts fired per day (last 30 days) | Bar chart |

---

## 8. Alert Configuration

### Slack Alert Template

```
🚨 *Data Quality Alert — Core Dynamics*
*Severity*: [HIGH/MEDIUM/LOW]
*Time*: [TIMESTAMP]
*Assertion*: [ASSERTION_NAME]
*Description*: [DESCRIPTION]
*Action Required*: [ACTION]
*Runbook*: [LINK_TO_RUNBOOK]
```

### Slack Channels
- `#data-platform-alerts` — All pipeline alerts (Rittman Analytics + Amara Diallo's team)
- `#data-engineering` — Detailed debugging alerts (Rittman Analytics only during engagement)

### Alert Severity Matrix

| Failure Type | Severity | Response SLA |
|-------------|---------|-------------|
| Freshness assertion failure (critical source) | HIGH | 1 hour |
| Business logic assertion failure (ARR, NPS) | HIGH | 1 hour |
| Referential integrity failure | MEDIUM | 4 hours |
| Completeness above threshold | MEDIUM | 4 hours |
| Volume anomaly (>10% change) | MEDIUM | 4 hours |
| Fivetran connector failure | HIGH | 1 hour |
| Cloud Composer DAG failure | HIGH | 1 hour |
