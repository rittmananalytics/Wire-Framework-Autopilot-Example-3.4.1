# Data Quality Plan — Product Analytics
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Dataform tag**: `data_quality_product`

---

## Assertion Summary

| ID | Assertion | Severity | Model | Alert Channel |
|----|-----------|----------|-------|--------------|
| DQ-P01 | No plain-text user IDs in warehouse models | CRITICAL | fct_feature_usage, fct_session_events, fct_workflow_completion | #data-platform-alerts + Priya Nair (Privacy) |
| DQ-P02 | Product engagement score in range 0–100 | HIGH | dim_account_product_score | #data-platform-alerts |
| DQ-P03 | Score weights sum to 1.0 | HIGH | N/A (dbt var validation) | #data-platform-alerts |
| DQ-P04 | All 7 onboarding steps present per account | MEDIUM | fct_onboarding_funnel | #data-platform-alerts |
| DQ-P05 | No duplicate events (same user + event + timestamp) | HIGH | fct_feature_usage | #data-platform-alerts |
| DQ-P06 | Feature taxonomy coverage ≥ 90% (not unmapped) | MEDIUM | fct_feature_usage | #data-platform-alerts |
| DQ-P07 | Account count consistent with Salesforce source | MEDIUM | dim_account | #data-platform-alerts |
| DQ-P08 | fct_feature_usage freshness ≤ 26 hours | HIGH | fct_feature_usage | #data-platform-alerts |
| DQ-P09 | dim_account_product_score populated for all active accounts | MEDIUM | dim_account_product_score | #data-platform-alerts |
| DQ-P10 | Segment and Mixpanel session volume reconciliation | MEDIUM | fct_session_events | #data-platform-alerts |

---

## DQ-P01: PII Compliance — No Plain-Text User IDs

```sql
-- assert_product_no_plain_text_user_id
-- Validates that user_pk columns contain only 64-char hex hashes
-- CRITICAL: any failure must block dashboard access and alert Priya Nair

select 'fct_feature_usage' as model, count(*) as violations
from mart_product.fct_feature_usage
where user_pk is not null
  and (length(user_pk) != 64 or regexp_contains(user_pk, r'[^0-9a-f]'))

union all

select 'fct_session_events', count(*)
from mart_product.fct_session_events
where user_pk is not null
  and (length(user_pk) != 64 or regexp_contains(user_pk, r'[^0-9a-f]'))

union all

select 'fct_workflow_completion', count(*)
from mart_product.fct_workflow_completion
where user_pk is not null
  and (length(user_pk) != 64 or regexp_contains(user_pk, r'[^0-9a-f]'))

having sum(violations) > 0
```

**Pass criteria**: Zero rows returned across all three models

---

## DQ-P02: Score Range Validation

```sql
-- assert_product_score_in_range
select account_pk, score_month, product_engagement_score
from mart_product.dim_account_product_score
where product_engagement_score < 0
   or product_engagement_score > 100
```

**Pass criteria**: Zero rows returned

---

## DQ-P03: Score Weight Validation

Validated at dbt compile time via dbt vars. If weights are changed, this assertion re-validates at runtime:

```sql
-- assert_product_score_weights_sum_to_one
-- Uses the configured dbt vars to check they sum to 1.0
select round(
    @dau_mau_weight + @feature_breadth_weight + @core_activation_weight +
    @work_order_weight + @licence_util_weight + @nps_weight + @onboarding_weight
, 2) as total_weight
having total_weight != 1.00
```

**Pass criteria**: Weights sum exactly to 1.00

---

## DQ-P04: Onboarding Step Completeness

```sql
-- assert_all_onboarding_steps_present
-- Every active account should have exactly 7 rows in fct_onboarding_funnel
select account_pk, count(*) as step_count
from mart_product.fct_onboarding_funnel
group by 1
having count(*) != 7
```

**Pass criteria**: Zero rows (every account has exactly 7 step records)

---

## DQ-P05: Event Deduplication

```sql
-- assert_no_duplicate_product_events
select user_pk, event_name, event_timestamp_utc, count(*) as duplicate_count
from mart_product.fct_feature_usage
group by 1, 2, 3
having count(*) > 1
limit 10
```

**Pass criteria**: Zero rows returned

---

## DQ-P06: Feature Taxonomy Coverage

```sql
-- assert_feature_taxonomy_coverage
-- Alert if > 10% of events are unmapped (module = 'Other')
select
  countif(module_id = 'mod_999') as unmapped_events,
  count(*) as total_events,
  round(countif(module_id = 'mod_999') / count(*), 2) as unmapped_rate
from mart_product.fct_feature_usage
where event_date >= date_sub(current_date(), interval 7 day)
having unmapped_rate > 0.10
```

**Pass criteria**: Unmapped rate ≤ 10%; if > 10%, alert and request updated feature_taxonomy seed from Leon Yip

---

## DQ-P07: Account Count Consistency

```sql
-- assert_account_count_consistency
-- dim_account should have similar count to Salesforce active accounts
-- Alert if count differs by > 5% from Salesforce staging count
with sf_count as (
    select count(*) as sf_accounts
    from staging.stg_salesforce__accounts
    where is_active = true
),
dw_count as (
    select count(*) as dw_accounts
    from mart_product.dim_account
    where is_active = true
)
select sf_accounts, dw_accounts,
       abs(sf_accounts - dw_accounts) / sf_accounts as discrepancy_rate
from sf_count, dw_count
having discrepancy_rate > 0.05
```

**Pass criteria**: Count discrepancy ≤ 5%

---

## DQ-P08: Freshness Check

```sql
-- assert_product_feature_usage_fresh
select max(event_timestamp_utc) as latest_event,
       timestamp_diff(current_timestamp(), max(event_timestamp_utc), hour) as hours_since_latest
from mart_product.fct_feature_usage
having timestamp_diff(current_timestamp(), max(event_timestamp_utc), hour) > 26
```

**Pass criteria**: Latest event within 26 hours (1-day pipeline + 2-hour buffer)

---

## DQ-P09: Score Coverage

```sql
-- assert_all_active_accounts_scored
-- Every active account should have a score for the current month
select a.account_pk, a.account_name
from mart_product.dim_account as a
left join mart_product.dim_account_product_score as s
    on a.account_pk = s.account_pk
    and s.score_month = date_trunc(current_date(), month)
where a.is_active = true
  and s.score_pk is null
```

**Pass criteria**: Zero rows (all active accounts have a current-month score)

---

## DQ-P10: Session Volume Reconciliation

```sql
-- assert_segment_session_volume_consistent
-- Compare session counts in fct_session_events vs raw Segment staging
-- Alert if warehouse has < 80% of raw session count
with raw_count as (
    select count(*) as raw_sessions
    from staging.stg_segment__sessions
    where session_date >= date_sub(current_date(), interval 7 day)
),
dw_count as (
    select count(*) as dw_sessions
    from mart_product.fct_session_events
    where session_date >= date_sub(current_date(), interval 7 day)
)
select raw_sessions, dw_sessions,
       safe_divide(dw_sessions, raw_sessions) as retention_rate
from raw_count, dw_count
having retention_rate < 0.80
```

**Pass criteria**: ≥ 80% of raw sessions retained (allows for accounts without a matched account_pk to be filtered)

---

## Volume Thresholds (for anomaly detection)

| Model | Min Expected Rows | Max Expected Daily Change |
|-------|-----------------|--------------------------|
| fct_feature_usage | 100,000 (daily) | ±40% |
| fct_session_events | 20,000 (daily) | ±40% |
| fct_onboarding_funnel | 2,184 (total, 312×7) | ±5 accounts |
| dim_account | 300 | ±10 per day |
| dim_account_product_score | 312 (current month) | ±5 |
