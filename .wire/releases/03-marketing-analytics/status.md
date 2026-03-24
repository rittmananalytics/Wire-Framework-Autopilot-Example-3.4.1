---
release_id: "20260324"
release_name: 03-marketing-analytics
release_type: full_platform
client_name: Core Dynamics
engagement_name: data_platform_modernisation
created_date: 2026-03-24
---

# Release Status: 03-marketing-analytics

## Overview
- **Client**: Core Dynamics
- **Engagement**: data_platform_modernisation
- **Release**: 03-marketing-analytics
- **Type**: full_platform
- **Created**: 2026-03-24

## Artifact Status

```yaml
requirements:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "requirements/requirements_specification.md"

workshops:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "design/workshop_agenda.md"
    - "design/workshop_decision_matrix.md"
  note: "Workshop materials generated as reference — no workshop conducted in Autopilot mode"

conceptual_model:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "design/conceptual_model.md"

pipeline_design:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "design/pipeline_architecture.md"

data_model:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "design/data_model_specification.md"

mockups:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "design/mockups/mockups_index.md"
    - "design/mockups/mockup_ma01_demand_gen.md"
    - "design/mockups/mockup_ma02_attribution.md"
    - "design/mockups/mockup_ma03_pipeline_contribution.md"

pipeline:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "dev/pipeline/README.md"
    - "dev/pipeline/dataform_workflow_config.md"
    - "dev/pipeline/dataform_run_dag_marketing_extension.py"

dbt:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "dev/dbt_models_summary.md"
    - "dbt/dbt_project.yml"
    - "dbt/models/integration/int__contacts__unified.sql"
    - "dbt/models/integration/int__marketing_touches__all_channels.sql"
    - "dbt/models/integration/int__campaign_spend__normalised.sql"
    - "dbt/models/integration/int__funnel_events__staged.sql"
    - "dbt/models/integration/int__opportunities__attributed.sql"
    - "dbt/models/warehouse/core/fct_lead_funnel_events.sql"
    - "dbt/models/warehouse/core/fct_campaign_spend.sql"
    - "dbt/models/warehouse/core/fct_attribution_touches.sql"
    - "dbt/models/warehouse/core/fct_opportunity_attribution.sql"
    - "dbt/models/warehouse/core/dim_campaign.sql"
    - "dbt/models/warehouse/core/dim_contact.sql"

semantic_layer:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "dev/semantic_layer/marketing.model.lkml"
    - "dev/semantic_layer/views/marketing/fct_lead_funnel_events.view.lkml"
    - "dev/semantic_layer/views/marketing/fct_campaign_spend.view.lkml"
    - "dev/semantic_layer/views/marketing/fct_attribution_touches.view.lkml"
    - "dev/semantic_layer/views/marketing/fct_opportunity_attribution.view.lkml"
    - "dev/semantic_layer/views/marketing/dim_campaign.view.lkml"
    - "dev/semantic_layer/views/marketing/dim_contact.view.lkml"

dashboards:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "dev/dashboards/ma01_demand_gen_performance.dashboard.lkml"
    - "dev/dashboards/ma02_attribution_explore_saved_views.md"
    - "dev/dashboards/ma03_pipeline_contribution.dashboard.lkml"

data_quality:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "test/data_quality_plan.md"

uat:
  generate: complete
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "test/uat_plan.md"

deployment:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  file: "deploy/deployment_runbook.md"

training:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "enablement/training_marketing_team_session_plan.md"
    - "enablement/training_marketing_team_slides.md"
    - "enablement/training_marketing_team_exercises.md"
    - "enablement/training_marketing_team_quick_reference.md"
    - "enablement/training_delivery_checklist.md"

documentation:
  generate: complete
  validate: pass
  review: approved
  reviewed_by: "Wire Autopilot (self-review)"
  reviewed_date: 2026-03-24
  files:
    - "enablement/documentation/architecture_guide.md"
    - "enablement/documentation/operations_guide.md"
    - "enablement/documentation/user_guide.md"
    - "enablement/documentation/glossary.md"
```
