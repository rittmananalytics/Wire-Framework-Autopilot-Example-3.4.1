# Data Quality Plan — Customer Analytics
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Framework**: Dataform assertions (tag: data_quality_customer)

---

## Overview

10 assertions covering: PII compliance, score integrity, NRR reasonableness, RLS correctness, churn event deduplication, cross-release join integrity, BQML prediction completeness.

**Critical assertion**: DQ-C01 (row count drop guard) and DQ-C04 (NRR reconciliation) are blocking — failures halt the deployment pipeline.

---

## Assertion Catalogue

### DQ-C01: Account Coverage Guard
**Severity**: Critical (blocking)
**Model**: `dim_account_health`
**Description**: Verify that dim_account_health has a record for every active account on the most recent score_date. A row count drop >10% vs prior day indicates a pipeline failure.
**Assertion**:
```sql
-- Fail if fewer than 90% of active accounts have a health score today
select count(*) as missing_accounts
from {{ ref('stg_salesforce__accounts') }} as a
where a.is_active = true
  and not exists (
      select 1
      from {{ ref('dim_account_health') }} as h
      where h.account_pk = a.account_pk
        and h.score_date = date_sub(current_date(), interval 1 day)
  )
having count(*) > (
    select count(*) * 0.10
    from {{ ref('stg_salesforce__accounts') }}
    where is_active = true
)
```

### DQ-C02: Health Score Range
**Severity**: High
**Model**: `dim_account_health`
**Description**: All health scores must be in range 0–100.
**Test**: `assert_score_in_range(model=dim_account_health, column_name=health_score, min_value=0, max_value=100)`

### DQ-C03: Health Score Weight Sum
**Severity**: High
**Model**: dbt vars check
**Description**: Verify that the 5 dbt health score weight vars sum to 1.0 (±0.001 tolerance). Misconfigured weights produce nonsensical scores.
**Assertion** (custom singular test):
```sql
-- dbt/tests/assert_customer_health_weights_sum.sql
select 'weight_sum_check' as check_name,
    abs(
        {{ var('customer_health_product_weight') }}
      + {{ var('customer_health_support_weight') }}
      + {{ var('customer_health_financial_weight') }}
      + {{ var('customer_health_relationship_weight') }}
      + {{ var('customer_health_nps_weight') }}
      - 1.0
    ) as weight_sum_error
having weight_sum_error > 0.001
```

### DQ-C04: NRR Reconciliation (Blocking)
**Severity**: Critical (blocking)
**Model**: `fct_nrr_grr`
**Description**: Company-level NRR for the most recent closed month must be within 2 percentage points of David Park's Finance reference number. Fails until NRR methodology is reconciled.
**Process**: Semi-automated — Finance team provides reference figure; assertion checks against seeded table.
**Assertion**:
```sql
select 'nrr_reconciliation' as check_name,
    abs(actual_nrr - reference_nrr) as nrr_discrepancy
from (
    select
        avg(nrr) as actual_nrr,
        (select reference_nrr from {{ ref('finance_nrr_reference') }}
         where month = date_trunc(date_sub(current_date(), interval 1 month), month)) as reference_nrr
    from {{ ref('fct_nrr_grr') }}
    where month_start = date_trunc(date_sub(current_date(), interval 1 month), month)
)
having nrr_discrepancy > 2.0
```

### DQ-C05: Churn Event Deduplication
**Severity**: Medium
**Model**: `fct_churn_events`
**Description**: No account should have more than one full churn event in the same calendar month (a business impossibility).
```sql
select account_pk, date_trunc(event_date, month) as churn_month, count(*) as churn_count
from {{ ref('fct_churn_events') }}
where churn_type = 'full_churn'
group by 1, 2
having count(*) > 1
```

### DQ-C06: Cross-Release Account Key Integrity
**Severity**: High
**Model**: `dim_account_health`
**Description**: All account_pks in dim_account_health must exist in dim_account (Release 04). Orphaned records indicate a join key mismatch.
**Test**: `relationships` test in schema.yml: `relationships(to=ref('dim_account'), field=account_pk)`

### DQ-C07: BQML Prediction Coverage
**Severity**: Medium
**Model**: `dim_account_health`
**Description**: At least 80% of active accounts should have a non-null churn_probability. NULL predictions indicate BQML inference job failure.
```sql
select
    countif(churn_probability is null) as missing_predictions,
    count(*) as total_accounts,
    round(countif(churn_probability is null) / count(*) * 100, 1) as pct_missing
from {{ ref('dim_account_health') }}
where score_date = date_sub(current_date(), interval 1 day)
having pct_missing > 20.0
```

### DQ-C08: Churn Risk Band Coverage
**Severity**: Medium
**Model**: `dim_account_health`
**Description**: churn_risk_band should be populated for all accounts where churn_probability is non-null. Validate accepted values.
**Test**: `accepted_values(values=['Low','Medium','High','Critical'])` on churn_risk_band

### DQ-C09: CSM Owner Coverage
**Severity**: High
**Model**: `fct_csm_book_of_business`
**Description**: All active accounts must have a non-null csm_owner. NULL owners cause RLS to silently hide accounts.
```sql
select count(*) as accounts_missing_csm
from {{ ref('fct_csm_book_of_business') }}
where csm_owner is null
  or trim(csm_owner) = ''
having count(*) > 0
```

### DQ-C10: NRR Bounds Sanity Check
**Severity**: Medium
**Model**: `fct_nrr_grr`
**Description**: Monthly NRR should be between -50% and 200% for any single account. Values outside this range indicate a calculation error.
**Test**: `assert_nrr_reasonable_range(model=fct_nrr_grr, column_name=nrr, min_value=-50, max_value=200)`

---

## Assertion Summary

| Assertion | Severity | Model | Blocking | Automated |
|-----------|----------|-------|----------|-----------|
| DQ-C01 Account Coverage Guard | Critical | dim_account_health | Yes | Yes |
| DQ-C02 Health Score Range | High | dim_account_health | No | Yes |
| DQ-C03 Health Weight Sum | High | dbt vars | No | Yes |
| DQ-C04 NRR Reconciliation | Critical | fct_nrr_grr | Yes | Semi-automated |
| DQ-C05 Churn Event Dedup | Medium | fct_churn_events | No | Yes |
| DQ-C06 Cross-Release Key Integrity | High | dim_account_health | No | Yes |
| DQ-C07 BQML Prediction Coverage | Medium | dim_account_health | No | Yes |
| DQ-C08 Churn Risk Band Coverage | Medium | dim_account_health | No | Yes |
| DQ-C09 CSM Owner Coverage | High | fct_csm_book_of_business | No | Yes |
| DQ-C10 NRR Bounds Sanity | Medium | fct_nrr_grr | No | Yes |

---

## Monitoring and Alerting

- All assertions run daily via Cloud Composer as `data_quality_customer` tagged Dataform invocation
- Failures trigger Slack alert to #data-platform-alerts
- DQ-C01 and DQ-C04 failures additionally page Sophie Tanner directly
- Weekly DQ summary email to Tara Obinna and David Park (Looker Scheduled Report)
