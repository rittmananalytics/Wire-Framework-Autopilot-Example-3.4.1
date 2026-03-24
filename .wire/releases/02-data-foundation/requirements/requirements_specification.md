# Requirements Specification
## Release: 02-data-foundation
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Release**: 02-data-foundation
**Type**: pipeline_only
**Prepared by**: Wire Autopilot (Mark Rittman, Rittman Analytics)
**Date**: 2026-03-24
**Version**: 1.0

---

## 1. Executive Summary

This document specifies the requirements for the data foundation release of the Core Dynamics Data Platform Modernisation engagement. The foundation release establishes the Google Cloud infrastructure, ELT pipelines, Dataform transformation layer, Cloud Composer orchestration, and data quality framework that all subsequent analytics workstreams depend upon.

Core Dynamics has no centralised data infrastructure today. All pipelines are ad-hoc scripts or Google Sheets imports. Before any analytics workstream can be delivered, a robust, governed, and scalable foundation must be in place. This release delivers that foundation: raw data from 18 source systems landing reliably in BigQuery, transformed through a three-layer Dataform model, orchestrated by Cloud Composer, and validated through automated data quality assertions.

This release corresponds to Phase 1 of the SOW (Weeks 1–4) and the beginning of Phase 2, covering deliverables D-01 through D-06.

---

## 2. Business Context

Core Dynamics, Inc. ($38.4M ARR, 312 enterprise accounts) sells CoreFM — a B2B SaaS facility and asset management platform. The company has a board-mandated target to improve NRR from 104% to 115% within 18 months. This target requires reliable, automated data pipelines as a prerequisite for all analytics work.

**Current state pain points:**
- No data warehouse; no transformation layer; no monitoring
- Pipelines are ad-hoc scripts running on developer laptops or scheduled Google Sheets imports
- The single data analyst spends 60% of his time on manual CSV exports and VLOOKUP reconciliations
- MRR figures differ by up to 8% between teams due to inconsistent data sources

**Desired outcomes for this release:**
- All 18 source systems landing raw data in BigQuery on defined schedules with < 0.1% error rate
- Three-layer Dataform model (staging → intermediate → warehouse-ready) for all sources
- Cloud Composer orchestrating pipeline runs with automated alerting on failure
- Data quality assertions passing for 3 consecutive daily runs before milestone sign-off
- Pipeline health dashboard visible to Amara Diallo and engineering team

---

## 3. Stakeholders

| Name | Role | Department | Involvement |
|------|------|-----------|-------------|
| Amara Diallo | Data Engineering Lead (Primary Technical Contact) | Engineering | Approver — Phase 1 milestone sign-off |
| Priya Nair | CTO, Executive Sponsor | Technology | Executive oversight |
| Sean Murphy | Platform Engineering | Engineering | GCP infrastructure; CoreFM PostgreSQL access; GCP Billing |
| Kofi Asante | Data Engineer | Rittman Analytics | Builder — pipelines, staging models |
| Sophie Tanner | Senior Analytics Engineer | Rittman Analytics | Builder — Dataform conventions, data quality |
| Daniel Osei | Project Manager | Rittman Analytics | Coordination; access provisioning tracking |
| Greg Fontaine | VP Sales | Sales | Salesforce API user provisioning |
| Niamh Collins | Marketing Ops Manager | Marketing | HubSpot connector credentials |
| Owen Brady | Demand Gen Manager | Marketing | Google Ads, LinkedIn Ads, Meta Ads credentials |
| Sandra Kowalski | CFO | Finance | NetSuite integration role provisioning |
| Ben Tran | CS Ops Manager | Customer Success | ChurnZero API access |
| Carlos Vega | Head of Support Engineering | Operations | Zendesk CSAT export; PagerDuty admin |
| Leon Yip | Senior PM | Product | Mixpanel + Segment credentials; feature_taxonomy CSV |
| Mei Lin | HR & People Ops | HR | BambooHR credentials |

---

## 4. Functional Requirements

### FR-001: GCP Project Provisioning
**Description**: Provision two dedicated GCP projects for analytics:
- `core-dynamics-analytics-prod` (production analytics)
- `core-dynamics-analytics-dev` (development and testing)
**Acceptance Criteria**: Both projects exist and are accessible to Rittman Analytics service accounts.

### FR-002: IAM Configuration
**Description**: Configure IAM roles following least-privilege principles across both projects.
Required roles: `data-engineers`, `analysts`, `looker-service-account`, `dataform-runner`.
**Acceptance Criteria**: All four role definitions exist; Rittman Analytics team members assigned to `data-engineers`; Looker service account assigned to `looker-service-account`; no overly permissive Owner/Editor assignments on prod project.

### FR-003: GCP API Enablement
**Description**: Enable all required GCP APIs: BigQuery, Dataform, Cloud Composer, Pub/Sub, Secret Manager, Cloud Logging.
**Acceptance Criteria**: All six APIs enabled on both dev and prod projects.

### FR-004: BigQuery Raw Dataset Architecture
**Description**: Create one raw BigQuery dataset per source system, named `raw_<source>` per the Appendix A architecture in the SOW.
**Required datasets**: raw_salesforce, raw_hubspot, raw_google_ads, raw_linkedin_ads, raw_meta_ads, raw_outreach, raw_corefm_db, raw_mixpanel, raw_segment, raw_intercom, raw_churnzero, raw_zendesk, raw_netsuite, raw_pagerduty, raw_gcp_billing, raw_bamboohr.
**Acceptance Criteria**: All 16 raw datasets exist in both dev and prod projects with appropriate IAM bindings.

### FR-005: Fivetran Standard Connector Configuration
**Description**: Configure Fivetran connectors for all standard-connector sources (15 sources).
**Sources and sync frequencies**:
- Salesforce → raw_salesforce (every 6 hours)
- HubSpot → raw_hubspot (every 1 hour)
- Google Ads → raw_google_ads (daily, 3am UTC)
- LinkedIn Ads → raw_linkedin_ads (daily, 3am UTC)
- Meta Ads → raw_meta_ads (daily, 3am UTC)
- Outreach.io → raw_outreach (every 6 hours)
- CoreFM PostgreSQL (CDC) → raw_corefm_db (near real-time, 15 min, via Cloud SQL Auth Proxy)
- Mixpanel → raw_mixpanel (daily, 4am UTC)
- Intercom → raw_intercom (every 6 hours)
- Zendesk → raw_zendesk (every 1 hour)
- NetSuite → raw_netsuite (daily, 5am UTC)
- PagerDuty → raw_pagerduty (every 1 hour)
- BambooHR → raw_bamboohr (daily, 5am UTC)
**Acceptance Criteria**: All connectors sync successfully for 7 consecutive days; < 0.1% error rate; connector configuration documented.

### FR-006: Segment BigQuery Destination
**Description**: Configure Segment BigQuery Destination (streaming) to land event data in `raw_segment`.
**Acceptance Criteria**: Events flow from Segment to raw_segment within 5 minutes of occurrence.

### FR-007: ChurnZero Custom Cloud Function
**Description**: Build a custom Cloud Function using the ChurnZero REST API with incremental sync logic, landing data in `raw_churnzero`. ChurnZero has no native Fivetran connector.
**Sync objects**: health score history, NPS scores, health score events, account segment assignments.
**Schedule**: Daily at 6am UTC.
**Acceptance Criteria**: Function runs successfully on schedule; incremental sync prevents duplicates; error handling alerts on failure; code documented for Amara Diallo's team to maintain.

### FR-008: Clearbit Enrichment Cloud Function
**Description**: Build a Cloud Function triggered by HubSpot webhook (on new inbound lead creation) to call the Clearbit REST API and land enrichment data in `raw_clearbit` (within raw_hubspot dataset or a dedicated dataset).
**Acceptance Criteria**: Function triggers correctly on new lead webhook; Clearbit API call succeeds for valid domains; enrichment data available within 5 minutes of lead creation.

### FR-009: GCP Billing Export Formalisation
**Description**: Validate and formalise the existing GCP Billing native export to BigQuery (Sean Murphy has partially configured this). Ensure data lands in `raw_gcp_billing` on daily schedule.
**Acceptance Criteria**: Billing data available in BigQuery for T-1 day; label coverage for customer attribution audited and documented.

### FR-010: Dataform Repository Initialisation
**Description**: Initialise a Dataform repository connected to the Core Dynamics GitHub organisation. Configure dev and prod environments pointing to respective GCP projects.
**Acceptance Criteria**: Repository exists in GitHub; dev environment connects to core-dynamics-analytics-dev; prod environment connects to core-dynamics-analytics-prod; CI/CD workflow configured for promoting changes.

### FR-011: Dataform Staging Models — All Sources
**Description**: Build staging models for all in-scope source systems with column-level documentation, data type casting, and field renaming to snake_case.
**Required staging models**:
- stg_salesforce__accounts, stg_salesforce__contacts, stg_salesforce__opportunities, stg_salesforce__contracts, stg_salesforce__campaigns
- stg_hubspot__contacts, stg_hubspot__companies, stg_hubspot__form_submissions, stg_hubspot__email_sends, stg_hubspot__page_views
- stg_google_ads__campaigns, stg_google_ads__ad_groups, stg_google_ads__ads, stg_google_ads__keywords
- stg_linkedin_ads__campaigns, stg_linkedin_ads__creatives
- stg_meta_ads__campaigns, stg_meta_ads__ad_sets, stg_meta_ads__ads
- stg_outreach__sequences, stg_outreach__mailings, stg_outreach__calls
- stg_corefm_db__accounts, stg_corefm_db__users (PII pseudonymised), stg_corefm_db__sessions, stg_corefm_db__feature_events, stg_corefm_db__work_orders, stg_corefm_db__assets, stg_corefm_db__reports
- stg_mixpanel__events
- stg_segment__events (deduped per Leon Yip's event-to-source mapping)
- stg_intercom__conversations, stg_intercom__surveys (NPS), stg_intercom__checklist_completions
- stg_churnzero__health_scores, stg_churnzero__nps
- stg_zendesk__tickets, stg_zendesk__ticket_comments, stg_zendesk__satisfaction_ratings
- stg_netsuite__invoices, stg_netsuite__transactions
- stg_pagerduty__incidents, stg_pagerduty__escalation_policies, stg_pagerduty__on_call
- stg_gcp_billing__usage_and_costs
- stg_bamboohr__employees, stg_bamboohr__departments
**Acceptance Criteria**: All staging models build without errors; column-level documentation complete; data types cast correctly; surrogate keys generated; PII fields pseudonymised in stg_corefm_db__users.

### FR-012: PII Pseudonymisation
**Description**: All PII fields in CoreFM PostgreSQL staging models (user email addresses, names) must be pseudonymised using a one-way hash on `user_id`. Only `account_id` is retained as the join key to Salesforce.
**Pre-condition**: Written sign-off from Priya Nair and legal counsel Diane Hooper required before implementation.
**Acceptance Criteria**: No plain-text PII in any Dataform model output; pseudonymisation approach documented in technical note; Priya Nair sign-off obtained.

### FR-013: Feature Taxonomy Reference Table
**Description**: Load the feature taxonomy CSV (Module → Feature Group → Feature mapping) provided by Leon Yip into BigQuery as `raw_corefm_db.feature_taxonomy`.
**Acceptance Criteria**: Table exists; all event_name values from Mixpanel/Segment map to at least one feature_id; joined correctly in stg_corefm_db__feature_events.

### FR-014: Cloud Composer Deployment
**Description**: Deploy Cloud Composer 2 environment in both dev and prod GCP projects.
**Acceptance Criteria**: Composer environment healthy; DAGs visible in Airflow UI; dev environment isolated from prod.

### FR-015: Cloud Composer Orchestration DAGs
**Description**: Build four Cloud Composer DAGs:
1. **fivetran_trigger_dag**: Trigger Fivetran syncs in dependency order (Salesforce before HubSpot, CoreFM PostgreSQL before Product staging)
2. **dataform_run_dag**: Run Dataform pipelines after Fivetran sync completes (staging first, then intermediate, then warehouse)
3. **data_quality_dag**: Run Dataform assertions after transformation; fail pipeline if assertions fail
4. **alerting_dag**: Send Slack and email alerts on any pipeline DAG failure
**Acceptance Criteria**: All four DAGs run successfully; alerting_dag fires correctly on simulated failure; dependency order maintained.

### FR-016: Dataform Data Quality Assertions
**Description**: Implement Dataform assertions covering: row counts on all warehouse tables, null rates on key fields, referential integrity between mart tables, and business logic sanity checks.
**Required assertions**:
- Row count assertions: flag if row count drops > 10% day-over-day on any warehouse table
- Null rate assertions: flag if null rate on any PK or critical FK exceeds 1%
- Referential integrity: all FK columns in warehouse models resolve to valid PKs in dimension tables
- Business logic: ARR values never negative; NPS scores between -100 and 100; date fields within reasonable range
**Acceptance Criteria**: All assertions configured; assertions pass for 3 consecutive daily runs; assertion failures block the dataform_run_dag downstream.

### FR-017: Pipeline Health Dashboard (Looker)
**Description**: Build a Looker dashboard showing pipeline health metrics: run times, failure rates, row count trends, last sync timestamps per source.
**Audience**: Amara Diallo, Kofi Asante, Sean Murphy.
**Refresh**: Hourly.
**Acceptance Criteria**: Dashboard displays per-source last sync time; row count trend (7-day); failure count by DAG; alert count by severity.

---

## 5. Non-Functional Requirements

### NFR-001: Pipeline Reliability
All Fivetran connectors must achieve < 0.1% error rate over any 7-day observation window in production.

### NFR-002: Data Freshness
- Salesforce, HubSpot, Zendesk, PagerDuty, Intercom, Outreach: data must be available in staging within 30 minutes of Fivetran sync completion.
- Daily sources (Google Ads, LinkedIn Ads, Meta Ads, Mixpanel, NetSuite, BambooHR): data available by 7am UTC.
- CoreFM PostgreSQL (CDC): staging data available within 15 minutes of change.

### NFR-003: Data Quality Thresholds
- All Dataform assertions must pass for 3 consecutive daily runs before Phase 1 milestone sign-off.
- Row count reconciliation within ±1% of source system record counts (documented exceptions permitted).

### NFR-004: Security
- No production credentials stored in code. All secrets managed via GCP Secret Manager.
- IAM follows least-privilege: no broad Owner/Editor grants on production project except during provisioning.
- CoreFM PostgreSQL access via read-only service account with network access restricted to GCP VPC.

### NFR-005: Maintainability
- All pipeline code committed to GitHub with PR review workflow.
- Dataform models include column-level documentation sufficient for Amara Diallo's team to understand and maintain independently.
- ChurnZero and Clearbit Cloud Functions documented with README covering architecture, deployment, and debugging.

### NFR-006: Observability
- All Cloud Composer DAG runs logged to Cloud Logging.
- BigQuery audit logs exported to Cloud Logging.
- Pipeline health dashboard provides real-time visibility for operations team.

---

## 6. Data Requirements

| Source System | Connection Method | Sync Frequency | Primary Owner | PII Present | Notes |
|---------------|------------------|----------------|---------------|-------------|-------|
| Salesforce | Fivetran Standard | Every 6 hours | Greg Fontaine / Ben Tran | No | Dedicated API user required |
| HubSpot | Fivetran Standard | Every 1 hour | Niamh Collins | Partial (emails) | Standard contact fields |
| Google Ads | Fivetran Standard | Daily (3am UTC) | Owen Brady | No | |
| LinkedIn Ads | Fivetran Standard | Daily (3am UTC) | Owen Brady | No | |
| Meta Ads | Fivetran Standard | Daily (3am UTC) | Owen Brady | No | |
| Outreach.io | Fivetran Standard | Every 6 hours | Niamh Collins | Partial | |
| Clearbit | Cloud Function (webhook) | On-demand | Niamh Collins | No (firmographics only) | Triggered by HubSpot new lead |
| CoreFM PostgreSQL | Fivetran CDC | 15 min (near real-time) | Amara Diallo | **Yes** | PII pseudonymisation required; Cloud SQL Auth Proxy |
| Mixpanel | Fivetran Standard | Daily (4am UTC) | Leon Yip | Partial | Dedup with Segment per event mapping |
| Segment | BigQuery Destination | Streaming | Leon Yip | Partial | Dedup with Mixpanel per event mapping |
| Intercom | Fivetran Standard | Every 6 hours | Julia Mercer | Partial | |
| ChurnZero | Custom Cloud Function | Daily (6am UTC) | Ben Tran | No | No native Fivetran connector |
| Zendesk | Fivetran Standard | Every 1 hour | Carlos Vega | Partial | Carlos to ensure CSAT export access for Fivetran |
| NetSuite | Fivetran Standard | Daily (5am UTC) | Sandra Kowalski | No | Integration role creation can take 2–3 weeks — start immediately |
| PagerDuty | Fivetran Standard | Every 1 hour | Sean Murphy | No | Check enterprise API token restrictions |
| GCP Billing | Native BigQuery Export | Daily (T+1) | Sean Murphy | No | Partially configured; formalise and validate label coverage |
| Google Cloud Monitoring | Cloud Monitoring API | Daily | Sean Murphy | No | Via Dataform scheduled query |
| BambooHR | Fivetran Standard | Daily (5am UTC) | Mei Lin | Yes (HR data) | Pseudonymise employee PII |

---

## 7. Technical Requirements

### Platform
- **Cloud Provider**: Google Cloud Platform (GCP)
- **Data Warehouse**: BigQuery (Standard edition; partitioned and clustered tables for large mart models)
- **Transformation**: Dataform (GitHub-connected; three-layer: staging → intermediate → warehouse)
- **Pipelines**: Fivetran Business Critical (to be procured by Core Dynamics before Phase 1 kickoff)
- **Orchestration**: Cloud Composer 2 (Airflow 2.x)
- **Custom Pipelines**: Cloud Functions (Gen 2, Python 3.11)
- **Secret Management**: GCP Secret Manager (all credentials)
- **Source Control**: GitHub (Core Dynamics organisation; Rittman Analytics team as collaborators)
- **Streaming**: Segment BigQuery Destination (Segment-managed)

### Environments
- **Development**: core-dynamics-analytics-dev (Rittman Analytics has Owner; used for all development and testing)
- **Production**: core-dynamics-analytics-prod (Rittman Analytics has Editor; production data; requires PR review before promotion)

### BigQuery Dataset Architecture (per Appendix A, SOW)
Three-layer architecture:
1. **Raw layer**: `raw_<source>` datasets (one per source, Fivetran-managed)
2. **Staging layer**: `staging` dataset (Dataform-managed; 1:1 with source tables; typed + documented)
3. **Intermediate layer**: `intermediate` dataset (cross-source joins and business logic)
4. **Warehouse/marts layer**: `mart_marketing`, `mart_product`, `mart_customer`, `mart_ops`
5. **ML layer**: `ml_models` (BQML outputs — future release)
6. **Looker scratch**: `looker_scratch` (Looker PDT scratch dataset)

### Constraints
- NetSuite integration role provisioning must start immediately (can take 2–3 weeks)
- CoreFM PostgreSQL read-only service account + Cloud SQL Auth Proxy must be provisioned by Amara Diallo before Phase 2 kickoff
- All Fivetran credentials provisioned by respective system owners within 5 business days of written request
- PII pseudonymisation in stg_corefm_db__users requires written sign-off from Priya Nair + Diane Hooper (legal) before implementation

---

## 8. Deliverables

| ID | Deliverable | Acceptance Criteria |
|----|-------------|---------------------|
| D-01 | GCP project setup, IAM, environment configuration | Both projects provisioned; all APIs enabled; IAM roles configured; no overly permissive prod grants |
| D-02 | Fivetran connector configuration (all 18 sources) | All connectors sync successfully; < 0.1% error rate over 7-day observation; configuration documented |
| D-03 | Dataform staging models (all sources) | All staging models build without errors; column-level docs complete; PII pseudonymised |
| D-04 | Cloud Composer DAGs for orchestration | All 4 DAGs run successfully; alerting fires on simulated failure |
| D-05 | Data quality assertions and pipeline health dashboard | Assertions pass for 3 consecutive daily runs; pipeline health dashboard live in Looker |
| D-06 | Data Engineering Runbook (partial — full runbook in Release 06) | Architecture section complete; connector configuration and debugging documented |

---

## 9. Timeline

| Week | Activities | Milestone |
|------|-----------|-----------|
| Week 1 | GCP project setup; IAM; Fivetran configuration begins (Salesforce, HubSpot, Zendesk, Mixpanel, Segment); Dataform repository initialised | GCP projects live; first connectors active |
| Week 2 | More Fivetran connectors; CoreFM PostgreSQL access (Cloud SQL Auth Proxy with Sean Murphy); staging models begin | Raw data landing for initial sources |
| Week 3 | Remaining Fivetran connectors; ChurnZero + Clearbit Cloud Functions; staging models for all sources | All staging models passing assertions |
| Week 4 | Cloud Composer orchestration deployed; data quality assertions; pipeline health dashboard; milestone review with Amara Diallo | **Phase 1 milestone: all raw data in BigQuery; staging models passing; sign-off from Amara Diallo** |

---

## 10. Assumptions and Dependencies

| # | Assumption | Risk if Wrong |
|---|-----------|---------------|
| A-01 | GCP Owner (dev) + Editor (prod) granted to Rittman Analytics service account by end of Week 1 | Blocks all infrastructure work |
| A-02 | Core Dynamics will procure Fivetran Business Critical account before Phase 1 kickoff | Blocks all standard connector work |
| A-03 | All system owner credentials provided within 5 business days of written request | Timeline slippage per connector |
| A-04 | CoreFM PostgreSQL Cloud SQL Auth Proxy configured by Amara + Sean before Phase 2 (product/customer workstreams) | Blocks Product and Customer releases |
| A-05 | NetSuite integration role process started in Week 1 even though pipeline needed in Week 4 | Timeline miss on NetSuite staging |
| A-06 | Leon Yip provides feature_taxonomy CSV before stg_corefm_db__feature_events build | Blocks feature taxonomy reference table |
| A-07 | Leon Yip provides Segment-vs-Mixpanel event-to-source mapping before staging model build for product events | Risk of double-counting if mapping absent |
| A-08 | Priya Nair + Diane Hooper sign off on PII pseudonymisation approach by end of Week 2 | Blocks stg_corefm_db__users implementation |

---

## 11. Risks and Mitigations

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-07 | CoreFM PostgreSQL network access not yet provisioned | In progress | High | Kofi + Sean direct call this week to configure Cloud SQL Auth Proxy |
| R-08 | NetSuite integration role creation can take 2–3 weeks | Flagged | Medium | Start process in Week 1 per Priya Nair's instruction |
| R-09 | ChurnZero has no native Fivetran connector | Known | Medium | Custom Cloud Function scoped and budgeted; extra buffer in Phase 1 |
| R-05 | GCP Billing label coverage unknown | Identified | High | Sean Murphy to provide label coverage audit before DO-02 scoping |
| R-06 | Segment/Mixpanel event overlap creates double-counting risk | Confirmed | Medium | Leon Yip to provide event-to-source mapping before product staging build |
| R-10 | PII pseudonymisation requires legal sign-off | Open | Medium | Target sign-off by end of Week 2; Priya to introduce Diane Hooper |

---

## 12. Scope Management

**In scope:**
- GCP project setup, IAM, and environment configuration
- Fivetran connectors for all 18 data sources
- Dataform repository, staging models, intermediate foundation models
- Cloud Composer 2 orchestration DAGs
- Data quality assertions (Dataform native)
- Pipeline health dashboard in Looker

**Out of scope:**
- Analytics workstream models and dashboards (covered in Releases 03–06)
- Self-service ETL tooling or data catalogue
- Salesforce, HubSpot, or Zendesk configuration changes
- Real-time streaming dashboards
- Production deployment of analytics dashboards (covered in Release 06 deployment artifact)

**Change process**: Any scope changes require a written change request from Core Dynamics, effort estimate from Rittman Analytics, and written approval from Priya Nair before work begins.
