# Data Quality Plan — Operational Analytics
## Release: 06-operational-analytics

**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25

---

## Assertions

### DQ-O01: Support Ticket Account Coverage
**Severity**: Medium
**Description**: Tickets should join to a known account. Unmatched tickets indicate Zendesk account_id mapping gaps.
```sql
select count(*) as unmatched_tickets
from {{ ref('fct_support_tickets') }}
where account_pk is null
having count(*) > count(*) * 0.05  -- more than 5% unmatched triggers alert
```

### DQ-O02: SLA Compliance Range
**Severity**: Medium
**Description**: SLA compliance % must be between 0 and 100.
**Test**: `assert_score_in_range(model=fct_support_capacity, column_name=sla_compliance_pct, min_value=0, max_value=100)`

### DQ-O03: Incident MTTR Sanity
**Severity**: Medium
**Description**: No P1 incident should have resolution_hours > 720 (30 days). Values larger than this indicate data quality issues.
```sql
select count(*) as outlier_incidents
from {{ ref('fct_incident_response') }}
where severity = 'P1'
  and resolution_hours > 720
having count(*) > 0
```

### DQ-O04: Infrastructure Cost Completeness
**Severity**: Low
**Description**: Verify all active accounts appear in fct_infra_cost_by_customer for the most recent billing month.
```sql
select count(*) as missing_accounts
from {{ ref('stg_salesforce__accounts') }} as a
where is_active = true
  and not exists (
      select 1
      from {{ ref('fct_infra_cost_by_customer') }} as c
      where c.account_pk = a.account_pk
        and c.billing_month = date_trunc(date_sub(current_date(), interval 1 month), month)
  )
having count(*) > 0
```

### DQ-O05: GCP Billing Freshness
**Severity**: Medium
**Description**: GCP Billing export should have data for the prior month. Missing current month is expected (billing delay).
```sql
select max(billing_month) as latest_billing_month
from {{ ref('stg_gcp__billing_export') }}
having latest_billing_month < date_sub(date_trunc(current_date(), month), interval 2 month)
```

---

## Summary

| Assertion | Severity | Blocking |
|-----------|----------|----------|
| DQ-O01 Ticket account coverage | Medium | No |
| DQ-O02 SLA compliance range | Medium | No |
| DQ-O03 Incident MTTR sanity | Medium | No |
| DQ-O04 Infrastructure cost completeness | Low | No |
| DQ-O05 GCP Billing freshness | Medium | No |
