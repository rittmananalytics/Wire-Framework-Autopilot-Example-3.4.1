# dbt Models Summary — Operational Analytics
## Release: 06-operational-analytics

**Generated**: 2026-03-25
**Dataset**: mart_operations

---

## Model Counts

| Layer | Count | Models |
|-------|-------|--------|
| Staging (new) | 2 | stg_pagerduty__incidents, stg_gcp__billing_export |
| Warehouse | 4 | fct_support_tickets, fct_incident_response, fct_infra_cost_by_customer, fct_support_capacity |
| **Total new** | **6** | |

---

## Warehouse Layer

| Model | Materialisation | Partition | Unique Key | Notes |
|-------|----------------|-----------|------------|-------|
| fct_support_tickets | Incremental | created_date | ticket_pk | SLA flags; cross-release account join |
| fct_incident_response | Incremental | created_date | incident_pk | Weekly correlation field for DO-02 |
| fct_infra_cost_by_customer | Full refresh | — | cost_pk | Finance-restricted; proportional attribution |
| fct_support_capacity | Full refresh | — | capacity_pk | CSM × month; tickets per account |

---

## File Locations

```
dbt/models/warehouse/core/
  fct_support_tickets.sql
  fct_incident_response.sql
  fct_infra_cost_by_customer.sql
  fct_support_capacity.sql
```

## Cross-Release Dependencies

| This Model | Depends On | Release |
|-----------|-----------|---------|
| fct_support_tickets | stg_zendesk__tickets, stg_salesforce__accounts | Release 02 |
| fct_support_capacity | fct_support_tickets, stg_salesforce__accounts | Release 02 + R06 self |
| fct_infra_cost_by_customer | stg_salesforce__accounts, stg_gcp__billing_export | Release 02 + new |
| fct_incident_response | stg_pagerduty__incidents, stg_zendesk__tickets | New + Release 02 |
