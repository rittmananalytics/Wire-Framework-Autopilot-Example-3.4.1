# UAT Plan
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**UAT Lead (Client)**: Rachel Summers (VP Marketing)
**Supporting UAT**: Owen Brady (Demand Gen Manager), Niamh Collins (Marketing Ops)
**Secondary Review**: David Park (CRO) for MA-03
**Scheduled**: Weeks 15–16 (per SOW timeline)
**Date prepared**: 2026-03-24

---

## 1. Overview

This UAT plan covers all deliverables in the 03-marketing-analytics release. Acceptance is required from Rachel Summers before the release is marked complete. David Park reviews MA-03.

UAT is conducted in the Looker **staging environment** pointing to `core-dynamics-analytics-dev` BigQuery project. All data used in UAT is production-equivalent (same Fivetran connectors; same transformation logic).

### Deliverables Under Test

| ID | Deliverable | Primary Sign-off |
|----|-------------|-----------------|
| D-07 | Marketing warehouse models (6 models) | Sophie Tanner (internal) + Rachel Summers |
| D-08 | Dashboard MA-01: Demand Generation Performance | Rachel Summers |
| D-09 | Dashboard MA-02: Multi-Touch Attribution Analysis | Rachel Summers |
| D-10 | Dashboard MA-03: Pipeline Contribution Report | Rachel Summers + David Park |
| D-11 | LookML marketing views and explores | Sophie Tanner (internal Looker content validation) |

---

## 2. Test Environment Setup

**Prerequisites before UAT session**:
- [ ] All 6 warehouse models running successfully in dev (dbt run + dbt test passing)
- [ ] Looker staging environment connected to `core-dynamics-analytics-dev`
- [ ] All three dashboards published to Looker staging with default filters
- [ ] MA-02 Explore saved views configured in Looker staging
- [ ] Rachel Summers, Owen Brady, Niamh Collins have Looker staging access (Viewer role)
- [ ] David Park has Looker staging access for MA-03 review
- [ ] Test script shared with UAT participants 3 days in advance

---

## 3. Test Cases

### 3.1 Warehouse Models (D-07)

#### TC-001: fct_lead_funnel_events — SAL Stage Inclusion
**Deliverable**: D-07
**Tester**: Sophie Tanner / Niamh Collins
**Prerequisite**: HubSpot contacts with SAL dates in staging

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Query `SELECT stage_name, COUNT(*) FROM mart_marketing.fct_lead_funnel_events GROUP BY 1 ORDER BY 1` | Row for 'sal' exists with count > 0 |
| 2 | Verify SAL timestamps are plausible | sal dates are between mql_date and sql_date for same contacts |
| 3 | Verify is_converted = TRUE for contacts that progressed beyond SAL | contacts with sal AND sql dates show is_converted = TRUE at SAL stage |

**Pass criteria**: SAL stage rows present; timestamps logical; conversion flag correct

---

#### TC-002: fct_opportunity_attribution — All 5 Models Present
**Deliverable**: D-07
**Tester**: Sophie Tanner

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | `SELECT DISTINCT attribution_model FROM fct_opportunity_attribution ORDER BY 1` | Exactly 5 rows: first_touch, last_touch, linear, time_decay, u_shaped |
| 2 | `SELECT attribution_model, SUM(touch_weight), COUNT(DISTINCT opportunity_pk) FROM fct_opportunity_attribution GROUP BY 1` | Sum per opp per model = 1.0; all models have similar opportunity counts |
| 3 | Verify U-shaped weights: select a single opportunity, all 5 models | first_touch gets 1.0 in first_touch model; u_shaped has 0.4/0.4/0.2 distribution |

**Pass criteria**: All 5 models present; weights sum to 1.0; U-shaped weights match specification

---

#### TC-003: fct_opportunity_attribution — 180-Day Window
**Deliverable**: D-07
**Tester**: Sophie Tanner

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | `SELECT MAX(days_before_opportunity), MIN(days_before_opportunity) FROM fct_opportunity_attribution` | Max ≤ 180; Min ≥ 0 |
| 2 | Check that no touches older than 180 days appear for any opportunity | 0 rows with days_before_opportunity > 180 |

**Pass criteria**: All touches within 0–180 day window

---

#### TC-004: dim_contact — PII Compliance
**Deliverable**: D-07
**Tester**: Sophie Tanner (mandatory before any UAT session begins)

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | `SELECT * FROM dim_contact LIMIT 10` | No column named 'email' with @ signs; email_pseudonymised is 64-char hex |
| 2 | `SELECT COUNT(*) FROM dim_contact WHERE REGEXP_CONTAINS(email_pseudonymised, '@')` | 0 rows |
| 3 | `SELECT COUNT(*) FROM dim_contact WHERE LENGTH(email_pseudonymised) != 64` | 0 rows |

**Pass criteria**: ZERO plain-text emails anywhere in dim_contact (CRITICAL — UAT blocked if this fails)

---

#### TC-005: fct_campaign_spend — All Platforms, Spend Reconciliation
**Deliverable**: D-07
**Tester**: Sophie Tanner + Owen Brady

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | `SELECT platform, SUM(spend_usd), COUNT(*) FROM fct_campaign_spend GROUP BY 1` | 3 rows: google_ads, linkedin_ads, meta_ads; all have spend > 0 |
| 2 | Owen Brady: compare Google Ads total spend in dashboard vs. Google Ads UI for last month | Within ±1% of platform-reported total |
| 3 | Owen Brady: compare LinkedIn Ads total for last month | Within ±1% of platform-reported total |

**Pass criteria**: All 3 platforms present; spend within ±1% of platform-reported totals

---

### 3.2 Dashboard MA-01: Demand Generation Performance (D-08)

#### TC-006: MA-01 — Default View Loads Within 5 Seconds
**Deliverable**: D-08
**Tester**: Rachel Summers (in UAT session)
**Prerequisite**: Dashboard open in Looker staging (fresh browser session)

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open MA-01 dashboard with no filters | Dashboard fully loaded within 5 seconds |
| 2 | Check default date range filter | Shows "Last 7 days" as default |
| 3 | Verify all 5 KPI tiles show non-zero values | Leads, MQLs, SALs, SQLs, Spend all > 0 |

**Pass criteria**: Load time ≤ 5 seconds; correct default date range; all KPIs populated

---

#### TC-007: MA-01 — Period-over-Period Comparison
**Deliverable**: D-08
**Tester**: Rachel Summers

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Observe period-over-period % change arrows on KPI tiles | % changes shown for leads, MQLs, SALs, SQLs, spend |
| 2 | Manually verify one metric: take leads this 7 days ÷ leads prior 7 days - 1 = shown % | Match within ±0.1% |

**Pass criteria**: Period-over-period comparison tile functional and accurate

---

#### TC-008: MA-01 — Majority Pipeline Stage Column
**Deliverable**: D-08
**Tester**: Rachel Summers + Owen Brady

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | View Top 10 Campaigns table | "Majority Pipeline Stage" column is present and populated |
| 2 | Pick one campaign; check Salesforce for the distribution of opportunity stages | The column shows the most common stage for that campaign's leads |
| 3 | Verify the column has a tooltip explaining the mode calculation | Hover tooltip visible |

**Pass criteria**: Majority Pipeline Stage column present, plausible values, tooltip explaining mode calculation

---

#### TC-009: MA-01 — UTM Coverage Data Coverage Tile
**Deliverable**: D-08 + NFR-005
**Tester**: Niamh Collins

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Locate data coverage tile on MA-01 | Coverage % shown (expected ~70%) |
| 2 | Verify tile has explanatory note | Note visible explaining ~30% UTM gap |

**Pass criteria**: Coverage tile present; accurate coverage %; explanation tooltip visible

---

### 3.3 Dashboard MA-02: Multi-Touch Attribution Analysis (D-09)

#### TC-010: MA-02 — U-Shaped Default and Model Switching
**Deliverable**: D-09
**Tester**: Rachel Summers

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open MA-02 Explore | Attribution model filter defaults to "u_shaped" |
| 2 | View channel revenue bar chart | LinkedIn Ads should show significantly different % under u_shaped vs. last_touch |
| 3 | Switch model to "first_touch" | Revenue distribution changes; chart updates without error |
| 4 | Switch back to "u_shaped" | Returns to original u_shaped distribution |

**Pass criteria**: All 5 models functional; U-shaped as default; model switching updates all tiles

---

#### TC-011: MA-02 — Attribution Model Comparison View
**Deliverable**: D-09
**Tester**: Owen Brady

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open saved view "Model Comparison" | Side-by-side table shows all 5 models as columns |
| 2 | Verify LinkedIn channel % differs meaningfully between last_touch and u_shaped | Expected: last_touch < u_shaped for LinkedIn (first-touch heavy channel) |
| 3 | Verify percentages sum to 100% per model column | Each model column sums to 100% |

**Pass criteria**: All 5 models in comparison; LinkedIn disparity visible; percentages sum to 100%

---

#### TC-012: MA-02 — Content Asset Influence Analysis
**Deliverable**: D-09
**Tester**: Rachel Summers

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open saved view "Content Asset Win/Loss Analysis" | Table shows asset categories with closed-won vs. lost journey counts |
| 2 | Verify at least 5 asset categories visible | > 5 rows in the table |
| 3 | Note any assets with >60% win rate | Rachel Summers to validate plausibility |

**Pass criteria**: Content asset analysis functional; results plausible to Rachel Summers

---

#### TC-013: MA-02 — 180-Day Influence Window Applied
**Deliverable**: D-09 + FR-004
**Tester**: Sophie Tanner

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Query: check the days_before_opportunity distribution in MA-02 attribution data | All values 0–180; no values > 180 |
| 2 | Compare total attributed revenue under u_shaped (180-day window) vs. hypothetical 90-day window (query test) | 180-day should include more touches and more marketing-influenced revenue |

**Pass criteria**: 180-day window confirmed in all attribution output

---

### 3.4 Dashboard MA-03: Pipeline Contribution Report (D-10)

#### TC-014: MA-03 — Marketing-Sourced vs. Sales-Sourced Split
**Deliverable**: D-10
**Tester**: Rachel Summers + David Park

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open MA-03; check KPI tile "Marketing-Sourced Pipeline" | Shows % of total pipeline that is marketing-sourced |
| 2 | Greg Fontaine (VP Sales) to validate sourced split intuitively | Approximately 40–60% marketing-sourced expected (to confirm) |
| 3 | Verify stacked bar chart shows 12 months of history | 12 months of data visible in chart |

**Pass criteria**: Sourced/influenced distinction correct; 12-month history visible; percentages plausible

---

#### TC-015: MA-03 — CAC Trend Chart
**Deliverable**: D-10
**Tester**: Rachel Summers

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open CAC by Quarter chart | Shows last 8 quarters (2 years) |
| 2 | Verify CAC calculation makes sense: spend / new customers | David Park to validate CAC figure vs. finance estimates |
| 3 | Confirm trend line direction matches Rachel Summers' expectation | CAC trend consistent with budget growth |

**Pass criteria**: 8 quarters visible; CAC figures plausible; trend direction correct

---

#### TC-016: MA-03 — LTV:CAC Placeholder
**Deliverable**: D-10 + FR-009
**Tester**: Rachel Summers

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Locate LTV:CAC tile on MA-03 | Tile present with current CAC value shown |
| 2 | Verify placeholder message explains Release 05 dependency | "LTV data available in Customer Analytics release (Release 05)" message visible |

**Pass criteria**: LTV:CAC tile present with informative placeholder; not a blank space

---

#### TC-017: MA-03 — Dashboard Loads Within 5 Seconds
**Deliverable**: D-10 + NFR-001
**Tester**: Rachel Summers + David Park (CEO Marcus Elwood to check if available)

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open MA-03 with default date range (last 12 months) in fresh browser | Fully loaded within 5 seconds |

**Pass criteria**: Load time ≤ 5 seconds for default view

---

### 3.5 LookML Validation (D-11)

#### TC-018: All Views Pass Looker Content Validation
**Deliverable**: D-11
**Tester**: Sophie Tanner (internal)

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Run Looker Content Validation on marketing.model.lkml | 0 errors; 0 warnings |
| 2 | Verify all 3 explores (demand_generation, marketing_attribution, pipeline_contribution) are accessible | All explores load without SQL errors |
| 3 | Test one ad-hoc explore query in each explore | Query returns results within 30 seconds |

**Pass criteria**: Content validation passes; all 3 explores functional

---

## 4. Sign-Off Template

```
MARKETING ANALYTICS RELEASE — UAT SIGN-OFF

Release: 03-marketing-analytics
Client: Core Dynamics, Inc.
Date: _______________

I confirm that the following deliverables have been tested and meet the acceptance criteria:

☐ D-07: Marketing warehouse models (6 models) — data quality and business logic verified
☐ D-08: Dashboard MA-01: Demand Generation Performance — loads in ≤5s; correct defaults; UAT passed
☐ D-09: Dashboard MA-02: Multi-Touch Attribution — all 5 models; U-shaped default; self-service Explore
☐ D-10: Dashboard MA-03: Pipeline Contribution — sourced vs. influenced; CAC; ROI; UAT passed
☐ D-11: LookML views and explores — content validation passing; explores functional

Outstanding issues / change requests:
_______________________________________________
_______________________________________________

Primary Sign-off (required):
Rachel Summers, VP Marketing | Signature: _____________ | Date: _____________

Secondary Sign-off (MA-03):
David Park, CRO | Signature: _____________ | Date: _____________

Builder Acknowledgement:
Sophie Tanner, Senior Analytics Engineer, Rittman Analytics | Signature: _____________ | Date: _____________
```

---

## 5. Issue Tracking

UAT issues raised during testing should be tracked in Jira (WAEP project) with label `uat-03-marketing-analytics`.

| Priority | SLA |
|----------|-----|
| P0 — Blocks sign-off (incorrect calculations, PII breach, crashes) | Fix within 1 business day |
| P1 — Significant functional issue | Fix within 3 business days |
| P2 — Minor UI or labelling issue | Fix within 5 business days or next release |
| P3 — Enhancement request | Log for Release 07 backlog |
