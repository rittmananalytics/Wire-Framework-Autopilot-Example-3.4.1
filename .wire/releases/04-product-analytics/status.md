---
release_id: "20260324"
release_name: 04-product-analytics
release_type: full_platform
client_name: Core Dynamics
engagement_name: data_platform_modernisation
created_date: 2026-03-24
---

# Release Status: 04-product-analytics

## Overview
- **Client**: Core Dynamics
- **Engagement**: data_platform_modernisation
- **Release**: 04-product-analytics
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
    - "design/mockups/mockup_pb01_product_adoption.md"
    - "design/mockups/mockup_pb02_account_usage.md"
    - "design/mockups/mockup_pb03_onboarding_funnel.md"

pipeline:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/pipeline/dataform_run_dag_product_extension.py"

dbt:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/dbt_models_summary.md"
    - "dbt/models/integration/int__feature_usage.sql"
    - "dbt/models/integration/int__account_sessions.sql"
    - "dbt/models/integration/int__onboarding.sql"
    - "dbt/models/warehouse/core/fct_feature_usage.sql"
    - "dbt/models/warehouse/core/fct_session_events.sql"
    - "dbt/models/warehouse/core/fct_onboarding_funnel.sql"
    - "dbt/models/warehouse/core/fct_workflow_completion.sql"
    - "dbt/models/warehouse/core/dim_account.sql"
    - "dbt/models/warehouse/core/dim_account_product_score.sql"

semantic_layer:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/semantic_layer/product.model.lkml"
    - "dev/semantic_layer/views/product/fct_feature_usage.view.lkml"
    - "dev/semantic_layer/views/product/dim_account.view.lkml"
    - "dev/semantic_layer/views/product/dim_account_product_score.view.lkml"
    - "dev/semantic_layer/views/product/fct_onboarding_funnel.view.lkml"

dashboards:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "dev/dashboards/pb01_product_adoption.dashboard.lkml"
    - "dev/dashboards/pb02_account_usage.dashboard.lkml"
    - "dev/dashboards/pb03_onboarding_funnel.dashboard.lkml"

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
    - "enablement/training_product_team_session_plan.md"
    - "enablement/training_product_team_quick_reference.md"

documentation:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-25
  files:
    - "enablement/documentation/architecture_guide.md"
```
