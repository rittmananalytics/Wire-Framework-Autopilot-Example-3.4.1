# Requirements Specification — Customer Analytics
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Version**: 1.0

---

## 1. Executive Summary

Release 05 delivers the customer analytics capability for Core Dynamics — a comprehensive view of account health, renewal pipeline, and customer success operations built on top of the data foundation established in Releases 02–04. This release addresses the primary business goal of improving Net Revenue Retention (NRR) from 104% to 115% within 18 months by making renewal risk, expansion opportunity, and churn propensity visible and actionable across the Revenue and Customer Success organisations.

The centrepiece of this release is a Customer Health Score — a composite index drawing on product engagement (from Release 04), support and relationship signals, and financial metrics — combined with a BigQuery ML logistic regression model that predicts 12-month churn probability. Three Looker dashboards surface this intelligence: a command centre for leadership, a CSM-specific book-of-business view with row-level security, and a CS leadership scorecard with NRR/GRR trending.

The release depends on Release 02 (staging models), Release 04 (`dim_account` shared key and `dim_account_product_score`), and delivers outputs consumed by Release 06 (operational analytics cross-release joins).

---

## 2. Business Context

### 2.1 Client Background

Core Dynamics, Inc. is a B2B SaaS company selling CoreFM, a facility and asset management platform, to 312 enterprise accounts across North America and EMEA. Annual Recurring Revenue is $38.4M (Series C). The board has set a target to improve NRR from 104% to 115% within 18 months.

### 2.2 Problem Statement

Customer Success teams have no unified, data-driven view of account health. Account managers rely on subjective intuition, manually compiled spreadsheets, and the ChurnZero platform — which contains only 14 months of history (vs. 24 months needed for meaningful churn modelling). Renewal forecasts are prepared manually in Salesforce without data enrichment. There is no early-warning system for churn risk at scale. The 8% MRR discrepancy between CS and Finance teams creates trust issues with revenue data.

### 2.3 Strategic Goals

1. Reduce churn rate by identifying at-risk accounts ≥90 days before renewal
2. Provide CSMs with a single account health view eliminating spreadsheet prep for QBRs
3. Standardise NRR/GRR calculation eliminating the 8% Finance vs CS discrepancy
4. Enable data-driven renewal and expansion motions
5. Build BQML churn model with AUC-ROC ≥ 0.75 as proof of concept for AI-assisted CS

### 2.4 Success Criteria

- Customer Health Score live for all 312 accounts within 4 weeks of deployment
- CS leadership can access NRR/GRR for trailing 12 months within 2 business days of go-live
- Churn model achieving AUC-ROC ≥ 0.75 on holdout set
- CSM book-of-business dashboard accessed weekly by ≥80% of CSMs within 60 days
- QBR prep time reduced from 4 hours to 30 minutes (self-reported, measured at 90 days)

---

## 3. Stakeholders

| Name | Role | Department | Involvement |
|------|------|-----------|-------------|
| Tara Obinna | VP Customer Success | Customer Success | Primary — CA-02 daily user, NRR owner |
| Claire Ashworth | VP Product | Product | Secondary — Customer Health Score co-designer |
| David Park | CFO | Finance | Financial metrics governance, NRR/GRR sign-off |
| Marcus Webb | VP Sales | Sales | Renewal pipeline visibility |
| Sophie Tanner | Engagement Lead | Rittman Analytics | Delivery lead |
| Greg Ellison | Head of BI | Core Dynamics Data | Technical owner post go-live |
| Amara Diallo | Revenue Ops | RevOps | Salesforce data quality, renewal dates |
| CSM team (6 people) | Customer Success Managers | Customer Success | CA-02 daily users |
| Rachel Summers | Marketing Ops | Marketing | Attribution model sign-off (Release 03 dependency) |

---

## 4. Functional Requirements

### FR-001: Customer Health Score
**Description**: Calculate a composite Customer Health Score (0–100) for each account on a daily basis, drawing on signals from product engagement, support history, financial health, and customer relationship quality.

**Acceptance Criteria**:
- Score computed for all active accounts with at least 30 days of history
- Score updated daily (not just monthly like Product Engagement Score)
- 5 signal components: product engagement (from dim_account_product_score), support health, financial health, relationship health, NPS/survey
- Score bands: At Risk (<40), Needs Attention (40–59), Healthy (60–79), Excellent (≥80)
- Score trend available (trailing 90 days)
- Weights configurable via dbt vars (default: product 30%, support 20%, financial 25%, relationship 15%, nps 10%)

### FR-002: Churn Prediction Model
**Description**: Train a BigQuery ML logistic regression model to predict 12-month churn probability for each account.

**Acceptance Criteria**:
- Trained on 24-month historical data (Salesforce contract history + ChurnZero proxy for months 15–24)
- AUC-ROC ≥ 0.75 on 20% holdout set
- Model outputs: churn_probability (0–1), churn_risk_band (Low/Medium/High/Critical), feature_importance summary
- Model retrained monthly
- Model card documenting training approach, features, limitations
- Predictions joined to dim_account_health for dashboard surfacing

### FR-003: Renewal Pipeline View
**Description**: Provide visibility into upcoming renewals with ARR at risk, probability weighting, and health score context.

**Acceptance Criteria**:
- All renewals in the next 180 days visible with: account, ARR, renewal date, CSM owner, health score, churn_risk_band
- Weighted pipeline = ARR × (1 - churn_probability)
- Renewal stage from Salesforce Opportunity
- Filter by: renewal window (30/60/90/180 days), CSM, risk band, ARR tier

### FR-004: CSM Book of Business
**Description**: Each CSM sees only their assigned accounts (row-level security) with health scores, churn risk, recent activity, and open action items.

**Acceptance Criteria**:
- Looker user attribute-based RLS: `csm_owner` attribute filters `dim_account.csm_owner` — each CSM sees only their accounts
- Finance leadership and VP CS (Tara Obinna) can see all accounts
- Action items: overdue onboarding steps (from Release 04 PB-03), open support tickets, NPS follow-ups
- Looker Action: "Flag for CSM Follow-up" → creates Salesforce task assigned to CSM
- Looker Action: "Export QBR Data" → exports account data to Google Slides QBR template

### FR-005: NRR/GRR Calculation
**Description**: Calculate Net Revenue Retention and Gross Revenue Retention at company level, ARR tier level, and CSM book level for trailing 12-month and point-in-time periods.

**Acceptance Criteria**:
- NRR = (Beginning ARR + Expansion + Contraction - Churn) / Beginning ARR × 100
- GRR = (Beginning ARR - Contraction - Churn) / Beginning ARR × 100
- Calculated monthly; trailing 12-month rolling window available
- `fct_nrr_grr` model with grain = account × month
- Reconciles with Finance source (David Park sign-off required)
- Financial metrics restricted to `finance_viewers` and `leadership` Looker groups

### FR-006: Churn Events Tracking
**Description**: Track churn and contraction events with reason codes for cohort and trend analysis.

**Acceptance Criteria**:
- Source: Salesforce closed-lost opportunities + ChurnZero churn events
- Fields: account_pk, event_date, churn_type (full_churn/contraction/non-renewal), arr_impacted, reason_category, reason_detail, csm_owner
- Available as dimension in CA-01 and CA-03 dashboards

### FR-007: Expansion Signals
**Description**: Surface leading indicators of expansion opportunity: high engagement + low licence utilisation, feature requests, and upsell signals.

**Acceptance Criteria**:
- Expansion signal: (feature_breadth_score > 70) AND (licence_utilisation_pct < 80)
- Upsell flags from Salesforce Opportunity type = 'Upsell' + stage
- `fct_expansion_signals` model with grain = account × signal_date

### FR-008: CS Leadership Dashboard (CA-03)
**Description**: Aggregated NRR/GRR, churn trend, and at-risk ARR view for Tara Obinna and CS leadership.

**Acceptance Criteria**:
- Company-level NRR/GRR trailing 12 months (line chart + number tiles)
- At-risk ARR waterfall: accounts moving between health bands month-over-month
- Churn events by reason category (bar chart)
- CSM performance comparison (non-financial — health score outcomes, at-risk accounts recovered)
- Scheduled alert: weekly digest to Tara Obinna → Slack #cs-leadership

### FR-009: Looker Scheduled Alerts
**Description**: Four types of automated Looker alerts delivered to Slack.

**Acceptance Criteria**:
- Weekly health score digest → #cs-team (every Monday 08:00, accounts with health change ≥10 points)
- At-risk account alert → CSM direct message (daily, new accounts crossing below 40)
- Renewal at-risk alert → #revenue-ops (daily, accounts <40 health score + renewal <90 days)
- NRR weekly summary → #cs-leadership (every Monday 08:00, trailing 4-week NRR trend)

---

## 5. Non-Functional Requirements

### 5.1 Performance
- CA-01 dashboard loads within 5 seconds for all accounts
- CA-02 CSM dashboard loads within 3 seconds (RLS filter applied server-side)
- Customer Health Score computed within 4-hour window of daily dbt run

### 5.2 Security
- User IDs: SHA-256 pseudonymisation (consistent with Releases 03 and 04)
- Financial metrics (ARR, MRR, NRR, GRR): restricted to `finance_viewers` and `leadership` Looker groups
- CSM book: RLS via Looker `csm_owner` user attribute — each CSM sees only their accounts
- BQML model outputs: stored in `ml_models` BigQuery dataset with restricted IAM

### 5.3 Data Freshness
- Customer Health Score: daily (runs after Release 04 product score refresh)
- Churn prediction: daily inference (model retrained monthly)
- NRR/GRR: daily (trailing window recalculated on each run)
- Renewal pipeline: daily (Salesforce refresh 6-hourly)

### 5.4 Availability
- Dashboards: 99.5% uptime during business hours (GCP SLA)
- BQML inference job: retried up to 3 times on failure before alerting

---

## 6. Data Requirements

| Source System | Type | Owner | Volume | Refresh | Notes |
|---------------|------|-------|--------|---------|-------|
| Salesforce | CRM | Amara Diallo | 312 accounts, ~1K opps | 6-hourly | Renewal dates, ARR, owner, churn events |
| ChurnZero | CS Platform | Tara Obinna | 14 months history | Daily | Health scores, usage signals (supplementary) |
| Zendesk | Support | Ops team | ~5K tickets | 6-hourly | Ticket volume, CSAT, resolution time |
| Intercom | Comms/NPS | Product team | NPS surveys | 6-hourly | NPS score per account (also in Release 04 stg) |
| dim_account_product_score | Release 04 output | Data team | 312 × 24 months | Daily | Product engagement score — cross-release join |
| dim_account | Release 04 output | Data team | 312 accounts | Daily | Shared account key (SHA-256 salesforce_account_id) |
| stg_salesforce__* | Release 02 output | Data team | Staging layer | 6-hourly | Account, opportunity, contact staging models |
| stg_zendesk__* | Release 02 output | Data team | Staging layer | 6-hourly | Ticket, satisfaction rating staging |
| stg_intercom__* | Release 02 output | Data team | Staging layer | 6-hourly | NPS staging (shared with Release 04) |

---

## 7. Technical Requirements

- **Platform**: Google Cloud Platform (BigQuery, Dataform, Cloud Composer, Looker, Fivetran)
- **dbt**: Customer analytics models in `dbt/models/warehouse/core/` using `mart_customer` dataset
- **BQML**: Logistic regression model in `ml_models` dataset; trained in BigQuery ML; results in `ml_models.customer_churn_predictions`
- **Looker**: Extends `product.model.lkml`; new `customer.model.lkml`; user attributes: `csm_owner`, `is_finance_viewer`, `is_leadership`
- **Python DAG**: Cloud Composer DAG extension adding customer phases after product phases
- **Integration**: `account_pk = SHA-256(salesforce_account_id)` — consistent join key across Releases 04 and 05

---

## 8. Deliverables

| Deliverable | Wire Artifact | Acceptance Criteria |
|-------------|--------------|---------------------|
| Customer Health Score model | dbt: `dim_account_health` | Score 0–100, 5 signals, daily refresh |
| Churn prediction model | BQML: `customer_churn_logistic_reg` | AUC-ROC ≥ 0.75, monthly retrain |
| Renewal pipeline model | dbt: `fct_renewal_pipeline` | 180-day window, weighted ARR |
| CSM book of business model | dbt: `fct_csm_book_of_business` | Per-CSM account health summary |
| NRR/GRR model | dbt: `fct_nrr_grr` | Monthly grain, reconciled with Finance |
| Churn events model | dbt: `fct_churn_events` | Full history, reason codes |
| Expansion signals model | dbt: `fct_expansion_signals` | High engagement + low utilisation flags |
| CA-01 Command Centre | Looker dashboard | Loads ≤5s, all accounts |
| CA-02 CSM Book of Business | Looker dashboard (RLS) | Per-CSM view, Looker Actions |
| CA-03 CS Leadership Scorecard | Looker dashboard | NRR/GRR, churn trend, restricted to leadership |
| Training materials | Enablement | CS team + CS leadership sessions |
| Architecture documentation | Enablement | Architecture guide + operations runbook |

---

## 9. Timeline

| Milestone | Target | Owner |
|-----------|--------|-------|
| Requirements approved | Sprint 7 | Sophie Tanner |
| Data model approved | Sprint 8 | Sophie Tanner + Greg Ellison |
| BQML model trained (dev) | Sprint 8 | Sophie Tanner |
| LookML + RLS configured | Sprint 9 | Sophie Tanner |
| Dashboards built | Sprint 9 | Sophie Tanner |
| UAT complete — Tara Obinna | Sprint 10 | Tara Obinna |
| UAT complete — David Park (NRR/GRR) | Sprint 10 | David Park |
| Production deployment | Sprint 10 | Sophie Tanner |

---

## 10. Assumptions and Dependencies

### Assumptions
- `dim_account` from Release 04 is deployed and accessible in `mart_product`
- `dim_account_product_score` is refreshed daily (Release 04 pipeline running)
- Salesforce `renewal_date__c` field populated for ≥85% of active contracts (Amara Diallo to confirm)
- ChurnZero 14-month history supplemented by Salesforce contract history proxy for months 15–24 of training window
- Looker user attributes (`csm_owner`) provisioned by Greg Ellison before UAT
- `finance_viewers` and `leadership` Looker groups created by Greg Ellison
- BQML training dataset: accounts with 24+ months of history (estimated ~180 of 312 accounts qualify)

### Dependencies
- Release 02 staging models: `stg_salesforce__accounts`, `stg_salesforce__opportunities`, `stg_zendesk__tickets`, `stg_intercom__nps_surveys`
- Release 04: `dim_account` (shared account_pk), `dim_account_product_score` (product signal input)
- External: Salesforce CSM owner field correctly assigned (Amara Diallo)

---

## 11. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| ChurnZero limited to 14 months history | BQML training window reduced; model quality risk | High | Use Salesforce contract events as proxy for months 15–24; document model limitation in model card |
| NRR/GRR reconciliation with Finance takes time | Dashboard blocked until David Park sign-off | Medium | Parallel track: build model and validate methodology with Amara Diallo before David Park review |
| Looker RLS misconfiguration exposes one CSM's data to another | Data breach / trust issue | Low-Medium | Test each CSM login in UAT before go-live; automated test case TC-C01 |
| BQML AUC-ROC < 0.75 | Churn model not deployable as stated | Medium | Fallback: rule-based churn risk (health score < 40 + renewal < 90 days); document threshold decision |
| 15% null renewal dates in Salesforce | Renewal pipeline incomplete | High | Show "renewal date unknown" flag; Amara Diallo to backfill before UAT |
| dim_account shared key mismatch between R04 and R05 | Cross-release join breaks | Low | Same SHA-256 formula used in both releases; validated in data quality assertions |

---

## 12. Scope Management

### In Scope
- Customer Health Score (5 signals, daily)
- BQML logistic regression churn prediction
- Renewal pipeline visibility (180-day window)
- CSM book-of-business with RLS
- NRR/GRR calculation (reconciled with Finance)
- Churn events tracking with reason codes
- Expansion signals model
- Three Looker dashboards: CA-01, CA-02, CA-03
- Looker Actions: Salesforce task creation, QBR Google Slides export
- Looker Scheduled Alerts: 4 alert types
- Training: CS team + CS leadership
- Documentation: architecture guide, operations guide

### Out of Scope
- Automated QBR slide generation (action triggers export only — slides populated manually)
- ChurnZero bi-directional writeback (ChurnZero reads from BigQuery — not in scope)
- Individual user-level churn analysis (account-level only; PII policy)
- Predictive expansion model (churn model scope only for this release)
- BambooHR or PagerDuty integration (Release 06)
- Real-time event streaming (batch daily refresh)

### Change Process
Changes to scope require written approval from Sophie Tanner and Tara Obinna with impact assessment on timeline and budget.
