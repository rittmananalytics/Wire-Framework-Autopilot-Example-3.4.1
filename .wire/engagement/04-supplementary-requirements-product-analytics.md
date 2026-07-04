# Supplementary Requirements — Product Analytics Workstream

**Document Type:** Supplementary Requirements Specification
**Workstream:** B — Product Analytics
**Prepared by:** Sophie Tanner (Rittman Analytics), following discovery session with Claire Ashworth and Leon Yip
**Date:** 6 February 2026
**Status:** DRAFT — pending review by Claire Ashworth

---

## Discovery Session Summary

The Product Analytics discovery session was held on Friday 5 February 2026 with Claire Ashworth (VP Product) and Leon Yip (Senior PM, Core Platform). Fatima Al-Rashidi (Senior PM, Integrations) was unable to attend but has been circulated this document for review.

The session surfaced several important clarifications and additions to the product analytics requirements set out in the SoW. The key additions are documented below.

---

## Addition 1: Feature Taxonomy

The SoW refers to "features" as the unit of product analytics measurement, but the CoreFM product has three levels of feature hierarchy that need to be reflected in the data model:

| Level | Description | Example |
|---|---|---|
| Module | Top-level product area | Maintenance Management |
| Feature Group | Functional area within a module | Work Order Management |
| Feature | Specific capability or action | "Create Recurring Work Order" |

**Requirement:** The `mart_product.fct_feature_usage` model must include `module_id`, `feature_group_id`, and `feature_id` dimensions. Dashboards should support filtering and grouping at all three levels. The Product Adoption heatmap (PB-01) should default to Feature Group level, with drill-through to Feature level.

**Data source:** Leon will provide a static feature taxonomy CSV mapping `event_name` values in Mixpanel to the three-level hierarchy. This will be loaded into BigQuery as a reference table (`raw_corefm_db.feature_taxonomy`) and joined at the staging layer.

---

## Addition 2: Licence Utilisation Metric

Claire raised that "licence utilisation" — the ratio of active users to contracted user seats — is a critical metric that appears in multiple contexts: product health, customer health (for expansion signals), and the QBR template. This metric is not explicitly defined in the SoW.

**Requirement:** Add `licence_utilisation_pct` to the `mart_product.dim_account_product_score` model:

```sql
licence_utilisation_pct = 
  COUNT(DISTINCT active_user_id WHERE last_login >= CURRENT_DATE - 30) 
  / contracted_user_seats
```

Where `contracted_user_seats` comes from Salesforce `Contract.User_Seats__c` field.

**Note:** Amara Diallo needs to confirm whether `User_Seats__c` is populated consistently in Salesforce. Leon believes there are some older contracts where this field is null.

---

## Addition 3: Onboarding Step Definitions

The SoW references an "onboarding funnel" but does not specify the steps. Leon provided the following onboarding checklist steps, which are tracked in Intercom:

| Step | Step ID | Description | Typically completed by |
|---|---|---|---|
| 1 | `onboarding_invite_users` | Admin invites at least 3 users | Day 1–3 |
| 2 | `onboarding_create_first_asset` | At least one asset record created | Day 1–7 |
| 3 | `onboarding_import_asset_list` | Asset bulk import completed (≥10 assets) | Day 3–14 |
| 4 | `onboarding_create_work_order` | First work order created and assigned | Day 7–21 |
| 5 | `onboarding_configure_report` | First scheduled report configured | Day 14–30 |
| 6 | `onboarding_integrate_iot` | First IoT device or sensor connected (optional) | Day 30–90 |
| 7 | `onboarding_qbr_ready` | Account manager marks account as QBR-ready | Day 60–90 |

Steps 1–5 are considered "core onboarding." Steps 6–7 are considered "extended onboarding." The `fct_onboarding_funnel` model should track completion of each step, with timestamp and days-since-signup for each completion event.

**Claire's note:** Step 4 (work order creation) is the most predictive step for long-term retention based on historical observation — accounts that don't create a work order in the first 30 days have significantly higher churn rates at 12 months. This should potentially be given additional weight in the product engagement score model, or at minimum flagged as a critical signal in the CS dashboard.

> **Sophie's note:** This is strong justification for adding "work order created within 30 days" as a binary signal in the `dim_account_product_score` composite score. Recommend adding this as a 10% weighted component, reducing DAU/MAU weight from 25% to 20% and core feature activation weight from 25% to 20%. To be validated with Tara Obinna (CS) as this affects the health score model.

---

## Addition 4: Segment vs. Mixpanel Event Coverage

During the session it became clear that there is partial overlap between the events tracked in Segment (via the CoreFM backend) and the events tracked in Mixpanel (via frontend JavaScript). This creates a risk of double-counting if both sources are used without deduplication.

**Findings:**
- Segment captures server-side events: login, asset create/update/delete, work order create/update/close, report generate
- Mixpanel captures client-side events: page views, button clicks, feature discovery events, workflow completion events
- There is overlap on `work_order_created` and `asset_created` — both Segment and Mixpanel fire events for these actions

**Requirement:** The `fct_feature_usage` model must use a single authoritative source per event type, not a union of both. Agreed approach:

| Event category | Source |
|---|---|
| Core transactional events (asset, work order, report) | Segment (server-side, more reliable) |
| Page/feature discovery events | Mixpanel (client-side only) |
| Workflow completion events | Mixpanel (instrumented at workflow conclusion) |
| Session events | Segment (session_start events) |

Leon to provide a definitive event-to-source mapping document before the staging model build for this workstream begins.

---

## Addition 5: Account Segment Definitions

The SoW references filtering dashboards by "account segment" but does not specify how segments are defined. Core Dynamics uses the following segments, stored in Salesforce `Account.Segment__c`:

| Segment | Definition |
|---|---|
| Enterprise | ACV ≥ $150K or employee count ≥ 1,000 |
| Mid-Market | ACV $50K–$149K or employee count 200–999 |
| SMB | ACV < $50K or employee count < 200 |
| Strategic | Manually designated by CRO — typically top-20 accounts by ARR regardless of size |

The `dim_account` shared dimension in LookML must include a `segment` dimension derived from Salesforce, with the `Strategic` designation taking precedence over size-based rules.

---

## Revised Product Engagement Score Model

Incorporating the additions above, the proposed revised weighting for `dim_account_product_score`:

| Signal | Original Weight | Revised Weight | Rationale |
|---|---|---|---|
| DAU/MAU ratio (last 30 days) | 25% | 20% | Slightly reduced to accommodate new signal |
| Distinct features used (last 30 days) | 20% | 20% | Unchanged |
| Core feature activation | 25% | 20% | Reduced; work order signal separated out |
| Work order created within first 30 days | — | 10% | New signal; high predictive value per Claire |
| Licence utilisation % | — | 5% | New signal; low weight, more expansion indicator |
| NPS response (last 180 days) | 15% | 15% | Unchanged |
| Onboarding checklist completion % | 15% | 10% | Slightly reduced |
| **Total** | **100%** | **100%** | |

**Note:** This revised weighting requires sign-off from both Claire Ashworth (Product) and Tara Obinna (CS) before the `dim_account_product_score` model is built, as changes will affect the Customer Analytics workstream.

---

## Open Questions

| Question | Owner | Due |
|---|---|---|
| Confirm `User_Seats__c` field population in Salesforce (for licence utilisation) | Amara Diallo | Before Phase 2 model design |
| Provide feature taxonomy CSV (Mixpanel event → module/feature group/feature) | Leon Yip | Before Phase 2 staging model build |
| Provide event-to-source mapping (Segment vs. Mixpanel) | Leon Yip | Before Phase 2 staging model build |
| Sign off revised product engagement score weighting | Claire Ashworth, Tara Obinna | Before `dim_account_product_score` build |
| Confirm whether IoT device data (Step 6) is in scope for onboarding funnel | Leon Yip | Before `fct_onboarding_funnel` build |
