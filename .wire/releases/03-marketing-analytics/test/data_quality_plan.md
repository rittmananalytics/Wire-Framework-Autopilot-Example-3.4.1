# Data Quality Plan
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0
**Dependency**: 02-data-foundation data quality plan must be passing before marketing analytics assertions run

---

## 1. Overview

This document specifies the data quality assertions for the marketing analytics warehouse models. All assertions are implemented as:
1. **dbt tests** (schema.yml) — run as part of `dbt test --select warehouse_marketing`
2. **Dataform native assertions** — run as part of `data_quality_dag` in Cloud Composer with tag `data_quality_marketing`
3. **Custom generic tests** — in `dbt/tests/generic/` (see dbt artifact)

Assertion failures on critical checks block downstream Looker dashboard refresh.

---

## 2. Attribution Model Integrity Assertions

**Purpose**: Ensure attribution calculations are internally consistent and revenue is fully accounted for.

### 2.1 Attribution Weights Sum to 1.0

```sql
-- assert_marketing_attribution_weights.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "attribution"]
}

SELECT
  opportunity_pk,
  attribution_model,
  ROUND(SUM(touch_weight), 3) as weight_sum,
  COUNT(*) as touch_count
FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
WHERE is_closed_won = TRUE
GROUP BY 1, 2
HAVING ABS(ROUND(SUM(touch_weight), 3) - 1.0) > 0.001
```

| Check | Expected | Alert If |
|-------|---------|---------|
| Attribution weights per opp per model | SUM(touch_weight) = 1.0 ± 0.001 | Any violation |

### 2.2 Attribution Revenue Matches Opportunity ARR

```sql
-- assert_marketing_attributed_revenue_totals.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "attribution"]
}

SELECT
  opportunity_pk,
  attribution_model,
  ROUND(SUM(attributed_revenue_usd), 2) as total_attributed,
  ROUND(MAX(opportunity_arr_usd), 2) as opportunity_arr,
  ABS(ROUND(SUM(attributed_revenue_usd), 2) - ROUND(MAX(opportunity_arr_usd), 2)) as discrepancy
FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
WHERE is_closed_won = TRUE
GROUP BY 1, 2
HAVING ABS(ROUND(SUM(attributed_revenue_usd), 2) - ROUND(MAX(opportunity_arr_usd), 2)) > 0.01
```

### 2.3 All 5 Attribution Models Present

```sql
-- assert_all_attribution_models_present.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "attribution"]
}

WITH expected_models AS (
  SELECT model FROM UNNEST(['first_touch', 'last_touch', 'linear', 'time_decay', 'u_shaped']) AS model
),
actual_models AS (
  SELECT DISTINCT attribution_model FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
)
SELECT e.model as missing_model
FROM expected_models e
LEFT JOIN actual_models a ON e.model = a.attribution_model
WHERE a.attribution_model IS NULL
```

---

## 3. PII Compliance Assertions

**Purpose**: Ensure no plain-text emails reach any warehouse model.

### 3.1 No Plain-Text Email in dim_contact

```sql
-- assert_marketing_no_plain_text_email.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "pii"]
}

SELECT COUNT(*) as violations
FROM `core-dynamics-analytics-prod.mart_marketing.dim_contact`
WHERE
  -- email_pseudonymised must be exactly 64 hex chars (SHA-256)
  NOT REGEXP_CONTAINS(email_pseudonymised, r'^[0-9a-f]{64}$')
  -- Must not contain @ (plain-text email indicator)
  OR REGEXP_CONTAINS(email_pseudonymised, r'@')
HAVING COUNT(*) > 0
```

### 3.2 Email Hash Format Valid

```sql
-- assert_marketing_email_hash_format.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "pii"]
}

SELECT
  COUNT(*) as total_contacts,
  COUNTIF(LENGTH(email_pseudonymised) = 64) as valid_hashes,
  COUNTIF(LENGTH(email_pseudonymised) != 64) as invalid_hashes
FROM `core-dynamics-analytics-prod.mart_marketing.dim_contact`
HAVING COUNTIF(LENGTH(email_pseudonymised) != 64) > 0
```

---

## 4. Attribution Coverage Assertions

**Purpose**: Monitor UTM coverage and contact match rates.

### 4.1 UTM Coverage Rate

```sql
-- assert_marketing_utm_coverage.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "coverage"]
}

WITH coverage AS (
  SELECT
    COUNT(*) as total_touches,
    COUNTIF(channel != 'unattributed') as attributed_touches,
    ROUND(COUNTIF(channel != 'unattributed') / COUNT(*), 3) as coverage_rate
  FROM `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches`
  WHERE touch_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
)
SELECT *
FROM coverage
-- Alert if coverage drops below 60% (documented baseline ~70%; alert at 60% indicates worsening)
WHERE coverage_rate < 0.60
```

| Check | Current Baseline | Alert Threshold | Notes |
|-------|----------------|----------------|-------|
| UTM coverage rate (last 30 days) | ~70% | < 60% | 30% gap is documented; alert only if significantly worse |

### 4.2 HubSpot-Salesforce Match Rate

```sql
-- assert_marketing_contact_match_rate.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "coverage"]
}

WITH match_stats AS (
  SELECT
    COUNT(*) as total_contacts,
    COUNTIF(is_sf_matched) as matched_contacts,
    ROUND(COUNTIF(is_sf_matched) / COUNT(*), 3) as match_rate
  FROM `core-dynamics-analytics-prod.mart_marketing.dim_contact`
)
SELECT *
FROM match_stats
-- Alert if match rate drops below 80% (baseline ~88%; alert at 80% indicates degradation)
WHERE match_rate < 0.80
```

---

## 5. Freshness Assertions

### 5.1 Marketing Warehouse Model Freshness

```sql
-- assert_marketing_warehouse_freshness.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "freshness"]
}

-- fct_attribution_touches should have data from today or yesterday
SELECT COUNT(*) as violations
FROM `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches`
WHERE DATE(_loaded_at) < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND (SELECT MAX(DATE(_loaded_at)) FROM `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches`) < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
HAVING COUNT(*) > 0
```

| Model | Expected Freshness | Max Allowed | Alert Threshold |
|-------|-------------------|-------------|----------------|
| fct_lead_funnel_events | Daily (T+1) by 08:00 UTC | T+2 | Any day without refresh |
| fct_campaign_spend | Daily (T+1) by 08:00 UTC | T+2 | Any day without refresh |
| fct_attribution_touches | Daily (T+1) by 08:00 UTC | T+2 | Any day without refresh |
| fct_opportunity_attribution | Daily (T+1) by 08:00 UTC | T+2 | Any day without refresh |
| dim_campaign | Daily (T+1) | T+2 | Any day without refresh |
| dim_contact | Daily (T+1) | T+2 | Any day without refresh |

---

## 6. Volume Anomaly Assertions

### 6.1 Row Count Anomaly Detection

```sql
-- assert_marketing_fct_attribution_volume.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "volume"]
}

WITH today_count AS (
  SELECT COUNT(*) as rows_today
  FROM `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches`
  WHERE DATE(_loaded_at) = CURRENT_DATE()
),
yesterday_count AS (
  SELECT COUNT(*) as rows_yesterday
  FROM `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches`
  WHERE DATE(_loaded_at) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
)
SELECT
  today_count.rows_today,
  yesterday_count.rows_yesterday,
  ABS(today_count.rows_today - yesterday_count.rows_yesterday) / NULLIF(yesterday_count.rows_yesterday, 0) as change_rate
FROM today_count, yesterday_count
HAVING change_rate > 0.20  -- 20% day-over-day change threshold for touch events
```

| Model | Min Rows | Max Day-over-Day Change | Notes |
|-------|---------|------------------------|-------|
| fct_attribution_touches | 500,000 | 20% | Daily touch volume fluctuates; large changes indicate ingestion issue |
| fct_opportunity_attribution | 10,000 | 25% | Full rebuild; count depends on active opps × 5 models |
| fct_lead_funnel_events | 50,000 | 10% | Incremental; should be stable day-to-day |
| fct_campaign_spend | 100 | 30% | Weekend low; weekday normal; Monday spike expected |
| dim_contact | 180,000 | 5% | Contact dimension should be stable |
| dim_campaign | 200 | 15% | New campaigns added periodically |

---

## 7. Business Logic Assertions

### 7.1 Influence Window Compliance

```sql
-- assert_marketing_influence_window.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "business_logic"]
}

SELECT COUNT(*) as out_of_window_touches
FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
WHERE days_before_opportunity > 180 OR days_before_opportunity < 0
HAVING COUNT(*) > 0
```

### 7.2 No Negative Attribution Values

```sql
-- assert_marketing_no_negative_attribution.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "business_logic"]
}

SELECT COUNT(*) as negative_values
FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
WHERE attributed_revenue_usd < 0 OR attributed_pipeline_usd < 0 OR touch_weight < 0
HAVING COUNT(*) > 0
```

### 7.3 U-Shaped Default Available in Explore

```sql
-- assert_marketing_u_shaped_model_coverage.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "data_quality_marketing", "business_logic"]
}

SELECT COUNT(*) as u_shaped_records
FROM `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution`
WHERE attribution_model = 'u_shaped'
HAVING COUNT(*) = 0  -- Alert if no u_shaped records exist
```

---

## 8. Alert Configuration

### Slack Alert Channels
- `#data-platform-alerts` — All marketing analytics pipeline alerts
- `#data-engineering` — Debugging alerts for Rittman Analytics team

### Alert Severity Matrix for Marketing Analytics

| Assertion | Severity | Response SLA |
|-----------|---------|-------------|
| Attribution weights sum ≠ 1.0 | HIGH | 1 hour — blocks MA-02 dashboard trust |
| Attribution revenue ≠ ARR | HIGH | 1 hour — figures shown to Rachel Summers would be wrong |
| Plain-text email in dim_contact | CRITICAL | 30 minutes — PII breach; escalate to Priya Nair + Diane Hooper |
| UTM coverage < 60% | MEDIUM | 4 hours — investigate with Niamh Collins |
| Contact match rate < 80% | MEDIUM | 4 hours — attribution coverage degraded |
| Volume anomaly > 20% | MEDIUM | 4 hours |
| Freshness > T+1 | HIGH | 1 hour — MA-01 Monday standup at risk |
| Influence window violation | HIGH | 1 hour — attribution calculations incorrect |

---

## 9. Monitoring Dashboard Addition

The pipeline health dashboard (from 02-data-foundation) should be extended with a Marketing Analytics tab:

| Tile | Metric |
|------|--------|
| Attribution model coverage | % of opportunities with all 5 models |
| UTM coverage rate (30-day trend) | Line chart, target ≥ 70% |
| Contact match rate | KPI with trend |
| Failed marketing assertions | Count today |
| fct_opportunity_attribution row count | vs. yesterday |
| Last successful attribution run | Timestamp |
