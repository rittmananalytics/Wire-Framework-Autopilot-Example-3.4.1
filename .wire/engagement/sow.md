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

Core Dynamics spends approximately $2.1M annually on demand generation across paid search (Google Ads), paid social (LinkedIn, Meta), content syndication, events, and SDR outreach. Rachel Summers (VP Marketing) and Owen Brady (Demand Gen Manager) have no reliable view of:

- Which channels and campaigns are generating pipeline and closed-won revenue (not just MQLs)
- True cost-per-opportunity and cost-per-acquisition by channel
- How long leads spend at each funnel stage and where drop-off occurs
- Which content assets (whitepapers, webinars, case studies) influence deals at each funnel stage

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
- Content:
  - Leads, MQLs, SQLs, Opportunities by week (bar chart)
  - Conversion rates at each funnel stage (funnel chart)
  - Spend by channel this month vs. last month (bar chart)
  - Cost per MQL and Cost per SQL by channel (table with sparklines)
  - Top 10 campaigns by pipeline generated (table)

**Dashboard MA-02: Multi-Touch Attribution Analysis (Self-Service Explore)**
- Audience: Rachel Summers, Owen Brady
- Refresh: Daily
- Content:
  - Attribution model selector (first-touch, last-touch, linear, time-decay, U-shaped)
  - Revenue attributed by channel under selected model
  - Average touches before close by segment
  - Content asset influence analysis (which assets appear in closed-won paths)
  - Funnel velocity: average days per stage by channel

**Dashboard MA-03: Pipeline Contribution Report (Monthly Executive)**
- Audience: Marcus Elwood, David Park, Rachel Summers
- Refresh: Weekly
- Content:
  - Marketing-sourced vs. Sales-sourced pipeline by month
  - Marketing-influenced revenue (touched at any point in the journey)
  - CAC by quarter with trend line
  - Marketing ROI ratio (pipeline generated / total spend)

#### Delivery Approach

This workstream requires a full delivery lifecycle: requirements validation, data model design, pipeline build, semantic layer development, and dashboard delivery. Estimated effort: **5 weeks** (Phases 2 & 3).

---

### 5.3 Workstream B: Product Analytics

#### Background & Problem Statement

CoreFM generates rich product usage telemetry but it is currently only accessible to engineers querying the production PostgreSQL database directly. The product and customer success teams have no visibility into:

- Which features are being adopted by which accounts, and at what depth
- Which accounts are "power users" vs. "light users" of the platform
- How onboarding completion rates correlate with long-term retention
- Where users are dropping off in key workflows (e.g., asset creation, work order submission, report generation)

Claire Ashworth (VP Product) needs this data to prioritise the roadmap. Tara Obinna (VP Customer Success) needs account-level product scores to identify at-risk accounts. Leon Yip (Senior PM) needs funnel analysis for specific features to assess adoption post-launch.

#### Data Sources Required
- CoreFM PostgreSQL operational database (accounts, users, sessions, feature events, work_orders, assets, reports)
- Mixpanel (frontend event tracking: page views, feature clicks, workflow completions)
- Salesforce (account metadata, contract dates, ARR — for joining product usage to commercial context)
- Intercom (in-app messages, NPS responses, onboarding checklist completions)
- Segment (event stream — source of Mixpanel events, also feeds to BigQuery via Segment Destination)

**Note:** The CoreFM PostgreSQL database contains PII (user email addresses, names). Agreed approach is to pseudonymise at the staging layer using a one-way hash on `user_id`, retaining only `account_id` as the join key to Salesforce. Rittman Analytics will document this approach and seek sign-off from Priya Nair before implementing.

#### Key Business Questions to Answer

1. What is the 30/60/90-day feature adoption rate for accounts who signed in the last six months?
2. Which features have the highest activation rate, and which have the lowest? (Product roadmap input)
3. How does depth of feature usage in the first 30 days correlate with 12-month renewal probability?
4. Which accounts have not logged in for 14+ days? Which have dropped below their historical usage baseline?
5. What does the onboarding completion funnel look like, and where are accounts stalling?
6. What is the DAU/MAU ratio by account segment and account size?

#### Warehouse Models Required

| Model | Description |
|---|---|
| `mart_product.fct_feature_usage` | Daily feature usage counts per account per feature |
| `mart_product.fct_session_events` | Individual session events from Segment/Mixpanel |
| `mart_product.fct_onboarding_funnel` | Onboarding step completion per account |
| `mart_product.dim_account_product_score` | Composite product engagement score per account (0–100), refreshed daily |
| `mart_product.fct_workflow_completion` | Completion rates for key in-app workflows |

#### Product Engagement Score Model

The `dim_account_product_score` model will implement a weighted composite score:

| Signal | Weight | Description |
|---|---|---|
| DAU/MAU ratio (last 30 days) | 25% | Active engagement breadth |
| Number of distinct features used (last 30 days) | 20% | Feature adoption depth |
| Core feature activation (asset mgmt + work orders) | 25% | Core value realised |
| NPS response (Intercom, last 180 days) | 15% | Sentiment signal |
| Onboarding checklist completion % | 15% | Onboarding health |

Score bands: `0–39` = At Risk, `40–69` = Neutral, `70–89` = Healthy, `90–100` = Champion.

#### Dashboards Required

**Dashboard PB-01: Product Adoption Overview**
- Audience: Claire Ashworth, Leon Yip, Fatima Al-Rashidi
- Refresh: Daily
- Content:
  - Feature adoption heatmap (accounts × features, colour = usage intensity)
  - DAU/MAU by account segment (enterprise vs. mid-market vs. SMB)
  - Feature activation funnel for accounts < 90 days old
  - Top 10 most-used features; bottom 10 least-used features

**Dashboard PB-02: Account-Level Product Usage (Drill-through from Customer Dashboard)**
- Audience: CSMs (via Customer Dashboard), VP Product
- Refresh: Daily
- Content:
  - Per-account feature usage over time (line chart per feature)
  - Product engagement score trend
  - Last login date, session count (last 30 days)
  - Onboarding checklist status
  - Usage vs. peer cohort benchmark

**Dashboard PB-03: Onboarding Funnel Analysis**
- Audience: Julia Mercer (Head of Onboarding), Tara Obinna
- Refresh: Daily
- Content:
  - Onboarding funnel conversion rates step-by-step
  - Time-to-complete each onboarding step (median, p75, p90)
  - Accounts stalled at each step (list, filterable by CSM)
  - Cohort analysis: onboarding completion rate by signup month

#### Delivery Approach

Full delivery lifecycle required. The PostgreSQL pipeline is a custom Dataform/Cloud Composer build (not a standard Fivetran connector) due to the operational database's schema complexity and PII requirements. Estimated effort: **6 weeks** (Phases 2 & 3), running in parallel with Marketing Analytics.

---

### 5.4 Workstream C: Customer Analytics

#### Background & Problem Statement

Tara Obinna (VP Customer Success) manages a team of 14 CSMs serving 312 enterprise accounts. The CS team currently uses ChurnZero as their customer success platform, but CSMs report low confidence in ChurnZero's health scores because they do not incorporate actual product usage data (ChurnZero only receives basic login events from a webhook, not feature-level usage). As a result, the CS team relies heavily on gut feel and quarterly business review (QBR) cycles rather than data-driven signals.

Key pain points identified in discovery:

- **Reactive churn management:** Churn is only identified when a customer declines a renewal call. There is no early-warning system.
- **Expansion blind spots:** The CS team has no systematic view of which accounts have unused licences, underutilised modules, or adjacent business units that could be upsold.
- **CSM workload imbalance:** ARR-per-CSM ranges from $1.2M to $4.7M with no data-driven capacity model to inform hiring or account reallocation decisions.
- **Inconsistent QBR preparation:** CSMs spend 3–5 hours preparing each QBR slide deck by manually pulling data from Salesforce, ChurnZero, and the product database.

This workstream will deliver a Customer 360 view, an AI-assisted churn risk model (using BigQuery ML), and a set of operational dashboards that allow CSMs and leadership to manage the book of business proactively.

#### Data Sources Required
- Salesforce (accounts, opportunities, contracts, renewal dates, ARR, CSM assignment)
- ChurnZero (NPS scores, health score history, QBR dates, segment)
- CoreFM PostgreSQL (product usage — from Workstream B models)
- Zendesk (support tickets per account, CSAT scores, severity, resolution time)
- Intercom (in-app messages, onboarding completion — from Workstream B)
- Finance/NetSuite (invoice payment history, contract expansion history)

#### Key Business Questions to Answer

1. Which accounts are at risk of churning in the next 90 days, and why?
2. Which accounts have expansion potential (unused licences, low feature breadth, multi-site potential)?
3. What is the current NRR and GRR by segment, CSM, and cohort?
4. How does support ticket volume and CSAT correlate with renewal outcome?
5. Which CSMs have the best and worst expansion conversion rates?
6. What is the predicted renewal probability for each account renewing in the next 180 days?

#### Warehouse Models Required

| Model | Description |
|---|---|
| `mart_customer.dim_account_health` | Single unified health score per account, incorporating product usage, support, sentiment, and financial signals |
| `mart_customer.fct_renewal_pipeline` | Renewals due in rolling 180-day window, with predicted renewal probability |
| `mart_customer.fct_expansion_signals` | Accounts with expansion indicators: unused licences, new business units, feature gap vs. contracted tier |
| `mart_customer.fct_csm_book_of_business` | Per-CSM: ARR managed, account count, health distribution, renewal coverage |
| `mart_customer.fct_nrr_grr` | Monthly NRR and GRR by segment, cohort, and CSM |
| `mart_customer.fct_churn_events` | Historical churn and downsell events with contributing signals for model training |

#### BigQuery ML Churn Risk Model

Rittman Analytics will build, evaluate, and deploy a logistic regression churn risk model using BigQuery ML. The model will:

- Be trained on 24 months of historical renewal outcomes (churn, renew, expand, downgrade)
- Use features from `mart_customer.dim_account_health`: product engagement score, support ticket rate, NPS trend, days since last QBR, licence utilisation %, contract age, ARR, segment
- Output a `churn_probability` (0–1) and `churn_risk_band` (Low/Medium/High/Critical) refreshed weekly
- Be evaluated using AUC-ROC, precision, recall at a 0.5 threshold, and business-context precision-recall trade-off
- Be documented with a model card covering assumptions, limitations, and retraining guidance

The model output feeds directly into the Customer Health dashboard and the CSM Alerts system.

#### Dashboards Required

**Dashboard CA-01: Customer Health Command Centre**
- Audience: Tara Obinna, Ben Tran (CS Ops), all CSMs
- Refresh: Daily
- Content:
  - Account health distribution (At Risk / Neutral / Healthy / Champion) — donut chart with drilldown
  - Churn risk heatmap: accounts × risk band, filterable by CSM and segment
  - Renewals due in next 30/60/90 days with predicted renewal probability
  - Top 10 at-risk accounts (ranked by ARR × churn probability)
  - Expansion opportunity list (accounts with expansion signals, sorted by potential ARR uplift)
  - NRR and GRR KPIs vs. board target (gauge chart)

**Dashboard CA-02: CSM Book of Business**
- Audience: Individual CSMs (row-level security by CSM)
- Refresh: Daily
- Content:
  - My accounts: health score, churn risk, renewal date, ARR (table with RAG indicators)
  - Accounts requiring action (last engagement > 30 days, health declining, upcoming renewal)
  - My NRR contribution vs. team average
  - QBR prep: one-click per-account data pull for QBR slide population

**Dashboard CA-03: CS Leadership Scorecard**
- Audience: Tara Obinna, David Park, Marcus Elwood
- Refresh: Weekly
- Content:
  - NRR and GRR trend (last 12 months vs. target)
  - Churn rate by segment and cohort
  - CSM performance comparison (NRR, expansion ARR, CSAT, at-risk account rate)
  - Upcoming renewal pipeline value vs. predicted outcome
  - Churn model performance metrics (AUC, prediction accuracy vs. actuals)

#### Looker Alerts

Rittman Analytics will configure Looker Scheduled Alerts to notify CSMs via Slack when:
- An account's health score drops by 15+ points in a 7-day window
- An account's product engagement score enters the "At Risk" band
- A renewal is 60 days out and predicted renewal probability is below 70%
- A new support ticket is opened at Severity 1 or 2 for an at-risk account

#### Delivery Approach

Full delivery lifecycle. This workstream has a dependency on Workstream B (product usage data must be available in BigQuery before the health score model can be built). The BQML model adds a sprint of data science work after the core data model is complete. Estimated effort: **7 weeks** (Phases 2 & 3, partially dependent on Workstream B completion).

---

### 5.5 Workstream D: Operational Analytics

#### Background & Problem Statement

Harriet Drummond (COO) has two primary concerns: (1) that the engineering and support operations teams are meeting their SLA commitments to enterprise customers, and (2) that cloud infrastructure costs are being managed efficiently as ARR grows. Neither concern can be answered with data today.

Support Engineering (Carlos Vega) tracks SLA performance in a combination of Zendesk and a Google Sheet maintained by a support analyst. The Google Sheet is updated once per week and provides no intraday visibility. There is no systematic tracking of resolution time by customer tier, ticket priority, or support agent.

Infrastructure cost allocation is performed monthly by Sean Murphy (Platform Engineering), who manually reconciles a GCP billing export with a spreadsheet of customer-to-project mappings. There is no per-customer cost visibility, and no alerting when spend deviates from forecast.

This workstream is lower complexity than Marketing or Customer — it does not require a full data model lifecycle for all components — but it does require reliable pipelines and a clear operational dashboard.

#### Data Sources Required
- Zendesk (tickets, agents, customers, SLA policy assignments, resolution times, CSAT)
- PagerDuty (incidents, escalations, on-call rotas, MTTA, MTTR)
- Google Cloud Billing Export → BigQuery (already partially configured by Sean Murphy; Rittman Analytics will formalise)
- CoreFM PostgreSQL (deployment events, feature flag states, system health events)
- Google Cloud Monitoring (uptime metrics, error rates — via Cloud Monitoring API to BigQuery)
- BambooHR (headcount, team structure — for support capacity planning model)

#### Key Business Questions to Answer

1. Are we meeting our P1/P2/P3 SLA commitments by customer tier this week/month?
2. What is our average CSAT score, and which agents/teams are below threshold?
3. What is MTTA and MTTR for PagerDuty incidents, and how has it trended?
4. What is our infrastructure cost per customer, and which customers are loss-making on a unit-cost basis?
5. How is support ticket volume trending vs. ARR and headcount? Are we maintaining support efficiency?
6. What is the on-call burden per engineer, and is it equitably distributed?

#### Warehouse Models Required

| Model | Description |
|---|---|
| `mart_ops.fct_support_tickets` | Tickets with SLA timers, resolution time, agent, customer tier, CSAT |
| `mart_ops.fct_incident_response` | PagerDuty incidents with MTTA, MTTR, escalation chain |
| `mart_ops.fct_infra_cost_by_customer` | Daily GCP cost allocated to customer (by project/label mapping) |
| `mart_ops.fct_support_capacity` | Ticket volume vs. headcount ratios by team, week |

#### Dashboards Required

**Dashboard DO-01: Support Operations SLA Tracker**
- Audience: Carlos Vega, Harriet Drummond, Ben Tran
- Refresh: Every 4 hours (intraday)
- Content:
  - SLA compliance rate by priority (P1/P2/P3) this month vs. target (table + gauge)
  - Open tickets breaching or at-risk of breaching SLA (live list with time remaining)
  - CSAT trend (last 90 days, by agent and team)
  - Ticket volume by week (bar chart, coloured by priority)
  - Agent workload (open tickets per agent, average resolution time)

**Dashboard DO-02: Infrastructure Cost & Efficiency**
- Audience: Harriet Drummond, Sean Murphy, Sandra Kowalski
- Refresh: Daily (billing exports are T+1)
- Content:
  - Total GCP spend this month vs. budget (gauge)
  - Cost per customer (top 20 highest-cost accounts — table)
  - Cost trend by service (BigQuery, GKE, Cloud SQL, Pub/Sub — stacked bar)
  - Unit economics: infrastructure cost as % of ARR by customer segment
  - Anomaly detection: flagged accounts where cost increased >20% week-over-week

**Dashboard DO-03: Incident Response & On-Call Health**
- Audience: Tobias Hecht, Carlos Vega, Harriet Drummond
- Refresh: Daily
- Content:
  - MTTA and MTTR trend (last 13 weeks)
  - Incidents by severity this quarter (bar chart)
  - On-call burden: incidents per engineer per month (fairness view)
  - Post-incident review completion rate
  - System uptime by service (last 30 days)

#### Delivery Approach

This workstream is the most straightforward and does not require a full data modelling lifecycle for all components. DO-01 (Support SLA) requires medium effort — Zendesk pipeline + model + dashboard. DO-02 (Infra Cost) builds on the existing GCP Billing export and requires primarily a Dataform model and dashboard. DO-03 (Incidents) requires a PagerDuty connector and lightweight model. Estimated effort: **4 weeks** (Phase 3, partially parallelisable with other workstreams).

---

### 5.6 Semantic Layer & Looker Governance

#### Background

Looker will serve as the single semantic layer for all analytics at Core Dynamics. The LookML project will be the authoritative definition of every business metric — MRR, NRR, CAC, churn rate, engagement score, SLA compliance — ensuring that the same number is returned regardless of which dashboard, alert, or API query requests it.

This governance layer is critical given the metric inconsistency problems identified in Section 4.1. Once deployed, any new report or dashboard must reference LookML-defined metrics rather than writing custom SQL, enforced through Looker's access-control and content validation features.

#### LookML Project Structure

The project will follow a modular structure aligned to the analytics workstreams:

```
core_dynamics_looker/
├── manifest.lkml
├── models/
│   ├── marketing.model.lkml
│   ├── product.model.lkml
│   ├── customer.model.lkml
│   ├── operations.model.lkml
│   └── executive.model.lkml
├── views/
│   ├── shared/          # Shared dimensions: date, account, user
│   ├── marketing/       # Campaign, lead, attribution views
│   ├── product/         # Feature usage, session, onboarding views
│   ├── customer/        # Health score, renewal, CSM views
│   └── operations/      # Ticket, incident, cost views
├── explores/
│   └── [per workstream explores]
└── dashboards/
    └── [LookML dashboards for all governed dashboards]
```

#### Key Semantic Layer Components

**Shared Dimensions**
- `dim_date`: Standard date dimension with fiscal calendar offsets (Core Dynamics fiscal year starts 1 February)
- `dim_account`: Master account dimension joining Salesforce account, ChurnZero segment, product score
- `dim_csm`: CSM dimension with team assignment and capacity metrics

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

**Access Controls**
- CSM dashboards will use Looker user attributes for row-level security (CSMs only see their own accounts)
- Financial metrics (ARR, cost) will be restricted to `finance_viewers` and `leadership` user groups
- PII fields will be hidden at the LookML layer; only pseudonymised `account_id` exposed to analysts

**Looker Actions**
- "Flag for CSM Follow-up" action on Customer Health dashboard → creates a task in Salesforce
- "Export QBR Data" action → generates a pre-formatted Google Slides template populated with account metrics

#### Delivery Approach

The semantic layer is built incrementally alongside each workstream rather than upfront as a monolith. Views and explores are added and reviewed as each workstream's warehouse models are completed. A final semantic layer audit and governance review will be conducted in the final week of Phase 3. Estimated effort: distributed across workstreams, **~2 weeks** of dedicated Looker governance work in Phase 3.

---

## 6. Data Sources

The following table summarises all in-scope data sources, their connection method, expected sync frequency, and the workstreams they support.

| Source System | Connection Method | Sync Frequency | Workstreams | Primary Owner (Client) |
|---|---|---|---|---|
| Salesforce | Fivetran Standard Connector | Every 6 hours | Marketing, Customer, Foundation | Greg Fontaine / Ben Tran |
| HubSpot | Fivetran Standard Connector | Every 1 hour | Marketing | Niamh Collins |
| Google Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| LinkedIn Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| Meta Ads | Fivetran Standard Connector | Daily (3am UTC) | Marketing | Owen Brady |
| Outreach.io | Fivetran Standard Connector | Every 6 hours | Marketing | Niamh Collins |
| Clearbit | REST API → Cloud Function → BigQuery | On-demand (inbound leads) | Marketing | Niamh Collins |
| CoreFM PostgreSQL | Fivetran Log-based CDC Connector | Near real-time (15 min) | Product, Customer, Operations | Amara Diallo |
| Mixpanel | Fivetran Standard Connector | Daily (4am UTC) | Product | Leon Yip |
| Segment | Segment BigQuery Destination | Streaming | Product | Leon Yip |
| Intercom | Fivetran Standard Connector | Every 6 hours | Product, Customer | Julia Mercer |
| ChurnZero | ChurnZero API → Cloud Function → BigQuery | Daily (6am UTC) | Customer | Ben Tran |
| Zendesk | Fivetran Standard Connector | Every 1 hour | Customer, Operations | Carlos Vega |
| NetSuite | Fivetran Standard Connector | Daily (5am UTC) | Customer, Foundation | Sandra Kowalski |
| PagerDuty | Fivetran Standard Connector | Every 1 hour | Operations | Sean Murphy |
| GCP Billing Export | Native BigQuery Export (already enabled) | Daily | Operations | Sean Murphy |
| Google Cloud Monitoring | Cloud Monitoring API → Dataform | Daily | Operations | Sean Murphy |
| BambooHR | Fivetran Standard Connector | Daily (5am UTC) | Operations | Mei Lin |

**Notes:**
- ChurnZero does not have a native Fivetran connector. Rittman Analytics will build a Cloud Function using ChurnZero's REST API with incremental sync logic.
- Clearbit enrichment will be triggered on new inbound lead creation via a HubSpot workflow webhook.
- Access credentials and network connectivity for CoreFM PostgreSQL must be provisioned by Amara Diallo's team prior to Phase 2 kickoff.

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

**Objectives:** Validate requirements with stakeholders, establish GCP infrastructure, configure initial data pipelines.

| Week | Activities |
|---|---|
| Week 1 | Project kickoff; stakeholder interviews (Rachel Summers, Claire Ashworth, Tara Obinna, Harriet Drummond, Carlos Vega); data source audit; access provisioning |
| Week 2 | GCP project and IAM setup (D-01); Fivetran connector configuration begins (D-02); Dataform repository initialised |
| Week 3 | Fivetran connectors active for Salesforce, HubSpot, Zendesk, Mixpanel, Segment; staging models built for these sources |
| Week 4 | Remaining Fivetran connectors; ChurnZero and Clearbit custom connectors built; all staging models complete; Cloud Composer orchestration deployed (D-05) |

**Milestone:** All raw data landing in BigQuery; staging models passing data quality assertions. Sign-off: Amara Diallo.

---

### Phase 2: Data Modelling & Semantic Layer Build (Weeks 5–14)

**Objectives:** Build warehouse models for all workstreams; build core LookML views and explores; deliver pipeline health dashboard.

| Weeks | Activities |
|---|---|
| 5–6 | Foundation warehouse models (shared dims, date spine, account master); pipeline health dashboard (D-06); marketing intermediate models |
| 7–8 | Marketing warehouse models complete; LookML marketing views and explores; Product intermediate models begin |
| 9–10 | Product warehouse models; product engagement score model; LookML product views; Customer intermediate models begin |
| 11–12 | Customer warehouse models; BQML churn risk model training and evaluation (D-13); LookML customer views |
| 13–14 | Operations warehouse models; LookML operations views; semantic layer review with Amara Diallo and workstream leads |

**Milestone:** All warehouse models complete and passing tests; LookML project in development Looker instance with all explores functional. Sign-off: Amara Diallo + workstream leads.

---

### Phase 3: Dashboard Build, UAT & Deployment (Weeks 15–22)

**Objectives:** Build all dashboards, conduct UAT with stakeholders, deploy to production, knowledge transfer.

| Weeks | Activities |
|---|---|
| 15–16 | Marketing dashboards built (D-07, D-08, D-09); UAT with Rachel Summers and Owen Brady |
| 16–17 | Product dashboards built (D-10, D-11, D-12); UAT with Claire Ashworth and Leon Yip |
| 17–19 | Customer dashboards built (D-14, D-15, D-16); RLS configuration; Looker Actions (D-17, D-22); UAT with Tara Obinna and Ben Tran |
| 19–20 | Operations dashboards built (D-18, D-19, D-20); UAT with Carlos Vega and Harriet Drummond |
| 20–21 | Semantic layer governance review; production deployment; documentation (D-23, D-24); Looker Alerts configuration |
| 22 | Knowledge transfer workshops (D-25); final UAT sign-off (D-26); hypercare period begins |

**Milestone:** All dashboards live in production Looker; all stakeholders signed off; runbook and semantic layer guide delivered. Sign-off: Priya Nair.

### Workstream Complexity Summary

| Workstream | Relative Complexity | Lifecycle Required | Dependencies |
|---|---|---|---|
| Foundation | High | Full (infra + pipeline + modelling) | None |
| Marketing Analytics | High | Full (pipeline → model → semantic layer → dashboards) | Foundation complete |
| Product Analytics | High | Full + PII handling + custom pipeline | Foundation; DB access provisioned |
| Customer Analytics | Very High | Full + BQML model | Foundation; Workstream B models |
| Operational Analytics | Medium | Partial (some components are dashboard-only) | Foundation |
| Semantic Layer Governance | Medium | Governance review + documentation | All workstreams |

---

## 9. Assumptions & Dependencies

1. **GCP Project Access:** Core Dynamics will grant Rittman Analytics `Owner` role on the `core-dynamics-analytics-dev` project and `Editor` role on `core-dynamics-analytics-prod` by the end of Week 1.
2. **Fivetran Account:** Core Dynamics holds or will procure a Fivetran Business Critical account with sufficient monthly active rows (MAR) to cover all in-scope connectors. Rittman Analytics will advise on MAR sizing but will not procure the account on the client's behalf.
3. **Looker Licence:** Core Dynamics holds or will procure a Looker Standard or Enterprise licence with sufficient user seats. The engagement assumes a minimum of 30 Standard Users and 5 Developer users.
4. **Credential Provisioning:** All API credentials, database passwords, and OAuth tokens for source systems will be provided by the relevant system owner within 5 business days of written request. Delays will result in timeline adjustment.
5. **CoreFM PostgreSQL Access:** Network access (VPN or Cloud SQL Auth Proxy) to the CoreFM production database will be provisioned by Amara Diallo's team before the start of Phase 2. Read-only service account credentials will be provided.
6. **Stakeholder Availability:** Workstream sponsors (Rachel Summers, Claire Ashworth, Tara Obinna, Harriet Drummond) will be available for a 1-hour requirements review in Week 1 and a 2-hour UAT session in Phase 3. Delays in stakeholder availability of more than 5 business days will result in timeline adjustment.
7. **Historical Data:** Rittman Analytics assumes that at least 24 months of historical data is available in each source system for the BQML churn model. If less history is available, model accuracy may be lower and timeline may be impacted.
8. **Data Quality:** Rittman Analytics will surface data quality issues encountered in source systems but will not be responsible for cleansing source data upstream of the pipeline. Material data quality issues in source systems may require scope adjustment.
9. **Salesforce-HubSpot Sync:** The existing Salesforce-HubSpot bidirectional sync is assumed to be functioning correctly and maintaining consistent `Contact.Id` fields. If this is not the case, attribution analysis will require remediation work that is currently out of scope.

---

## 10. Out of Scope

The following items are explicitly out of scope for this engagement:

- **Real-time streaming dashboards** (sub-minute latency). All dashboards refresh on schedules ranging from 4 hours to daily. Real-time streaming architectures can be scoped separately.
- **Self-service ETL tooling or data catalogue** (e.g., Dataplex, Alation). The runbook covers operational documentation; a full data catalogue is a future phase.
- **Predictive modelling beyond the churn risk model.** Expansion propensity modelling, LTV prediction, and lead scoring models are not in scope.
- **Salesforce, HubSpot, or Zendesk configuration changes.** Rittman Analytics will read from these systems but will not modify their schemas, workflows, or field configurations.
- **GDPR/CCPA compliance review or legal sign-off.** PII pseudonymisation will be implemented at the data engineering layer, but formal compliance sign-off is the responsibility of Core Dynamics' legal team.
- **Mobile or embedded analytics.** All Looker content will be accessed via the Looker web application. Embedded analytics (e.g., in the CoreFM application) is a future phase.
- **Training materials or internal analytics enablement programme** beyond the three knowledge transfer sessions listed in the deliverables.
- **Ongoing managed service.** This engagement covers build and handover. An ongoing managed service (monitoring, model retraining, new dashboard requests) can be scoped under a separate retainer arrangement post-engagement.

---

## 11. Fees & Payment Schedule

| Milestone | Description | Amount (USD) | Due |
|---|---|---|---|
| M1 | Contract signature | $42,500 | On signature |
| M2 | Phase 1 complete — all raw data in BigQuery | $42,500 | End of Week 4 |
| M3 | Phase 2 complete — all warehouse models signed off | $55,000 | End of Week 14 |
| M4 | Phase 3 — Marketing & Product dashboards signed off (D-07 to D-12) | $42,500 | End of Week 17 |
| M5 | Phase 3 — Customer & Operations dashboards signed off (D-13 to D-20) | $42,500 | End of Week 20 |
| M6 | Final sign-off, documentation, and knowledge transfer complete | $25,000 | End of Week 22 |
| **Total** | | **$250,000** | |

**Expenses:** Travel expenses (if on-site visits are required) will be billed at cost with a 10% handling fee, subject to prior written approval. Remote delivery is assumed as the default; on-site presence is available on request.

**Out-of-scope work:** Any work outside this SoW will be quoted separately and require written approval before proceeding. Rittman Analytics' standard day rate for this engagement is $2,200/day.

**Invoicing:** Invoices will be issued on milestone completion. Payment terms are net-30 from invoice date.

---

## 12. Acceptance Criteria

Each deliverable will be accepted based on the following criteria:

**Data Pipelines (D-02 to D-05):**
- All Fivetran connectors sync successfully with < 0.1% error rate over a 7-day observation period
- All Dataform assertions pass with no failures for 3 consecutive daily runs
- Cloud Composer DAGs complete successfully with alerts firing on simulated failure

**Warehouse Models (D-04):**
- All tables pass Dataform not-null and uniqueness tests on primary keys
- Row counts reconcile within ±1% of source system record counts (documented exceptions permitted)
- Agreed business metrics (ARR, NRR, CAC) match values currently reported in Finance's spreadsheets within ±2% (tolerance accounts for calculation methodology improvements)

**BQML Churn Risk Model (D-13):**
- AUC-ROC ≥ 0.75 on held-out test set
- Precision ≥ 60% at a 0.5 probability threshold (i.e., accounts flagged as high-risk are at risk more than 60% of the time)
- Model card reviewed and signed off by Tara Obinna

**Dashboards (D-07 to D-20):**
- Dashboard loads within 5 seconds for default date range (prior 90 days) in production Looker
- All KPI tiles match agreed business definitions in the semantic layer governance guide
- UAT sign-off received from the named workstream sponsor within 5 business days of UAT delivery
- Row-level security verified: CSMs cannot view accounts not assigned to them

**Documentation (D-23, D-24):**
- Reviewed by Amara Diallo and at least one member of the data engineering team
- Covers all in-scope pipelines, models, and Looker configuration at sufficient depth for the team to maintain the platform independently

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
├── staging                 # Dataform staging models (1:1 with source tables, typed + documented)
├── intermediate            # Cross-source joins and business logic
│
├── mart_marketing          # Marketing analytics warehouse tables
├── mart_product            # Product analytics warehouse tables
├── mart_customer           # Customer analytics warehouse tables
├── mart_ops                # Operational analytics warehouse tables
│
├── ml_models               # BigQuery ML model outputs (churn risk scores)
└── looker_scratch          # Looker PDT scratch dataset
```

---

## Appendix B: Proposed Looker Project Structure

```
core_dynamics_looker/
│
├── manifest.lkml           # Project constants, localisation settings
│
├── models/
│   ├── marketing.model.lkml    # Marketing explores + access grants
│   ├── product.model.lkml      # Product explores + access grants
│   ├── customer.model.lkml     # Customer explores + RLS access grants
│   ├── operations.model.lkml   # Operations explores + access grants
│   └── executive.model.lkml    # Cross-functional executive explores
│
├── views/
│   ├── shared/
│   │   ├── dim_date.view.lkml
│   │   ├── dim_account.view.lkml
│   │   └── dim_csm.view.lkml
│   ├── marketing/
│   │   ├── fct_lead_funnel_events.view.lkml
│   │   ├── fct_campaign_spend.view.lkml
│   │   ├── fct_attribution_touches.view.lkml
│   │   ├── fct_opportunity_attribution.view.lkml
│   │   └── dim_campaign.view.lkml
│   ├── product/
│   │   ├── fct_feature_usage.view.lkml
│   │   ├── fct_session_events.view.lkml
│   │   ├── fct_onboarding_funnel.view.lkml
│   │   └── dim_account_product_score.view.lkml
│   ├── customer/
│   │   ├── dim_account_health.view.lkml
│   │   ├── fct_renewal_pipeline.view.lkml
│   │   ├── fct_expansion_signals.view.lkml
│   │   ├── fct_csm_book_of_business.view.lkml
│   │   ├── fct_nrr_grr.view.lkml
│   │   └── ml_churn_risk_scores.view.lkml
│   └── operations/
│       ├── fct_support_tickets.view.lkml
│       ├── fct_incident_response.view.lkml
│       ├── fct_infra_cost_by_customer.view.lkml
│       └── fct_support_capacity.view.lkml
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

*This Statement of Work is subject to the Master Services Agreement between Rittman Analytics Ltd and Core Dynamics, Inc. dated [to be inserted]. In the event of any conflict between this SoW and the MSA, the MSA shall prevail.*

*Prepared by:* Mark Rittman, Rittman Analytics Ltd
*Approved by (Client):* _________________________ Date: _________
*Approved by (Rittman Analytics):* _________________________ Date: _________
