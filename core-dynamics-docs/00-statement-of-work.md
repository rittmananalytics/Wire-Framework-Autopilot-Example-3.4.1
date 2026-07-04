# Statement of Work
## Google Cloud & Looker Data Platform Engagement
### Core Dynamics, Inc. — Prepared by Rittman Analytics

---

**Document Version:** 1.0
**Date:** 24 March 2026
**Prepared by:** Rittman Analytics Ltd
**Prepared for:** Core Dynamics, Inc.
**Engagement Reference:** RA-2026-0041

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [About Core Dynamics](#2-about-core-dynamics)
3. [Stakeholder Organisation Chart](#3-stakeholder-organisation-chart)
4. [Engagement Objectives & Problems to Solve](#4-engagement-objectives--problems-to-solve)
5. [Scope of Work](#5-scope-of-work)
   - 5.1 [Foundation: Data Centralisation & Google Cloud Platform](#51-foundation-data-centralisation--google-cloud-platform)
   - 5.2 [Workstream A: Marketing Analytics](#52-workstream-a-marketing-analytics)
   - 5.3 [Workstream B: Product Analytics](#53-workstream-b-product-analytics)
   - 5.4 [Workstream C: Customer Analytics](#54-workstream-c-customer-analytics)
   - 5.5 [Workstream D: Operational Analytics](#55-workstream-d-operational-analytics)
   - 5.6 [Semantic Layer & Looker Governance](#56-semantic-layer--looker-governance)
6. [Data Sources](#6-data-sources)
7. [Deliverables Summary](#7-deliverables-summary)
8. [Delivery Approach & Phasing](#8-delivery-approach--phasing)
9. [Assumptions & Dependencies](#9-assumptions--dependencies)
10. [Out of Scope](#10-out-of-scope)
11. [Fees & Payment Schedule](#11-fees--payment-schedule)
12. [Acceptance Criteria](#12-acceptance-criteria)
13. [Appendix A: Proposed BigQuery Dataset Architecture](#appendix-a-proposed-bigquery-dataset-architecture)
14. [Appendix B: Proposed Looker Project Structure](#appendix-b-proposed-looker-project-structure)

---

## 1. Executive Summary

Rittman Analytics has been engaged by Core Dynamics, Inc. to design, build, and deliver a unified data platform on Google Cloud, with Looker as the primary business intelligence and semantic layer tool. The engagement addresses four distinct but interconnected analytics domains — marketing, product, customer, and operational — each of which has specific reporting needs, data sources, and stakeholders.

Core Dynamics currently operates with fragmented data spread across over a dozen SaaS tools and internal systems. There is no single source of truth for revenue attribution, customer health, product usage, or supply-chain efficiency. Analysts spend the majority of their time extracting and reconciling data manually, and leadership has limited confidence in the numbers presented in board-level reports.

This engagement will deliver a production-grade Google Cloud data stack (BigQuery, Dataform, Cloud Composer, Pub/Sub, and Looker) underpinned by a governed semantic layer, serving purpose-built dashboards and self-service analytics to each business function. The estimated engagement duration is **22 weeks** across three phases, with an option to extend into an ongoing managed-service arrangement.

---

## 2. About Core Dynamics

Core Dynamics, Inc. is a mid-market B2B SaaS company headquartered in Austin, Texas, with regional offices in London and Singapore. The company sells a cloud-based facility and asset management platform — **CoreFM** — to enterprise customers in sectors including commercial real estate, manufacturing, healthcare, and higher education.

**Key business metrics (FY2025):**

| Metric | Value |
|---|---|
| Annual Recurring Revenue (ARR) | $38.4M |
| Number of Customers | 312 enterprise accounts |
| Average Contract Value (ACV) | ~$123K |
| Employees | ~480 |
| Markets | North America, EMEA, APAC |
| Product | CoreFM (SaaS, multi-tenant) |

The company is Series C funded and under pressure from its board to improve net revenue retention (NRR) from 104% to 115% within 18 months. The data platform engagement is a foundational investment in that goal.

---

## 3. Stakeholder Organisation Chart

```
CEO: Marcus Elwood
│
├── CFO: Sandra Kowalski
│   └── Finance Analyst: James Petit
│
├── CTO: Priya Nair
│   ├── VP Engineering: Tobias Hecht
│   │   ├── Data Engineering Lead: Amara Diallo  ← Primary Technical Contact
│   │   └── Platform Engineering: Sean Murphy
│   └── VP Product: Claire Ashworth
│       ├── Senior PM (Core Platform): Leon Yip
│       └── Senior PM (Integrations): Fatima Al-Rashidi
│
├── CRO: David Park
│   ├── VP Marketing: Rachel Summers  ← Marketing Analytics Sponsor
│   │   ├── Demand Gen Manager: Owen Brady
│   │   └── Marketing Ops Manager: Niamh Collins
│   ├── VP Sales: Greg Fontaine
│   └── VP Customer Success: Tara Obinna  ← Customer Analytics Sponsor
│       ├── CS Ops Manager: Ben Tran
│       └── Head of Onboarding: Julia Mercer
│
└── COO: Harriet Drummond  ← Operational Analytics Sponsor
    ├── Head of Support Engineering: Carlos Vega
    ├── Finance & Revenue Ops: Sandra Kowalski (joint)
    └── HR & People Ops: Mei Lin
```

**Rittman Analytics Engagement Team:**

| Role | Name |
|---|---|
| Engagement Lead | Mark Rittman |
| Senior Analytics Engineer | Sophie Tanner |
| Data Engineer | Kofi Asante |
| Looker Developer | Irina Volkov |
| Project Manager | Daniel Osei |

**Primary client contact (day-to-day):** Amara Diallo, Data Engineering Lead
**Executive sponsor (client):** Priya Nair, CTO

---

## 4. Engagement Objectives & Problems to Solve

### 4.1 Overarching Problems

1. **No single source of truth.** Revenue, usage, and customer health data exist in at least six separate tools (Salesforce, ChurnZero, Mixpanel, NetSuite, Zendesk, and a proprietary PostgreSQL operational database). There is no automated reconciliation between them.

2. **Analyst bottleneck.** The single data analyst (James Petit, Finance) spends approximately 60% of his time on manual CSV exports, VLOOKUP reconciliations, and ad-hoc requests. Business stakeholders cannot self-serve.

3. **Metric inconsistency.** MRR figures reported by Sales, Finance, and Customer Success differ by as much as 8% due to differing calculation logic and refresh cadences. The board has flagged this as a governance risk.

4. **No product usage visibility at the account level.** The Customer Success team cannot see which accounts are actively using CoreFM features, making it impossible to identify at-risk customers before they churn, or to identify expansion opportunities proactively.

5. **Marketing attribution is last-touch only.** The marketing team uses HubSpot's built-in attribution which only captures last-touch channel. Multi-touch attribution across paid channels, organic, and SDR-driven pipeline is entirely blind.

6. **Operational data is trapped in spreadsheets.** Support ticket SLA performance, deployment pipeline health, and infrastructure cost allocation are tracked in Google Sheets with no historical trending or alerting.

### 4.2 Workstream-Specific Objectives

| Workstream | Primary Objective |
|---|---|
| Foundation | Centralise all source data into BigQuery with automated, reliable pipelines |
| Marketing | Deliver multi-touch attribution and campaign ROI reporting to reduce CAC by 15% |
| Product | Enable account-level usage scoring to power CS expansion/churn plays |
| Customer | Build a single customer health dashboard driving a proactive CS motion |
| Operational | Surface SLA, cost, and support metrics to COO and team leads in real time |

---

## 5. Scope of Work

### 5.1 Foundation: Data Centralisation & Google Cloud Platform

#### Background & Problem Statement

Core Dynamics has no centralised data infrastructure today. Data pipelines are ad-hoc scripts running on developer laptops or scheduled Google Sheets imports. There is no data warehouse, no transformation layer, and no monitoring. Before any analytics workstream can be delivered, a robust, governed, and scalable foundation must be in place.

#### Deliverables

**5.1.1 Google Cloud Project Setup & IAM**
- Provision a dedicated GCP project for analytics (`core-dynamics-analytics-prod`) with a parallel development project (`core-dynamics-analytics-dev`).
- Configure IAM roles following least-privilege principles: `data-engineers`, `analysts`, `looker-service-account`, `dataform-runner`.
- Enable required APIs: BigQuery, Dataform, Cloud Composer, Pub/Sub, Secret Manager, Cloud Logging.

**5.1.2 ELT Pipeline Build (Fivetran)**
- Configure Fivetran connectors for all in-scope source systems (see Section 6).
- Land raw data into a `raw` BigQuery dataset per source (e.g., `raw_salesforce`, `raw_hubspot`).
- Establish Fivetran sync schedules appropriate to each source's change frequency (ranges from 15-minute to nightly).
- Document connector configuration and field mappings.

**5.1.3 Dataform Transformation Layer**
- Initialise a Dataform repository connected to the Core Dynamics GitHub organisation.
- Implement a three-layer data model: `staging` → `intermediate` → `warehouse` (or `marts`).
- Build staging models for all in-scope sources, with column-level documentation and data type casting.
- Build intermediate models for cross-source joins and business logic.
- Implement Dataform assertions (not-null, unique, referential integrity) on all warehouse tables.
- Configure Dataform scheduled releases via Cloud Composer (nightly full refresh + intraday incremental for high-priority tables).

**5.1.4 Cloud Composer (Airflow) Orchestration**
- Deploy a Cloud Composer 2 environment.
- Build DAGs for: (a) triggering Fivetran syncs in dependency order, (b) running Dataform pipelines post-sync, (c) data quality checks post-transformation, (d) alerting on pipeline failures via Slack/email.

**5.1.5 Data Quality & Observability**
- Implement dbt-style data tests via Dataform assertions covering: row counts, null rates, referential integrity between key tables, and business logic sanity checks (e.g., ARR never negative).
- Configure BigQuery audit log export to Cloud Logging.
- Build a simple pipeline health dashboard in Looker (pipeline run times, failure rates, row count trends).

**5.1.6 Development Standards & Handover Documentation**
- Deliver a Data Engineering Runbook covering pipeline architecture, how to add new sources, how to promote changes from dev to prod, and incident response.
- Conduct a 2-hour knowledge transfer session with Amara Diallo and the data engineering team.

#### Estimated Effort: 6 weeks (Phases 1 & 2)

---

### 5.2 Workstream A: Marketing Analytics

#### Background & Problem Statement

Core Dynamics spends approximately $2.1M annually on demand generation across paid search (Google Ads), paid social (LinkedIn, Meta), content syndication, events, and SDR outreach. Rachel Summers (VP Marketing) and Owen Brady (Demand Gen Manager) have no reliable view of which channels and campaigns are generating pipeline and closed-won revenue, true cost-per-opportunity and cost-per-acquisition by channel, how long leads spend at each funnel stage and where drop-off occurs, or which content assets influence deals at each funnel stage.

HubSpot's native attribution only captures the last-touch conversion before a contact becomes an MQL. There is no connection between HubSpot marketing data and Salesforce opportunity/revenue data beyond a manual weekly CSV export performed by Niamh Collins (Marketing Ops).

#### Data Sources Required
- HubSpot (contacts, companies, form submissions, email sends, page views, UTM parameters)
- Salesforce (leads, contacts, accounts, opportunities, opportunity line items, campaigns)
- Google Ads (campaigns, ad groups, ads, keywords, impressions, clicks, cost)
- LinkedIn Ads (campaigns, creatives, impressions, clicks, spend)
- Meta Ads (campaigns, ad sets, ads, spend, impressions, clicks)
- Outreach.io (sequences, email touches, call touches per prospect)
- Clearbit Enrichment (company firmographics on inbound leads)
- Salesforce → HubSpot contact sync (for closed-loop attribution)

#### Key Business Questions to Answer

1. What is our MQL-to-SQL conversion rate by channel, and how has it trended over the last 12 months?
2. What is our blended CAC and CAC by channel for closed-won opportunities in the trailing 90 days?
3. Which marketing campaigns have generated the highest pipeline-to-spend ratio?
4. What does our full funnel look like — from first touch to closed-won — by cohort month?
5. Where is pipeline velocity slowest (i.e., which stage has the longest average dwell time)?
6. Which content assets appear most frequently in the paths of closed-won deals?

#### Warehouse Models Required

| Model | Description |
|---|---|
| `mart_marketing.fct_lead_funnel_events` | One row per lead per funnel stage transition, with timestamps |
| `mart_marketing.fct_campaign_spend` | Daily spend by channel, campaign, ad group |
| `mart_marketing.fct_attribution_touches` | All marketing touches per contact, with touch type and channel |
| `mart_marketing.fct_opportunity_attribution` | Opportunity value allocated across touches (linear, time-decay, U-shaped, first/last) |
| `mart_marketing.dim_campaign` | Campaign dimension with channel, type, target segment |
| `mart_marketing.dim_contact` | Contacts with enrichment attributes from Clearbit |

#### Dashboards Required

**Dashboard MA-01: Demand Generation Performance (Weekly)**
- Audience: Rachel Summers, Owen Brady, Niamh Collins
- Refresh: Daily
- Content: Leads, MQLs, SQLs, Opportunities by week; conversion rates at each funnel stage; spend by channel; cost per MQL and cost per SQL by channel; top 10 campaigns by pipeline generated

**Dashboard MA-02: Multi-Touch Attribution Analysis (Self-Service Explore)**
- Audience: Rachel Summers, Owen Brady
- Refresh: Daily
- Content: Attribution model selector; revenue attributed by channel; average touches before close; content asset influence analysis; funnel velocity by channel

**Dashboard MA-03: Pipeline Contribution Report (Monthly Executive)**
- Audience: Marcus Elwood, David Park, Rachel Summers
- Refresh: Weekly
- Content: Marketing-sourced vs. Sales-sourced pipeline; marketing-influenced revenue; CAC by quarter; marketing ROI ratio

#### Estimated Effort: 5 weeks (Phases 2 & 3)

---

### 5.3 Workstream B: Product Analytics

#### Background & Problem Statement

CoreFM generates rich product usage telemetry but it is currently only accessible to engineers querying the production PostgreSQL database directly. The product and customer success teams have no visibility into which features are being adopted by which accounts, which accounts are power users vs. light users, how onboarding completion rates correlate with long-term retention, or where users are dropping off in key workflows.

#### Data Sources Required
- CoreFM PostgreSQL operational database (accounts, users, sessions, feature events, work_orders, assets, reports)
- Mixpanel (frontend event tracking)
- Salesforce (account metadata, contract dates, ARR)
- Intercom (in-app messages, NPS responses, onboarding checklist completions)
- Segment (event stream)

**Note:** The CoreFM PostgreSQL database contains PII. Agreed approach is to pseudonymise at the staging layer using a one-way hash on `user_id`, retaining only `account_id` as the join key to Salesforce. Rittman Analytics will document this approach and seek sign-off from Priya Nair before implementing.

#### Product Engagement Score Model

The `dim_account_product_score` model implements a weighted composite score:

| Signal | Weight | Description |
|---|---|---|
| DAU/MAU ratio (last 30 days) | 25% | Active engagement breadth |
| Number of distinct features used (last 30 days) | 20% | Feature adoption depth |
| Core feature activation (asset mgmt + work orders) | 25% | Core value realised |
| NPS response (Intercom, last 180 days) | 15% | Sentiment signal |
| Onboarding checklist completion % | 15% | Onboarding health |

Score bands: `0–39` = At Risk, `40–69` = Neutral, `70–89` = Healthy, `90–100` = Champion.

#### Estimated Effort: 6 weeks (Phases 2 & 3)

---

### 5.4 Workstream C: Customer Analytics

#### Background & Problem Statement

Tara Obinna (VP Customer Success) manages a team of 14 CSMs serving 312 enterprise accounts. The CS team uses ChurnZero but CSMs report low confidence in its health scores because they do not incorporate actual product usage data. Key pain points include reactive churn management, expansion blind spots, CSM workload imbalance, and inefficient QBR preparation.

This workstream will deliver a Customer 360 view, an AI-assisted churn risk model (using BigQuery ML), and a set of operational dashboards that allow CSMs and leadership to manage the book of business proactively.

#### BigQuery ML Churn Risk Model

- Trained on 24 months of historical renewal outcomes
- Features from `mart_customer.dim_account_health`: product engagement score, support ticket rate, NPS trend, days since last QBR, licence utilisation %, contract age, ARR, segment
- Outputs `churn_probability` (0–1) and `churn_risk_band` (Low/Medium/High/Critical) refreshed weekly
- Evaluated using AUC-ROC, precision, recall at 0.5 threshold
- Documented with a model card covering assumptions, limitations, and retraining guidance

#### Estimated Effort: 7 weeks (Phases 2 & 3, partially dependent on Workstream B)

---

### 5.5 Workstream D: Operational Analytics

#### Background & Problem Statement

Harriet Drummond (COO) needs visibility into SLA compliance and infrastructure cost efficiency. Support SLA performance is tracked in a combination of Zendesk and a Google Sheet updated once per week. Infrastructure cost allocation is performed monthly by Sean Murphy using a manual reconciliation process with no per-customer cost visibility.

#### Estimated Effort: 4 weeks (Phase 3)

---

### 5.6 Semantic Layer & Looker Governance

Looker serves as the single semantic layer for all analytics at Core Dynamics. The LookML project is the authoritative definition of every business metric, ensuring that the same number is returned regardless of which dashboard, alert, or API query requests it.

**Core Business Metrics (governed, single-definition)**

| Metric | Definition | Model |
|---|---|---|
| `ARR` | Sum of active contract annual value at period end | customer |
| `MRR` | ARR / 12 | customer |
| `NRR` | (Starting ARR + Expansion - Contraction - Churn) / Starting ARR × 100 | customer |
| `GRR` | (Starting ARR - Contraction - Churn) / Starting ARR × 100 | customer |
| `CAC` | Total sales + marketing spend / new logos acquired | marketing |
| `LTV` | Average ACV × average customer lifetime in years | customer |
| `LTV:CAC` | LTV / CAC | executive |
| `Product Engagement Score` | Weighted composite (see Section 5.3) | product |
| `Churn Risk Probability` | BQML model output | customer |
| `SLA Compliance Rate` | Tickets resolved within SLA / total tickets × 100 | operations |

#### Estimated Effort: ~2 weeks dedicated governance work in Phase 3

---

## 6. Data Sources

| Source System | Connection Method | Sync Frequency | Workstreams | Primary Owner (Client) |
|---|---|---|---|---|
| Salesforce | Fivetran Standard Connector | Every 6 hours | Marketing, Customer, Foundation | Greg Fontaine / Ben Tran |
| HubSpot | Fivetran Standard Connector | Every 1 hour | Marketing | Niamh Collins |
| Google Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| LinkedIn Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| Meta Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| Outreach.io | Fivetran Standard Connector | Every 6 hours | Marketing | Niamh Collins |
| Clearbit | REST API → Cloud Function → BigQuery | On-demand | Marketing | Niamh Collins |
| CoreFM PostgreSQL | Fivetran Log-based CDC Connector | Near real-time (15 min) | Product, Customer, Operations | Amara Diallo |
| Mixpanel | Fivetran Standard Connector | Daily (4am UTC) | Product | Leon Yip |
| Segment | Segment BigQuery Destination | Streaming | Product | Leon Yip |
| Intercom | Fivetran Standard Connector | Every 6 hours | Product, Customer | Julia Mercer |
| ChurnZero | ChurnZero API → Cloud Function → BigQuery | Daily (6am UTC) | Customer | Ben Tran |
| Zendesk | Fivetran Standard Connector | Every 1 hour | Customer, Operations | Carlos Vega |
| NetSuite | Fivetran Standard Connector | Daily (5am UTC) | Customer, Foundation | Sandra Kowalski |
| PagerDuty | Fivetran Standard Connector | Every 1 hour | Operations | Sean Murphy |
| GCP Billing Export | Native BigQuery Export | Daily | Operations | Sean Murphy |
| Google Cloud Monitoring | Cloud Monitoring API → Dataform | Daily | Operations | Sean Murphy |
| BambooHR | Fivetran Standard Connector | Daily (5am UTC) | Operations | Mei Lin |

---

## 7. Deliverables Summary

| ID | Deliverable | Workstream | Phase | Format |
|---|---|---|---|---|
| D-01 | GCP project setup, IAM, and environment configuration | Foundation | 1 | Infrastructure |
| D-02 | Fivetran connector configuration (all sources) | Foundation | 1–2 | Pipeline |
| D-03 | Dataform repository with staging models (all sources) | Foundation | 2 | Code (GitHub) |
| D-04 | Intermediate and warehouse models (all workstreams) | All | 2–3 | Code (GitHub) |
| D-05 | Cloud Composer DAGs for orchestration | Foundation | 2 | Code (GitHub) |
| D-06 | Data quality assertions and pipeline health dashboard | Foundation | 2 | Looker Dashboard |
| D-07 | Dashboard MA-01: Demand Generation Performance | Marketing | 3 | Looker Dashboard |
| D-08 | Dashboard MA-02: Multi-Touch Attribution Analysis | Marketing | 3 | Looker Dashboard |
| D-09 | Dashboard MA-03: Pipeline Contribution Report | Marketing | 3 | Looker Dashboard |
| D-10 | Dashboard PB-01: Product Adoption Overview | Product | 3 | Looker Dashboard |
| D-11 | Dashboard PB-02: Account-Level Product Usage | Product | 3 | Looker Dashboard |
| D-12 | Dashboard PB-03: Onboarding Funnel Analysis | Product | 3 | Looker Dashboard |
| D-13 | BigQuery ML Churn Risk Model | Customer | 3 | BQML Model + Model Card |
| D-14 | Dashboard CA-01: Customer Health Command Centre | Customer | 3 | Looker Dashboard |
| D-15 | Dashboard CA-02: CSM Book of Business (with RLS) | Customer | 3 | Looker Dashboard |
| D-16 | Dashboard CA-03: CS Leadership Scorecard | Customer | 3 | Looker Dashboard |
| D-17 | Looker Scheduled Alerts (churn risk, health drop) | Customer | 3 | Looker Alerts |
| D-18 | Dashboard DO-01: Support Operations SLA Tracker | Operations | 3 | Looker Dashboard |
| D-19 | Dashboard DO-02: Infrastructure Cost & Efficiency | Operations | 3 | Looker Dashboard |
| D-20 | Dashboard DO-03: Incident Response & On-Call Health | Operations | 3 | Looker Dashboard |
| D-21 | LookML project with governed semantic layer | All | 2–3 | Code (GitHub) |
| D-22 | Looker Actions (Salesforce task creation, QBR export) | Customer | 3 | Looker Action |
| D-23 | Data Engineering Runbook | Foundation | 3 | Documentation |
| D-24 | Semantic Layer Governance Guide | All | 3 | Documentation |
| D-25 | Knowledge transfer sessions (×3) | All | 3 | Workshops |
| D-26 | UAT sign-off documentation | All | 3 | Sign-off Document |

---

## 8. Delivery Approach & Phasing

### Phase 1: Discovery & Foundation Setup (Weeks 1–4)

| Week | Activities |
|---|---|
| Week 1 | Project kickoff; stakeholder interviews; data source audit; access provisioning |
| Week 2 | GCP project and IAM setup; Fivetran connector configuration begins; Dataform repository initialised |
| Week 3 | Fivetran connectors active for Salesforce, HubSpot, Zendesk, Mixpanel, Segment; staging models built |
| Week 4 | Remaining Fivetran connectors; ChurnZero and Clearbit custom connectors; all staging models complete; Cloud Composer deployed |

**Milestone:** All raw data landing in BigQuery; staging models passing data quality assertions. Sign-off: Amara Diallo.

### Phase 2: Data Modelling & Semantic Layer Build (Weeks 5–14)

| Weeks | Activities |
|---|---|
| 5–6 | Foundation warehouse models; pipeline health dashboard; marketing intermediate models |
| 7–8 | Marketing warehouse models complete; LookML marketing views and explores |
| 9–10 | Product warehouse models; product engagement score model; LookML product views |
| 11–12 | Customer warehouse models; BQML churn risk model training and evaluation |
| 13–14 | Operations warehouse models; LookML operations views; semantic layer review |

**Milestone:** All warehouse models complete and passing tests. Sign-off: Amara Diallo + workstream leads.

### Phase 3: Dashboard Build, UAT & Deployment (Weeks 15–22)

| Weeks | Activities |
|---|---|
| 15–16 | Marketing dashboards; UAT with Rachel Summers and Owen Brady |
| 16–17 | Product dashboards; UAT with Claire Ashworth and Leon Yip |
| 17–19 | Customer dashboards; RLS configuration; Looker Actions; UAT with Tara Obinna and Ben Tran |
| 19–20 | Operations dashboards; UAT with Carlos Vega and Harriet Drummond |
| 20–21 | Semantic layer governance review; production deployment; documentation |
| 22 | Knowledge transfer workshops; final UAT sign-off; hypercare period begins |

**Milestone:** All dashboards live in production. Sign-off: Priya Nair.

---

## 9. Assumptions & Dependencies

1. Core Dynamics will grant Rittman Analytics `Owner` role on the dev project and `Editor` role on prod by end of Week 1.
2. Core Dynamics holds or will procure a Fivetran Business Critical account with sufficient monthly active rows.
3. Core Dynamics holds or will procure a Looker Standard or Enterprise licence with a minimum of 30 Standard Users and 5 Developer users.
4. All API credentials and OAuth tokens for source systems will be provided within 5 business days of written request.
5. Network access to the CoreFM production database will be provisioned before the start of Phase 2.
6. Workstream sponsors will be available for a 1-hour requirements review in Week 1 and a 2-hour UAT session in Phase 3.
7. At least 24 months of historical data is available in each source system for the BQML churn model.
8. Rittman Analytics will surface data quality issues but will not be responsible for cleansing source data upstream of the pipeline.
9. The existing Salesforce-HubSpot bidirectional sync is assumed to be functioning correctly.

---

## 10. Out of Scope

- Real-time streaming dashboards (sub-minute latency)
- Self-service ETL tooling or data catalogue
- Predictive modelling beyond the churn risk model
- Salesforce, HubSpot, or Zendesk configuration changes
- GDPR/CCPA compliance review or legal sign-off
- Mobile or embedded analytics
- Training materials beyond the three knowledge transfer sessions
- Ongoing managed service

---

## 11. Fees & Payment Schedule

| Milestone | Description | Amount (USD) | Due |
|---|---|---|---|
| M1 | Contract signature | $42,500 | On signature |
| M2 | Phase 1 complete — all raw data in BigQuery | $42,500 | End of Week 4 |
| M3 | Phase 2 complete — all warehouse models signed off | $55,000 | End of Week 14 |
| M4 | Marketing & Product dashboards signed off (D-07 to D-12) | $42,500 | End of Week 17 |
| M5 | Customer & Operations dashboards signed off (D-13 to D-20) | $42,500 | End of Week 20 |
| M6 | Final sign-off, documentation, and knowledge transfer complete | $25,000 | End of Week 22 |
| **Total** | | **$250,000** | |

Standard day rate for out-of-scope work: $2,200/day. Payment terms: net-30 from invoice date.

---

## 12. Acceptance Criteria

**Data Pipelines:** All Fivetran connectors sync with < 0.1% error rate over 7-day observation period; all Dataform assertions pass for 3 consecutive daily runs.

**Warehouse Models:** All tables pass not-null and uniqueness tests; row counts reconcile within ±1% of source system counts; agreed metrics match Finance's spreadsheets within ±2%.

**BQML Churn Risk Model:** AUC-ROC ≥ 0.75; Precision ≥ 60% at 0.5 threshold; model card signed off by Tara Obinna.

**Dashboards:** Load within 5 seconds for default date range; all KPIs match semantic layer definitions; UAT sign-off received from workstream sponsor within 5 business days; row-level security verified.

**Documentation:** Reviewed by Amara Diallo; covers all in-scope pipelines, models, and Looker configuration at sufficient depth for independent maintenance.

---

## Appendix A: Proposed BigQuery Dataset Architecture

```
core-dynamics-analytics-prod
│
├── raw_salesforce          # Fivetran raw Salesforce tables
├── raw_hubspot             # Fivetran raw HubSpot tables
├── raw_google_ads          # Fivetran raw Google Ads tables
├── raw_linkedin_ads        # Fivetran raw LinkedIn Ads tables
├── raw_meta_ads            # Fivetran raw Meta Ads tables
├── raw_outreach            # Fivetran raw Outreach tables
├── raw_corefm_db           # Fivetran CDC from CoreFM PostgreSQL
├── raw_mixpanel            # Fivetran raw Mixpanel tables
├── raw_segment             # Segment BigQuery Destination
├── raw_intercom            # Fivetran raw Intercom tables
├── raw_churnzero           # Custom Cloud Function output
├── raw_zendesk             # Fivetran raw Zendesk tables
├── raw_netsuite            # Fivetran raw NetSuite tables
├── raw_pagerduty           # Fivetran raw PagerDuty tables
├── raw_gcp_billing         # Native GCP Billing Export
├── raw_bamboohr            # Fivetran raw BambooHR tables
│
├── staging                 # Dataform staging models
├── intermediate            # Cross-source joins and business logic
│
├── mart_marketing          # Marketing analytics warehouse tables
├── mart_product            # Product analytics warehouse tables
├── mart_customer           # Customer analytics warehouse tables
├── mart_ops                # Operational analytics warehouse tables
│
├── ml_models               # BigQuery ML model outputs
└── looker_scratch          # Looker PDT scratch dataset
```

---

## Appendix B: Proposed Looker Project Structure

```
core_dynamics_looker/
│
├── manifest.lkml
│
├── models/
│   ├── marketing.model.lkml
│   ├── product.model.lkml
│   ├── customer.model.lkml
│   ├── operations.model.lkml
│   └── executive.model.lkml
│
├── views/
│   ├── shared/
│   │   ├── dim_date.view.lkml
│   │   ├── dim_account.view.lkml
│   │   └── dim_csm.view.lkml
│   ├── marketing/
│   ├── product/
│   ├── customer/
│   └── operations/
│
└── dashboards/
    ├── pipeline_health.dashboard.lookml
    ├── ma_01_demand_gen.dashboard.lookml
    ├── ma_02_attribution.dashboard.lookml
    ├── ma_03_pipeline_contribution.dashboard.lookml
    ├── pb_01_product_adoption.dashboard.lookml
    ├── pb_02_account_product_usage.dashboard.lookml
    ├── pb_03_onboarding_funnel.dashboard.lookml
    ├── ca_01_customer_health.dashboard.lookml
    ├── ca_02_csm_book_of_business.dashboard.lookml
    ├── ca_03_cs_leadership_scorecard.dashboard.lookml
    ├── do_01_support_sla.dashboard.lookml
    ├── do_02_infra_cost.dashboard.lookml
    └── do_03_incident_response.dashboard.lookml
```

---

*This Statement of Work is subject to the Master Services Agreement between Rittman Analytics Ltd and Core Dynamics, Inc. Prepared by Mark Rittman, Rittman Analytics Ltd.*
