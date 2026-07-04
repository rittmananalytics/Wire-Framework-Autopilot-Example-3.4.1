# Semantic Layer Summary — Operational Analytics
## Release: 06-operational-analytics

**Model file**: `operations.model.lkml`
**Dataset**: mart_operations

## Explores

| Explore | Primary View | Joins | Dashboards |
|---------|-------------|-------|-----------|
| support_ops | fct_support_tickets | → dim_account, → fct_support_capacity | DO-01 |
| incident_response | fct_incident_response | (standalone) | DO-02 |
| infra_cost | fct_infra_cost_by_customer | → dim_account | DO-03 |

## Key LookML Patterns

### Financial Metric Restriction (DO-03)
```lkml
measure: total_cost_usd {
  type: sum
  sql: ${TABLE}.cost_usd ;;
  value_format_name: usd_0
  required_access_grants: [finance_viewers, leadership]
}
```

### SLA Compliance Rate
```lkml
measure: sla_compliance_pct {
  type: number
  sql: 100.0 * COUNTIF(${is_within_sla}) / NULLIF(COUNT(*), 0) ;;
  value_format_name: decimal_1
  label: "SLA Compliance %"
}
```

### MTTR Average
```lkml
measure: avg_resolution_hours {
  type: average
  sql: ${TABLE}.resolution_hours ;;
  value_format_name: decimal_1
  label: "Avg Resolution (Hours)"
}
```

## LookML Files Generated
- `operations.model.lkml`
- `views/operations/fct_support_tickets.view.lkml`
- `views/operations/fct_incident_response.view.lkml`
- `views/operations/fct_infra_cost_by_customer.view.lkml`
- `views/operations/fct_support_capacity.view.lkml`
