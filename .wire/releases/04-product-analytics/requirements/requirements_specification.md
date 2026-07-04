# Requirements Specification
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (Autopilot — self-reviewed)
**Status**: Approved

---

## 1. Executive Summary

Release 04 builds the Product Analytics capability on the Core Dynamics data platform. It transforms raw product event data from Mixpanel, Segment, and Intercom — combined with CoreFM's own PostgreSQL operational data — into a set of warehouse models and Looker dashboards that give the Product and Customer Success teams visibility into how accounts are using CoreFM.

The central deliverable is a **Product Engagement Score** for every account — a 0–100 composite metric that rolls up feature adoption breadth, session activity, onboarding completion, licence utilisation, and a critical early-adoption signal (work order created within first 30 days). This score feeds into Release 05's customer health model and the QBR reporting cycle.

Three dashboards are delivered: **PB-01** (Product Adoption Overview — feature heatmap), **PB-02** (Account-Level Product Usage — drill-through from customer health), and **PB-03** (Onboarding Funnel Analysis — stalled accounts for CSM intervention).

All user-level data is pseudonymised using SHA-256 hashes. No plain-text user IDs or email addresses are stored in any warehouse model.

---

## 2. Business Context

**Client**: Core Dynamics, Inc. — B2B SaaS, $38.4M ARR, 312 enterprise accounts, CoreFM (facility and asset management platform)
**Strategic goal**: Improve Net Revenue Retention from 104% to 115% within 18 months
**Problem**: No product usage visibility at account level; inability to identify at-risk accounts, stalled onboarding, or expansion opportunities based on product behaviour

**Stakeholders engaged in product requirements**:
- Claire Ashworth (VP Product) — primary product analytics stakeholder
- Leon Yip (Senior PM, Core Platform) — provided feature taxonomy and onboarding definitions
- Tara Obinna (VP Customer Success) — co-owner of Product Engagement Score weighting

---

## 3. Stakeholders

| Name | Role | Department | Involvement |
|------|------|-----------|-------------|
| Claire Ashworth | VP Product | Product | Primary stakeholder; UAT lead for product dashboards |
| Leon Yip | Senior PM, Core Platform | Product | Feature taxonomy and onboarding step definitions |
| Fatima Al-Rashidi | Senior PM, Integrations | Product | Circulated for review; IoT integration scope |
| Tara Obinna | VP Customer Success | Customer Success | Co-approver of Product Engagement Score weights |
| Rachel Summers | VP Marketing | Marketing | Downstream consumer — Account-Level view feeds MA-02 |
| David Park | CRO | Revenue | Secondary consumer — PB-02 feeds CA-01 in Release 05 |
| Sophie Tanner | Senior Analytics Engineer | Rittman Analytics | Builder and UAT facilitator |
| Amara Diallo | Engagement Director | Rittman Analytics | Milestone sign-off |

---

## 4. Functional Requirements

### FR-001 — Feature Taxonomy Model
**Description**: The `fct_feature_usage` warehouse model must include three-level feature hierarchy: `module_id`, `feature_group_id`, `feature_id`. All dimensions must derive from a seed/reference table mapping Mixpanel `event_name` values to the hierarchy.
**Source**: Supplementary Requirements Addition 1; Leon Yip discovery session
**Acceptance criteria**: Every row in `fct_feature_usage` has non-null `module_id`; feature taxonomy CSV loaded as seed; PB-01 dashboard supports filter and grouping at all three levels

### FR-002 — Single Authoritative Event Source Per Event Category
**Description**: `fct_feature_usage` and `fct_session_events` must use a single source per event type (no double-counting). Segment for core transactional events; Mixpanel for discovery and workflow completion; Segment for session events.
**Source**: Supplementary Requirements Addition 4
**Acceptance criteria**: Zero duplicate event rows in `fct_feature_usage` for events that appear in both Segment and Mixpanel; each event has a `source_system` column documenting the authoritative source

### FR-003 — Onboarding Funnel Model (7 Steps)
**Description**: `fct_onboarding_funnel` tracks completion of 7 onboarding steps per account, with timestamp and days-since-signup for each step. Steps 1–5 are core onboarding; Steps 6–7 are extended.
**Source**: Supplementary Requirements Addition 3; Leon Yip
**Steps**: invite_users (1), create_first_asset (2), import_asset_list (3), create_work_order (4), configure_report (5), integrate_iot (6), qbr_ready (7)
**Acceptance criteria**: Each account has at most one row per step; all 7 step IDs present in model; `days_since_signup` populated for each completed step

### FR-004 — Work Order Within 30 Days Signal
**Description**: A binary flag `work_order_within_30_days` must be computed per account: TRUE if the account created at least one work order within the first 30 days of the contract start date.
**Source**: Supplementary Requirements Addition 3 (Claire Ashworth); identified as strongest churn predictor
**Acceptance criteria**: Flag present in `dim_account_product_score` with no nulls; contract start date sourced from Salesforce; test verifies no account has both TRUE for days_before_signup > 30

### FR-005 — Licence Utilisation Metric
**Description**: `licence_utilisation_pct` = active users in last 30 days / contracted user seats. `contracted_user_seats` sourced from Salesforce `Contract.User_Seats__c`. Null seats field → metric shows NULL (not 0).
**Source**: Supplementary Requirements Addition 2; Claire Ashworth
**Acceptance criteria**: Metric present in `dim_account_product_score`; null seats handled gracefully; displayed in PB-02 at account level

### FR-006 — Product Engagement Score (0–100 Composite)
**Description**: `dim_account_product_score` stores a composite score per account per month, built from 7 weighted signals. Score is capped at 100, floored at 0.
**Weights** (per supplementary requirements, signed off by Claire Ashworth and Tara Obinna):

| Signal | Weight | Source |
|--------|--------|--------|
| DAU/MAU ratio (last 30 days) | 20% | Segment sessions |
| Distinct features used (last 30 days) | 20% | Mixpanel feature events |
| Core feature activation | 20% | Segment + Mixpanel |
| Work order created within first 30 days | 10% | Segment |
| Licence utilisation % | 5% | Salesforce + Segment |
| NPS response (last 180 days) | 15% | Intercom |
| Onboarding checklist completion % | 10% | Intercom onboarding events |

**Acceptance criteria**: All 7 signals present in model; score between 0 and 100 for all accounts; historical monthly scores retained for trending

### FR-007 — Account Segment Dimension
**Description**: All product models must include or join to an `account_segment` dimension with values: Enterprise, Mid-Market, SMB, Strategic. `Strategic` takes precedence. Sourced from Salesforce `Account.Segment__c`.
**Source**: Supplementary Requirements Addition 5
**Acceptance criteria**: Segment dimension present in `dim_account`; all 4 segment values present in data; Strategic accounts use `Strategic` regardless of size criteria

### FR-008 — PB-01: Product Adoption Overview Dashboard
**Description**: Heatmap of feature adoption by account, grouped by Feature Group by default, with drill-through to Feature level. Filterable by module, account segment, date range.
**Source**: SOW; sprint plan P-03-01
**Acceptance criteria**: Heatmap renders at Feature Group level by default; drill-through to Feature level functional; module/segment/date filters work; loads within 5 seconds

### FR-009 — PB-02: Account-Level Product Usage Dashboard
**Description**: Account-level view showing Product Engagement Score, DAU/MAU, feature breadth, licence utilisation, onboarding completion status. Designed as a drill-through destination from CA-01 (Release 05).
**Source**: SOW; sprint plan P-03-02
**Acceptance criteria**: Filterable by account name; shows all 7 score components; links to Salesforce account (URL field); loads within 5 seconds with account filter applied

### FR-009 — PB-03: Onboarding Funnel Analysis Dashboard
**Description**: Funnel visualisation of all 7 onboarding steps. CSMs can filter by their book of business to identify stalled accounts. Shows time spent at each step and % of accounts that completed each step.
**Source**: SOW; sprint plan P-03-03
**Acceptance criteria**: All 7 steps visible as funnel; filterable by CSM name (from Salesforce); "stalled" flag (>14 days on a step without completion) surfaced; loads within 5 seconds

---

## 5. Non-Functional Requirements

### NFR-001 — Dashboard Performance
All three dashboards must load within 5 seconds with default filters applied. `fct_feature_usage` partitioned by event_date; `dim_account_product_score` materialised as table for fast dashboard queries.

### NFR-002 — PII Pseudonymisation
No plain-text user IDs or email addresses may be stored in any warehouse model. User identifiers are stored as `SHA-256(LOWER(TRIM(user_id)))` producing 64-character hex. The original user ID cannot be recovered from the hash.

### NFR-003 — Event Deduplication
`fct_feature_usage` must contain no duplicate events (same user, same event_name, same timestamp from multiple sources). Segment takes precedence for overlapping event categories.

### NFR-004 — Backwards Compatibility with Release 05
`dim_account_product_score` and `dim_account` must be designed to be joinable by the Release 05 customer analytics models. The `account_pk` surrogate key must match the key generated in the Release 03/05 staging models.

---

## 6. Data Requirements

| Source | Type | Owner | Key Data | Refresh |
|--------|------|-------|---------|---------|
| CoreFM PostgreSQL | CDC via Fivetran | Leon Yip | Assets, work orders, users, accounts | 15-min CDC |
| Segment | BigQuery Destination (streaming) | Leon Yip | Session events, transactional events | Near real-time |
| Mixpanel | Fivetran (daily) | Leon Yip | Feature discovery, workflow completion events | Daily |
| Intercom | Fivetran (6-hour) | Tara Obinna | Onboarding checklist events, NPS surveys | 6-hourly |
| Salesforce | Fivetran (6-hour) | Amara Diallo | Account, Contract (User_Seats__c), CSM assignment | 6-hourly |
| Feature taxonomy CSV | Static seed | Leon Yip | event_name → module/feature_group/feature mapping | Manual update |

---

## 7. Technical Requirements

- **Platform**: Google BigQuery (`core-dynamics-analytics-prod`)
- **Transformation**: dbt Core 1.7+ (existing `core_dynamics_analytics` project)
- **New BigQuery dataset**: `mart_product` (warehouse layer)
- **Orchestration**: Cloud Composer — extend `dataform_run_dag` with `intermediate_product` and `warehouse_product` Dataform phases
- **BI layer**: Looker — new `product.model.lkml`; 3 new explores
- **PII**: SHA-256 pseudonymisation; `assert_product_no_plain_text_user_id` assertion
- **Dependency**: 02-data-foundation staging models must be passing (staging layer provides CoreFM, Segment, Mixpanel, Intercom, Salesforce staging models)

---

## 8. Deliverables

| ID | Deliverable | Wire Artifact | Acceptance Owner |
|----|-------------|--------------|-----------------|
| D-12 | Product integration models (3 models) | dbt | Sophie Tanner |
| D-13 | Product warehouse models (6 models incl. score) | dbt | Sophie Tanner + Claire Ashworth |
| D-14 | LookML product semantic layer | semantic_layer | Sophie Tanner |
| D-15 | Dashboard PB-01: Product Adoption Overview | dashboards | Claire Ashworth |
| D-16 | Dashboard PB-02: Account-Level Product Usage | dashboards | Claire Ashworth + Tara Obinna |
| D-17 | Dashboard PB-03: Onboarding Funnel Analysis | dashboards | Claire Ashworth |

---

## 9. Timeline

Sprints 7–8 (Weeks 12–15 of the 22-week engagement). Dependency: Releases 02 and 03 must be deployed to dev environment.

---

## 10. Assumptions and Dependencies

- Leon Yip will provide the feature taxonomy CSV before staging model build begins
- Leon Yip will provide event-to-source mapping (Segment vs. Mixpanel) before model build
- Amara Diallo will confirm `User_Seats__c` Salesforce field population before `dim_account_product_score` build
- Claire Ashworth and Tara Obinna sign off revised Product Engagement Score weights before model build
- IoT device data (Step 6 of onboarding) is in scope — Leon Yip to confirm before `fct_onboarding_funnel` is built; if not, step 6 is tracked but marked as "optional" in the funnel

---

## 11. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|-----------|
| Feature taxonomy CSV not provided before build | High — `fct_feature_usage` cannot be built without it | Medium | Use placeholder taxonomy seed; update post-delivery when Leon Yip provides real mapping |
| Event deduplication introduces data loss | Medium — undercounts feature usage if Segment events dropped | Low | Validate row counts against raw Segment and Mixpanel tables; document dedup logic |
| `User_Seats__c` null for older contracts | Medium — `licence_utilisation_pct` will be null for those accounts | Medium | Null handled gracefully (show NULL not 0); document known gap in dashboard |
| Product Engagement Score weighting contested post-delivery | High — score recalculation requires full model rebuild | Low | Obtain written sign-off from Claire Ashworth and Tara Obinna before build |
| Segment and Mixpanel session volumes differ significantly | Medium — may indicate double-counting or gaps | Low | Add reconciliation data quality assertion comparing session counts across sources |

---

## 12. Scope Management

**In scope**:
- Feature usage (3-level taxonomy), session events, onboarding funnel (7 steps), workflow completion
- Product Engagement Score composite metric per account per month
- PB-01, PB-02, PB-03 dashboards
- Licence utilisation metric
- PII pseudonymisation for user IDs

**Out of scope**:
- In-app notifications or triggers based on product score (Release 05 Looker Actions covers this)
- LTV model (Release 05)
- Cohort analysis by acquisition channel — link to MA-02 is via `account_pk` join only
- Real-time product analytics (near real-time via Segment BigQuery Destination is acceptable)
- IoT telemetry data beyond what's in CoreFM PostgreSQL
