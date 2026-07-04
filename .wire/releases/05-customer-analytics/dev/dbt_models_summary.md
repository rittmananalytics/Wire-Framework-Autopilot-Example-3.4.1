# dbt Models Summary — Customer Analytics
## Release: 05-customer-analytics

**Generated**: 2026-03-25
**Dataset**: mart_customer

---

## Model Counts

| Layer | Count | Models |
|-------|-------|--------|
| Integration | 3 | int__account_health, int__renewal_pipeline, int__csm_book |
| Warehouse | 6 | dim_account_health, fct_renewal_pipeline, fct_csm_book_of_business, fct_nrr_grr, fct_churn_events, fct_expansion_signals |
| **Total** | **9** | |

---

## Integration Layer

| Model | Materialisation | Tags | Key Logic |
|-------|----------------|------|-----------|
| int__account_health | View | intermediate_customer | 5-signal assembly with 90-day date spine |
| int__renewal_pipeline | View | intermediate_customer | Upcoming renewals enriched with health + BQML |
| int__csm_book | View | intermediate_customer | Per-CSM account summary with open actions |

---

## Warehouse Layer

| Model | Materialisation | Partition | Unique Key | Notes |
|-------|----------------|-----------|------------|-------|
| dim_account_health | Incremental | score_date | account_health_pk | BQML churn_probability joined daily |
| fct_renewal_pipeline | Full refresh | — | opportunity_pk | 180-day lookahead; weighted ARR |
| fct_csm_book_of_business | Full refresh | — | account_csm_pk | RLS via csm_owner; daily snapshot |
| fct_nrr_grr | Full refresh | — | nrr_pk | 24-month history; finance-restricted |
| fct_churn_events | Incremental | event_date | churn_event_pk | SF > ChurnZero dedup |
| fct_expansion_signals | Full refresh | — | signal_pk | 3 signal types; deactivated on close |

---

## New Tests Added

| Test | Model | Type |
|------|-------|------|
| assert_score_in_range(0,100) | dim_account_health.health_score | Custom generic |
| assert_customer_health_weights_sum | dim_account_health | Custom singular |
| assert_nrr_reasonable_range(-50, 200) | fct_nrr_grr.nrr | Custom generic |
| unique + not_null | All 6 warehouse PKs | Built-in |
| relationships → dim_account | All 6 warehouse models | Built-in |
| accepted_values(health_band) | dim_account_health | Built-in |
| accepted_values(churn_risk_band) | dim_account_health, fct_renewal_pipeline | Built-in |
| accepted_values(churn_type) | fct_churn_events | Built-in |
| not_null(csm_owner) | fct_csm_book_of_business | Built-in |

---

## Cross-Release Dependencies

| This Model | Depends On | Release |
|-----------|-----------|---------|
| int__account_health | dim_account_product_score | Release 04 (mart_product) |
| int__csm_book | fct_onboarding_funnel | Release 04 (mart_product) |
| dim_account_health | dim_account | Release 04 (mart_product) |
| All warehouse models | dim_account | Release 04 (mart_product) |
| All warehouse models | stg_salesforce__*, stg_zendesk__*, stg_intercom__*, stg_churnzero__* | Release 02 |

---

## File Locations

```
dbt/models/integration/
  int__account_health.sql
  int__renewal_pipeline.sql
  int__csm_book.sql

dbt/models/warehouse/core/
  dim_account_health.sql
  fct_renewal_pipeline.sql
  fct_csm_book_of_business.sql
  fct_nrr_grr.sql
  fct_churn_events.sql
  fct_expansion_signals.sql
```
