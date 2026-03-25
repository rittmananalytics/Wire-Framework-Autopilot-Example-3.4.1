---
release_id: "20260324"
release_name: 06-operational-analytics
release_type: dbt_development
client_name: Core Dynamics
engagement_name: data_platform_modernisation
created_date: 2026-03-24
---

# Release Status: 06-operational-analytics

## Overview
- **Client**: Core Dynamics
- **Engagement**: data_platform_modernisation
- **Release**: 06-operational-analytics
- **Type**: dbt_development
- **Created**: 2026-03-24

## Artifact Status

```yaml
requirements:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "requirements/requirements_specification.md"

data_model:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "design/data_model_specification.md"

dbt:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/dbt_models_summary.md"
    - "dbt/models/warehouse/core/fct_support_tickets.sql"
    - "dbt/models/warehouse/core/fct_incident_response.sql"
    - "dbt/models/warehouse/core/fct_infra_cost_by_customer.sql"
    - "dbt/models/warehouse/core/fct_support_capacity.sql"

semantic_layer:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/semantic_layer_summary.md"

data_quality:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "test/data_quality_plan.md"

deployment:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "deploy/deployment_runbook.md"
```
