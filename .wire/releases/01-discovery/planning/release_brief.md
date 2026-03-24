# Release Brief
## Core Dynamics Data Platform Modernisation

**Engagement**: data_platform_modernisation
**Client**: Core Dynamics, Inc.
**Prepared by**: Mark Rittman, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (Autopilot — self-reviewed)
**Status**: Approved (self-review) — *[Signature required from client before sprint plan execution]*

---

## 1. Executive Summary

This release brief formalises the scope, deliverables, timeline, and acceptance criteria for the Core Dynamics Data Platform Modernisation engagement. Rittman Analytics will design, build, and deliver a unified Google Cloud data platform — comprising BigQuery, Dataform, Cloud Composer, Fivetran, and Looker — serving four analytics domains (marketing, product, customer success, and operations) over 22 weeks.

The platform directly supports Core Dynamics' board-mandated NRR target of 115% (up from 104%) by enabling proactive customer success management, reliable multi-touch marketing attribution, account-level product usage visibility, and operational transparency. The engagement will be delivered in five sequential delivery releases following this discovery sprint.

---

## 2. Problem Statement (Condensed)

Core Dynamics has no centralised data infrastructure. Data is fragmented across 18+ systems with no automated reconciliation. The single analyst spends 60% of his time on manual exports. MRR figures differ by 8% between teams. Customer churn is identified reactively. Marketing attribution is last-touch only. The company cannot reach its NRR target without reliable, accessible data.

**Source**: `.wire/releases/01-discovery/planning/problem_definition.md`

---

## 3. Solution Overview

A governed, multi-domain analytics platform on Google Cloud:

- **ELT Pipelines**: Fivetran connectors (16 standard + 2 custom Cloud Functions) landing raw data into BigQuery per-source datasets
- **Transformation Layer**: Dataform 3-layer model (staging → intermediate → warehouse) across four mart schemas
- **Analytics & BI**: Looker semantic layer with governed metric definitions; 13 dashboards + self-service Explore
- **ML Model**: BigQuery ML logistic regression churn risk model with explainable signals
- **Orchestration**: Cloud Composer 2 (Airflow) DAGs for pipeline orchestration and quality alerting

---

## 4. Deliverables

### 4.1 Discovery Sprint Deliverables

| ID | Deliverable | Type | Acceptance Criteria |
|----|-------------|------|---------------------|
| DS-01 | Problem Definition | Document | All 10 sections complete; reviewed by engagement lead |
| DS-02 | Pitch | Document | All 10 sections; appetite defined; downstream releases specified |
| DS-03 | Release Brief | Document | All 12 sections; client sign-off before sprint plan execution |
| DS-04 | Sprint Plan | Document | All releases epics and stories with estimates; point totals verified |

### 4.2 Foundation Release (02-data-foundation)

| ID | Deliverable | SOW Ref | Acceptance Criteria |
|----|-------------|---------|---------------------|
| D-01 | GCP project setup & IAM | D-01 | dev + prod projects provisioned; all required APIs enabled; IAM roles per least-privilege spec |
| D-02 | Fivetran connectors (all 18 sources) | D-02 | All connectors sync successfully; < 0.1% error rate over 7-day observation |
| D-03 | Dataform staging models (all sources) | D-03 | All staging models built; column-level documentation and type casting; data quality assertions passing |
| D-04a | Cloud Composer DAGs for orchestration | D-05 | DAGs trigger Fivetran syncs in dependency order; Dataform runs post-sync; alerts fire on simulated failure |
| D-04b | Data quality assertions & pipeline health dashboard | D-06 | Assertions cover row counts, null rates, referential integrity, business logic sanity checks; pipeline health dashboard live |

### 4.3 Marketing Analytics Release (03-marketing-analytics)

| ID | Deliverable | SOW Ref | Acceptance Criteria |
|----|-------------|---------|---------------------|
| D-07 | Marketing warehouse models (6 models) | D-04 | All tables pass not-null and uniqueness tests on PKs; row counts reconcile within ±1% of source |
| D-08 | Dashboard MA-01: Demand Generation Performance | D-07 | Loads within 5 seconds; default date range last 7 days; period-over-period comparison; UAT sign-off from Rachel Summers |
| D-09 | Dashboard MA-02: Multi-Touch Attribution Analysis | D-08 | All 5 attribution models functional; U-shaped default; 180-day influence window; UAT sign-off |
| D-10 | Dashboard MA-03: Pipeline Contribution Report | D-09 | Marketing-sourced vs. influenced pipeline visible; CAC by quarter; UAT sign-off |
| D-11 | LookML marketing views & explores | D-21 | All views pass Looker content validation; explores functional in dev instance |

### 4.4 Product Analytics Release (04-product-analytics)

| ID | Deliverable | SOW Ref | Acceptance Criteria |
|----|-------------|---------|---------------------|
| D-12 | Product warehouse models (5 models) | D-04 | PII pseudonymised at staging; all tests passing; feature taxonomy CSV loaded |
| D-13 | Product engagement score (0–100) | D-04 | Score refreshes daily; composite weighting confirmed by Claire Ashworth + Tara Obinna before build |
| D-14 | Dashboard PB-01: Product Adoption Overview | D-10 | Feature adoption heatmap at Feature Group level with drill-through; UAT sign-off from Claire Ashworth |
| D-15 | Dashboard PB-02: Account-Level Product Usage | D-11 | Per-account feature usage, engagement score trend, onboarding status; drill-through from CA-01 |
| D-16 | Dashboard PB-03: Onboarding Funnel Analysis | D-12 | All 7 onboarding steps tracked; UAT sign-off from Julia Mercer + Tara Obinna |
| D-17 | LookML product views & explores | D-21 | All views pass Looker content validation |

### 4.5 Customer Analytics Release (05-customer-analytics)

| ID | Deliverable | SOW Ref | Acceptance Criteria |
|----|-------------|---------|---------------------|
| D-18 | Customer warehouse models (6 models) | D-04 | All tests passing; NRR/GRR calculations within ±2% of Finance spreadsheet |
| D-19 | BigQuery ML churn risk model | D-13 | AUC-ROC ≥ 0.75; precision ≥ 60% at 0.5 threshold; model card reviewed by Tara Obinna |
| D-20 | Dashboard CA-01: Customer Health Command Centre | D-14 | Health distribution, churn heatmap, renewal pipeline, expansion signals; UAT sign-off from Tara Obinna |
| D-21 | Dashboard CA-02: CSM Book of Business | D-15 | Row-level security verified (CSMs see own accounts only); prioritised action list functional |
| D-22 | Dashboard CA-03: CS Leadership Scorecard | D-16 | NRR/GRR trend, churn by segment, CSM performance; UAT sign-off |
| D-23 | Looker Scheduled Alerts (4 alert types) | D-17 | All 4 alert conditions fire correctly; Slack delivery confirmed |
| D-24 | Looker Action: Salesforce task creation | D-22 | Action creates Salesforce task with correct template on trigger |
| D-25 | Looker Action: QBR export to Google Slides | D-22 | One-click generates pre-populated Google Slides deck with account metrics |
| D-26 | LookML customer views & explores (with RLS) | D-21 | RLS via user attributes verified; explores functional |

### 4.6 Operational Analytics Release (06-operational-analytics)

| ID | Deliverable | SOW Ref | Acceptance Criteria |
|----|-------------|---------|---------------------|
| D-27 | Operations warehouse models (4 models) | D-04 | All tests passing |
| D-28 | Dashboard DO-01: Support Operations SLA Tracker | D-18 | 4-hour refresh; live SLA compliance by priority; UAT sign-off from Carlos Vega + Harriet Drummond |
| D-29 | Dashboard DO-02: Infrastructure Cost & Efficiency | D-19 | Per-customer cost scoped to actual GCP Billing label coverage; UAT sign-off |
| D-30 | Dashboard DO-03: Incident Response & On-Call Health | D-20 | MTTA/MTTR 13-week trend; UAT sign-off from Tobias Hecht |
| D-31 | LookML operations views & explores | D-21 | All views pass Looker content validation |
| D-32 | Data Engineering Runbook | D-23 | Covers pipeline architecture, adding new sources, dev-to-prod promotion, incident response; reviewed by Amara Diallo |
| D-33 | Semantic Layer Governance Guide | D-24 | Covers all governed metric definitions, access controls, and content validation process |
| D-34 | Knowledge Transfer Sessions (×3) | D-25 | Three 2-hour sessions delivered; attendance confirmed by Amara Diallo |
| D-35 | UAT Sign-off Documentation | D-26 | Completed sign-off from all four workstream sponsors |

---

## 5. Out of Scope

The following items are explicitly excluded from this engagement:

- Real-time streaming dashboards (sub-minute latency)
- Self-service ETL tooling or data catalogue
- Predictive modelling beyond the churn risk model
- Salesforce, HubSpot, or Zendesk configuration changes
- GDPR/CCPA compliance review or legal sign-off
- Mobile or embedded analytics
- Training programme beyond three KT sessions
- Ongoing managed service
- Retroactive UTM clean-up or Salesforce data remediation

*Any items added to scope require a written change request and budget approval before proceeding.*

---

## 6. Timeline

| Phase | Weeks | Milestone | Sign-off Owner |
|-------|-------|-----------|----------------|
| Discovery Sprint | 1 | Problem definition, pitch, release brief, sprint plan | Mark Rittman |
| Phase 1: Foundation Setup | 1–4 | All raw data landing in BigQuery; staging models passing assertions | Amara Diallo |
| Phase 2: Data Modelling | 5–14 | All warehouse models complete; LookML project functional in dev Looker | Amara Diallo + workstream leads |
| Phase 3: Dashboards & UAT | 15–22 | All dashboards live in production Looker; all stakeholders signed off | Priya Nair |

**Payment milestones:**

| Milestone | Amount | Due |
|-----------|--------|-----|
| M1: Contract signature | $42,500 | On signature |
| M2: Phase 1 complete | $42,500 | End of Week 4 |
| M3: Phase 2 complete | $55,000 | End of Week 14 |
| M4: Marketing & Product dashboards signed off | $42,500 | End of Week 17 |
| M5: Customer & Operations dashboards signed off | $42,500 | End of Week 20 |
| M6: Final sign-off, docs, knowledge transfer | $25,000 | End of Week 22 |
| **Total** | **$250,000** | |

---

## 7. Assumptions and Dependencies

| # | Assumption | Owner | Risk |
|---|-----------|-------|------|
| A-01 | Core Dynamics will grant GCP Owner (dev) and Editor (prod) roles to Rittman Analytics service account by end of Week 1 | Amara Diallo | High if delayed |
| A-02 | Core Dynamics holds or will procure Fivetran Business Critical account before Phase 1 | Amara Diallo | Blocks all pipeline work |
| A-03 | Core Dynamics holds or will procure Looker Standard/Enterprise with ≥30 Standard + 5 Developer users | Priya Nair | Blocks dashboard delivery |
| A-04 | All API credentials provided within 5 business days of written request | System owners | Timeline risk per credential |
| A-05 | CoreFM PostgreSQL network access (Cloud SQL Auth Proxy) provisioned before Phase 2 kickoff | Amara Diallo | Blocks Product and Customer workstreams |
| A-06 | ≥24 months of historical data available in source systems for BQML (or Salesforce proxy accepted) | Ben Tran | Model accuracy risk |
| A-07 | Workstream sponsors available for 1-hour requirements review (Week 1) and 2-hour UAT (Phase 3) | Daniel Osei | Timeline risk |
| A-08 | Salesforce-HubSpot bidirectional sync maintains consistent Contact.Id fields | Niamh Collins | Attribution coverage risk |

---

## 8. Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-01 | HubSpot-Salesforce 12% contact mismatch | Confirmed | High | Fuzzy matching at staging layer; document coverage gap |
| R-02 | Renewal_Date__c null/incorrect for 15% of Salesforce accounts | Confirmed | Medium | Document impact; flag to Ben Tran for client-side cleanup |
| R-03 | ChurnZero only 14 months of history | Confirmed | High | Salesforce opportunity proxy for BQML; document in model card |
| R-04 | UTM parameter gaps (~30% of campaigns) | Confirmed | Medium | Accept historic gap; enforce going forward; Niamh Collins owns |
| R-05 | GCP Billing label coverage unknown | Identified | High | Sean Murphy to audit before ops discovery; scope DO-02 accordingly |
| R-06 | Segment/Mixpanel event overlap risk | Confirmed | Medium | Leon Yip to provide event-to-source mapping; dedup at staging |
| R-07 | CoreFM PostgreSQL access not provisioned | In progress | High | Kofi + Sean to configure Cloud SQL Auth Proxy this week |
| R-10 | PII pseudonymisation requires legal sign-off | Open | Medium | Diane Hooper (legal) to review; target end of Week 2 |

---

## 9. Governance and Change Control

**Metric governance**: All business metrics (MRR, NRR, CAC, GRR, product engagement score, churn risk) will be defined in a Metric Definitions document in Phase 2. Each workstream sponsor must sign off on the definitions that affect their domain before they are locked in LookML.

**Change requests**: Any work outside this brief requires a written change request specifying the additional scope, effort estimate, and cost. Rittman Analytics' standard day rate is $2,200/day. No out-of-scope work will begin without written client approval.

**Status reporting**: Weekly status report to Amara Diallo (day-to-day contact) and Priya Nair (executive sponsor). Milestone sign-offs required per Section 6.

---

## 10. Team

**Rittman Analytics**: Mark Rittman (Engagement Lead), Sophie Tanner (Senior Analytics Engineer), Kofi Asante (Data Engineer), Irina Volkov (Looker Developer), Daniel Osei (Project Manager).

**Core Dynamics primary contacts**: Amara Diallo (Data Engineering Lead, day-to-day), Priya Nair (CTO, executive sponsor).

---

## 11. Downstream Releases

| Release | Name | Type | Scope Summary | Planned Phase |
|---------|------|------|---------------|---------------|
| 02 | 02-data-foundation | pipeline_only | GCP setup, Fivetran connectors (18 sources), Dataform staging, Cloud Composer orchestration, data quality | Phase 1–2 |
| 03 | 03-marketing-analytics | full_platform | Marketing warehouse models, LookML, dashboards MA-01/02/03 | Phase 2–3 |
| 04 | 04-product-analytics | full_platform | Product warehouse models (PII handling), product score, LookML, dashboards PB-01/02/03 | Phase 2–3 |
| 05 | 05-customer-analytics | full_platform | Customer warehouse models, BQML churn model, RLS, Looker Actions, dashboards CA-01/02/03 | Phase 2–3 |
| 06 | 06-operational-analytics | dbt_development | Operations warehouse models, LookML, dashboards DO-01/02/03, documentation, KT | Phase 3 |

---

## 12. Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Engagement Lead, Rittman Analytics | Mark Rittman | *[Signature required]* | |
| CTO / Executive Sponsor, Core Dynamics | Priya Nair | *[Signature required before sprint plan execution]* | |
| Data Engineering Lead, Core Dynamics | Amara Diallo | *[Signature required before sprint plan execution]* | |
