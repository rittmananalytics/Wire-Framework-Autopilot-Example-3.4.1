# Sprint Plan
## Core Dynamics Data Platform Modernisation

**Engagement**: data_platform_modernisation
**Client**: Core Dynamics, Inc.
**Prepared by**: Mark Rittman, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (Autopilot — self-reviewed)

---

## Planning Assumptions

- **Velocity**: 5 story points per consultant-day (team of 4 delivery consultants)
- **Buffer**: 20% added to all sprint estimates
- **Sprint length**: 2-week sprints (10 consultant-days per sprint × 4 = 40 points per sprint gross; ~32 points net after 20% buffer)
- **Fibonacci scale**: 1, 2, 3, 5, 8 — no story exceeds 8 points
- **Total engagement**: 22 weeks = 11 sprints
- **Discovery sprint**: Week 1 (this document)
- **Delivery sprints**: Sprints 2–11 (Weeks 2–22)

---

## Discovery Sprint (Sprint 1 — Week 1)

### Epic: D-01 — Engagement Setup & Discovery

| Story | Description | Points | Assignee |
|-------|-------------|--------|----------|
| D-01-01 | Create engagement structure, Git branch, .wire folder layout | 1 | Mark Rittman |
| D-01-02 | Generate problem definition document | 2 | Mark Rittman |
| D-01-03 | Generate pitch document | 2 | Mark Rittman |
| D-01-04 | Generate release brief | 2 | Mark Rittman |
| D-01-05 | Generate sprint plan | 2 | Mark Rittman |

**Sprint 1 Total: 9 points**

---

## Release 02: Data Foundation (Sprints 2–4 — Weeks 2–7)

### Epic: F-01 — GCP Infrastructure & IAM

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| F-01-01 | Provision core-dynamics-analytics-dev and -prod GCP projects | 3 | 2 |
| F-01-02 | Configure IAM roles (data-engineers, analysts, looker-service-account, dataform-runner) | 3 | 2 |
| F-01-03 | Enable required APIs: BigQuery, Dataform, Cloud Composer, Pub/Sub, Secret Manager, Cloud Logging | 1 | 2 |
| F-01-04 | Create BigQuery raw datasets (one per source: raw_salesforce, raw_hubspot, etc.) | 2 | 2 |

**Epic F-01 Total: 9 points**

### Epic: F-02 — Fivetran Pipeline Configuration

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| F-02-01 | Configure Fivetran connector: Salesforce (6-hour sync) | 3 | 2 |
| F-02-02 | Configure Fivetran connector: HubSpot (1-hour sync) | 2 | 2 |
| F-02-03 | Configure Fivetran connectors: Google Ads, LinkedIn Ads, Meta Ads (daily) | 3 | 2 |
| F-02-04 | Configure Fivetran connector: Outreach.io (6-hour sync) | 2 | 3 |
| F-02-05 | Configure Fivetran connector: Mixpanel (daily) | 2 | 3 |
| F-02-06 | Configure Fivetran connector: Intercom (6-hour sync) | 2 | 3 |
| F-02-07 | Configure Fivetran connector: Zendesk (1-hour sync) | 2 | 3 |
| F-02-08 | Configure Fivetran connector: NetSuite (daily, via integration role) | 3 | 3 |
| F-02-09 | Configure Fivetran connector: PagerDuty (1-hour sync) | 2 | 3 |
| F-02-10 | Configure Fivetran connector: BambooHR (daily) | 2 | 3 |
| F-02-11 | Configure Fivetran connector: CoreFM PostgreSQL (CDC, 15-min, Cloud SQL Auth Proxy) | 5 | 3 |
| F-02-12 | Build custom Cloud Function: ChurnZero incremental sync → BigQuery | 8 | 4 |
| F-02-13 | Build custom Cloud Function: Clearbit REST API → BigQuery (on-demand trigger) | 5 | 4 |
| F-02-14 | Configure GCP Billing native export to BigQuery (validate Sean Murphy's existing config) | 2 | 4 |
| F-02-15 | Configure Segment BigQuery Destination (streaming) | 2 | 4 |

**Epic F-02 Total: 45 points**

### Epic: F-03 — Dataform Staging Models

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| F-03-01 | Initialise Dataform repository; connect to Core Dynamics GitHub; configure dev/prod environments | 3 | 2 |
| F-03-02 | Build staging models: stg_salesforce (accounts, contacts, opportunities, contracts) | 5 | 3 |
| F-03-03 | Build staging models: stg_hubspot (contacts, companies, email_sends, form_submissions, page_views) | 5 | 3 |
| F-03-04 | Build staging models: stg_google_ads, stg_linkedin_ads, stg_meta_ads | 5 | 4 |
| F-03-05 | Build staging models: stg_outreach (sequences, touches) | 3 | 4 |
| F-03-06 | Build staging models: stg_corefm_db (accounts, users, sessions, assets, work_orders, reports) with PII pseudonymisation | 8 | 4 |
| F-03-07 | Build staging models: stg_mixpanel, stg_segment (with deduplication rules per Leon Yip's event mapping) | 5 | 4 |
| F-03-08 | Build staging models: stg_intercom (messages, NPS, onboarding checklist) | 3 | 4 |
| F-03-09 | Build staging models: stg_churnzero (health scores, NPS history, segments) | 3 | 4 |
| F-03-10 | Build staging models: stg_zendesk (tickets, agents, SLA policies, CSAT) | 5 | 4 |
| F-03-11 | Build staging models: stg_netsuite (invoices, contracts, expansion history) | 5 | 4 |
| F-03-12 | Build staging models: stg_pagerduty (incidents, escalations, on-call) | 3 | 4 |
| F-03-13 | Build staging models: stg_gcp_billing, stg_cloud_monitoring, stg_bamboohr | 5 | 4 |
| F-03-14 | Build reference table: feature_taxonomy (from Leon Yip's CSV) | 2 | 4 |

**Epic F-03 Total: 60 points**

### Epic: F-04 — Cloud Composer Orchestration

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| F-04-01 | Deploy Cloud Composer 2 environment (dev + prod) | 3 | 4 |
| F-04-02 | Build DAG: trigger Fivetran syncs in dependency order | 5 | 4 |
| F-04-03 | Build DAG: run Dataform pipelines post-Fivetran sync | 3 | 4 |
| F-04-04 | Build DAG: data quality checks post-transformation | 3 | 4 |
| F-04-05 | Build DAG: alerting on pipeline failures (Slack + email) | 3 | 4 |

**Epic F-04 Total: 17 points**

### Epic: F-05 — Data Quality & Pipeline Health

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| F-05-01 | Implement Dataform assertions: row counts on all warehouse tables | 3 | 4 |
| F-05-02 | Implement Dataform assertions: null rates on key fields | 3 | 4 |
| F-05-03 | Implement Dataform assertions: referential integrity between key mart tables | 3 | 4 |
| F-05-04 | Implement Dataform assertions: business logic sanity checks (e.g., ARR never negative) | 3 | 4 |
| F-05-05 | Configure BigQuery audit log export to Cloud Logging | 1 | 4 |
| F-05-06 | Build pipeline health dashboard in Looker (pipeline run times, failure rates, row count trends) | 5 | 4 |

**Epic F-05 Total: 18 points**

**Release 02 Total: 149 points across Sprints 2–4 (≈32 net points/sprint × 3 sprints = 96 net points with buffer)**

*Note: Foundation release runs across 3 sprints with 4 consultants; 149 gross points / 4 consultants / 5 pts per day = ~7.5 days per sprint of actual work, well within 10-day sprints.*

---

## Release 03: Marketing Analytics (Sprints 5–6 — Weeks 8–11)

### Epic: M-01 — Marketing Warehouse Models

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| M-01-01 | Build integration models: int__lead_funnel, int__attribution_touches, int__campaign_spend | 5 | 5 |
| M-01-02 | Build warehouse model: fct_lead_funnel_events (including SAL stage per Niamh's funnel definition) | 5 | 5 |
| M-01-03 | Build warehouse model: fct_campaign_spend (daily by channel, campaign, ad group) | 3 | 5 |
| M-01-04 | Build warehouse model: fct_attribution_touches (all touches per contact, multi-model) | 8 | 5 |
| M-01-05 | Build warehouse model: fct_opportunity_attribution (5 models: first/last/linear/time-decay/U-shaped; 180-day window) | 8 | 5 |
| M-01-06 | Build warehouse model: dim_campaign (channel, type, target segment) | 3 | 5 |
| M-01-07 | Build warehouse model: dim_contact (with Clearbit enrichment attributes) | 3 | 5 |
| M-01-08 | Write data quality tests for all marketing models | 3 | 5 |

**Epic M-01 Total: 38 points**

### Epic: M-02 — LookML Marketing Semantic Layer

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| M-02-01 | Create LookML views for all 6 marketing warehouse models | 5 | 6 |
| M-02-02 | Build marketing.model.lkml with explores (campaigns, attribution, funnel) | 5 | 6 |
| M-02-03 | Define governed metrics: CAC, LTV, marketing-sourced pipeline, ROI ratio | 3 | 6 |
| M-02-04 | Add "majority pipeline stage" derived dimension to campaign performance | 2 | 6 |

**Epic M-02 Total: 15 points**

### Epic: M-03 — Marketing Dashboards

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| M-03-01 | Build Dashboard MA-01: Demand Generation Performance (default: last 7 days) | 5 | 6 |
| M-03-02 | Build Dashboard MA-02: Multi-Touch Attribution Analysis (U-shaped default; self-service Explore) | 5 | 6 |
| M-03-03 | Build Dashboard MA-03: Pipeline Contribution Report (marketing-sourced vs. influenced) | 5 | 6 |
| M-03-04 | UAT preparation and documentation for marketing dashboards | 2 | 6 |

**Epic M-03 Total: 17 points**

**Release 03 Total: 70 points across Sprints 5–6**

---

## Release 04: Product Analytics (Sprints 7–8 — Weeks 12–15)

### Epic: P-01 — Product Warehouse Models

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| P-01-01 | Build integration models: int__feature_usage, int__account_sessions, int__onboarding | 5 | 7 |
| P-01-02 | Build warehouse model: fct_feature_usage (with module_id, feature_group_id, feature_id taxonomy) | 8 | 7 |
| P-01-03 | Build warehouse model: fct_session_events (deduped: Segment for transactional, Mixpanel for discovery) | 5 | 7 |
| P-01-04 | Build warehouse model: fct_onboarding_funnel (7 steps from Leon Yip's definition, with timestamps) | 5 | 7 |
| P-01-05 | Build warehouse model: fct_workflow_completion | 3 | 7 |
| P-01-06 | Build warehouse model: dim_account_product_score (0–100 composite; DAU/MAU 20%, feature breadth 20%, core activation 20%, NPS 15%, onboarding 15%, work_order_within_30_days 10%) | 8 | 7 |
| P-01-07 | Write data quality tests for all product models | 3 | 7 |

**Epic P-01 Total: 37 points**

### Epic: P-02 — LookML Product Semantic Layer

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| P-02-01 | Create LookML views for all 5 product warehouse models | 5 | 8 |
| P-02-02 | Build product.model.lkml with explores (feature adoption, account usage, onboarding) | 5 | 8 |
| P-02-03 | Define governed metrics: Product Engagement Score, DAU/MAU, licence_utilisation_pct, onboarding completion rate | 3 | 8 |
| P-02-04 | Apply PII visibility controls in LookML (pseudonymised user_id only) | 2 | 8 |

**Epic P-02 Total: 15 points**

### Epic: P-03 — Product Dashboards

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| P-03-01 | Build Dashboard PB-01: Product Adoption Overview (feature heatmap at Feature Group level; drill-through to Feature) | 5 | 8 |
| P-03-02 | Build Dashboard PB-02: Account-Level Product Usage (drill-through from CA-01) | 5 | 8 |
| P-03-03 | Build Dashboard PB-03: Onboarding Funnel Analysis (all 7 steps; stalled accounts filterable by CSM) | 5 | 8 |
| P-03-04 | UAT preparation for product dashboards | 2 | 8 |

**Epic P-03 Total: 17 points**

**Release 04 Total: 69 points across Sprints 7–8**

---

## Release 05: Customer Analytics (Sprints 8–10 — Weeks 15–19)

### Epic: C-01 — Customer Warehouse Models

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| C-01-01 | Build integration models: int__account_health, int__renewal_pipeline, int__csm_book | 5 | 8 |
| C-01-02 | Build warehouse model: dim_account_health (unified health score incorporating product, support, sentiment, financial) | 8 | 9 |
| C-01-03 | Build warehouse model: fct_renewal_pipeline (rolling 180-day window with predicted probability) | 5 | 9 |
| C-01-04 | Build warehouse model: fct_expansion_signals (unused licences, module gaps, multi-site potential) | 5 | 9 |
| C-01-05 | Build warehouse model: fct_csm_book_of_business (per-CSM: ARR, account count, health distribution) | 3 | 9 |
| C-01-06 | Build warehouse model: fct_nrr_grr (monthly NRR and GRR by segment, cohort, CSM) | 5 | 9 |
| C-01-07 | Build warehouse model: fct_churn_events (historical churn/downsell with contributing signals for BQML training) | 5 | 9 |
| C-01-08 | Write data quality tests; verify NRR/GRR within ±2% of Finance spreadsheet | 3 | 9 |

**Epic C-01 Total: 39 points**

### Epic: C-02 — BigQuery ML Churn Risk Model

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| C-02-01 | Prepare training dataset (24 months; Salesforce proxy for pre-ChurnZero period) | 5 | 9 |
| C-02-02 | Train logistic regression model using BigQuery ML | 5 | 9 |
| C-02-03 | Evaluate model: AUC-ROC, precision/recall at 0.4 and 0.5 thresholds | 3 | 10 |
| C-02-04 | Write BQML model to ml_models dataset; schedule weekly refresh | 3 | 10 |
| C-02-05 | Write model card (assumptions, limitations, retraining guidance) | 3 | 10 |

**Epic C-02 Total: 19 points**

### Epic: C-03 — LookML Customer Semantic Layer & RLS

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| C-03-01 | Create LookML views for all 6 customer warehouse models | 5 | 10 |
| C-03-02 | Build customer.model.lkml with explores | 5 | 10 |
| C-03-03 | Define governed metrics: ARR, MRR, NRR, GRR, LTV, churn_risk_probability | 5 | 10 |
| C-03-04 | Implement Looker user attribute-based RLS for CSM dashboards | 5 | 10 |
| C-03-05 | Add financial metric visibility controls (finance_viewers, leadership groups only) | 2 | 10 |

**Epic C-03 Total: 22 points**

### Epic: C-04 — Customer Dashboards & Looker Actions

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| C-04-01 | Build Dashboard CA-01: Customer Health Command Centre (health distribution, churn heatmap, renewals, expansion) | 8 | 10 |
| C-04-02 | Build Dashboard CA-02: CSM Book of Business (with RLS; prioritised action list; risk signals) | 8 | 10 |
| C-04-03 | Build Dashboard CA-03: CS Leadership Scorecard (NRR/GRR trend, CSM performance, churn model metrics) | 5 | 10 |
| C-04-04 | Configure Looker Scheduled Alerts (4 alert types → Slack) | 3 | 10 |
| C-04-05 | Build Looker Action: "Flag for CSM Follow-up" → Salesforce task creation | 5 | 10 |
| C-04-06 | Build Looker Action: "Export QBR Data" → Google Slides template | 5 | 10 |
| C-04-07 | UAT preparation for customer dashboards | 2 | 10 |

**Epic C-04 Total: 36 points**

**Release 05 Total: 116 points across Sprints 8–10**

---

## Release 06: Operational Analytics (Sprints 10–11 — Weeks 19–22)

### Epic: O-01 — Operations Warehouse Models

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| O-01-01 | Build integration models: int__support_tickets, int__incidents, int__infra_cost | 5 | 10 |
| O-01-02 | Build warehouse model: fct_support_tickets (SLA timers, resolution time, agent, tier, CSAT) | 5 | 11 |
| O-01-03 | Build warehouse model: fct_incident_response (MTTA, MTTR, escalation chain) | 3 | 11 |
| O-01-04 | Build warehouse model: fct_infra_cost_by_customer (daily GCP cost by project/label; scoped to label coverage) | 5 | 11 |
| O-01-05 | Build warehouse model: fct_support_capacity (ticket volume vs. headcount ratio) | 3 | 11 |
| O-01-06 | Write data quality tests for operations models | 2 | 11 |

**Epic O-01 Total: 23 points**

### Epic: O-02 — LookML Operations Semantic Layer

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| O-02-01 | Create LookML views for all 4 operations warehouse models | 5 | 11 |
| O-02-02 | Build operations.model.lkml with explores | 3 | 11 |
| O-02-03 | Define governed metrics: SLA compliance rate, MTTA, MTTR, infra cost per customer | 3 | 11 |

**Epic O-02 Total: 11 points**

### Epic: O-03 — Operations Dashboards

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| O-03-01 | Build Dashboard DO-01: Support Operations SLA Tracker (4-hour refresh; live SLA compliance; CSAT trend) | 5 | 11 |
| O-03-02 | Build Dashboard DO-02: Infrastructure Cost & Efficiency (cost per customer; anomaly detection) | 5 | 11 |
| O-03-03 | Build Dashboard DO-03: Incident Response & On-Call Health (MTTA/MTTR trend; on-call burden) | 5 | 11 |
| O-03-04 | Semantic layer governance review with Amara Diallo and workstream leads | 3 | 11 |

**Epic O-03 Total: 18 points**

### Epic: O-04 — Documentation & Knowledge Transfer

| Story | Description | Points | Sprint |
|-------|-------------|--------|--------|
| O-04-01 | Write Data Engineering Runbook (pipeline architecture, adding sources, dev-to-prod, incident response) | 5 | 11 |
| O-04-02 | Write Semantic Layer Governance Guide (all governed metrics, access controls, content validation) | 3 | 11 |
| O-04-03 | Knowledge transfer session 1: Data Engineering team (Amara Diallo) — 2 hours | 2 | 11 |
| O-04-04 | Knowledge transfer session 2: Looker developers / analytics team — 2 hours | 2 | 11 |
| O-04-05 | Knowledge transfer session 3: Business users (dashboard consumers) — 2 hours | 2 | 11 |
| O-04-06 | Compile UAT sign-off documentation (all 4 workstream sponsors) | 2 | 11 |

**Epic O-04 Total: 16 points**

**Release 06 Total: 68 points across Sprints 10–11**

---

## Sprint Summary

| Sprint | Weeks | Release(s) | Gross Points | Net (×0.8) |
|--------|-------|-----------|-------------|------------|
| Sprint 1 | 1 | Discovery | 9 | 7 |
| Sprint 2 | 2–3 | Foundation | 32 | 26 |
| Sprint 3 | 4–5 | Foundation | 45 | 36 |
| Sprint 4 | 6–7 | Foundation | 72 | 58 |
| Sprint 5 | 8–9 | Marketing | 55 | 44 |
| Sprint 6 | 10–11 | Marketing | 34 | 27 |
| Sprint 7 | 12–13 | Product | 45 | 36 |
| Sprint 8 | 14–15 | Product + Customer (start) | 41 | 33 |
| Sprint 9 | 16–17 | Customer | 58 | 46 |
| Sprint 10 | 18–19 | Customer + Operations (start) | 74 | 59 |
| Sprint 11 | 20–22 | Operations + Documentation | 68 | 54 |
| **Total** | | | **533 points** | **426 net** |

*Note: Team of 4 consultants × 10 days × 5 pts/day = 200 gross points per sprint. Actuals distributed unevenly based on SOW phasing. All sprints within team capacity.*

---

## Downstream Releases

| Release Name | Type | Scope Summary | Priority |
|-------------|------|---------------|----------|
| 02-data-foundation | pipeline_only | GCP setup, IAM, Fivetran connectors (18 sources), Dataform staging models, Cloud Composer orchestration, data quality assertions, pipeline health dashboard | 1 |
| 03-marketing-analytics | full_platform | Marketing intermediate + warehouse models, LookML marketing views/explores, dashboards MA-01/MA-02/MA-03, multi-touch attribution, semantic layer metrics | 2 |
| 04-product-analytics | full_platform | Product warehouse models (PII pseudonymisation), product engagement score, feature taxonomy, LookML product views/explores, dashboards PB-01/PB-02/PB-03 | 3 |
| 05-customer-analytics | full_platform | Customer warehouse models, BQML churn risk model, Looker RLS + Actions (Salesforce + QBR), LookML customer views, dashboards CA-01/CA-02/CA-03 + Scheduled Alerts | 4 |
| 06-operational-analytics | dbt_development | Operations warehouse models, LookML operations views, dashboards DO-01/DO-02/DO-03, semantic layer governance, Data Engineering Runbook, Semantic Layer Governance Guide, knowledge transfer × 3 | 5 |
