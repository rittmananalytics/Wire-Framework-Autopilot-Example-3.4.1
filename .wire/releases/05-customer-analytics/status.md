---
release_id: "20260324"
release_name: 05-customer-analytics
release_type: full_platform
client_name: Core Dynamics
engagement_name: data_platform_modernisation
created_date: 2026-03-24
---

# Release Status: 05-customer-analytics

## Overview
- **Client**: Core Dynamics
- **Engagement**: data_platform_modernisation
- **Release**: 05-customer-analytics
- **Type**: full_platform
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

workshops:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "design/workshop_agenda.md"
    - "design/workshop_decision_matrix.md"
  note: "Workshop materials generated as reference — no workshop conducted in Autopilot mode"

conceptual_model:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "design/conceptual_model.md"

pipeline_design:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "design/pipeline_architecture.md"

data_model:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "design/data_model_specification.md"

mockups:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "design/mockups/mockups_index.md"
    - "design/mockups/mockup_ca01_customer_health.md"
    - "design/mockups/mockup_ca02_csm_book.md"
    - "design/mockups/mockup_ca03_cs_scorecard.md"

pipeline:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/pipeline/dataform_run_dag_customer_extension.py"

dbt:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/dbt_models_summary.md"
    - "dbt/models/integration/int__account_health.sql"
    - "dbt/models/integration/int__renewal_pipeline.sql"
    - "dbt/models/integration/int__csm_book.sql"
    - "dbt/models/warehouse/core/dim_account_health.sql"
    - "dbt/models/warehouse/core/fct_renewal_pipeline.sql"
    - "dbt/models/warehouse/core/fct_csm_book_of_business.sql"
    - "dbt/models/warehouse/core/fct_nrr_grr.sql"
    - "dbt/models/warehouse/core/fct_churn_events.sql"
    - "dbt/models/warehouse/core/fct_expansion_signals.sql"

semantic_layer:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/semantic_layer/customer.model.lkml"
    - "dev/semantic_layer/views/customer/dim_account_health.view.lkml"
    - "dev/semantic_layer/views/customer/fct_renewal_pipeline.view.lkml"
    - "dev/semantic_layer/views/customer/fct_csm_book_of_business.view.lkml"
    - "dev/semantic_layer/views/customer/fct_nrr_grr.view.lkml"
    - "dev/semantic_layer/views/customer/fct_churn_events.view.lkml"

dashboards:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/dashboards/ca01_customer_health.dashboard.lkml"
    - "dev/dashboards/ca02_csm_book.dashboard.lkml"
    - "dev/dashboards/ca03_cs_scorecard.dashboard.lkml"

data_quality:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "test/data_quality_plan.md"

uat:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "test/uat_plan.md"

deployment:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  file: "deploy/deployment_runbook.md"

training:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "enablement/training_cs_team_session_plan.md"
    - "enablement/training_cs_team_quick_reference.md"

documentation:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "enablement/documentation/architecture_guide.md"
```
