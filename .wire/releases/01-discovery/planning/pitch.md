# Shape Up Pitch
## Core Dynamics Data Platform Modernisation

**Engagement**: data_platform_modernisation
**Client**: Core Dynamics, Inc.
**Prepared by**: Mark Rittman, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (Autopilot — self-reviewed)

---

## 1. Appetite

**Big Batch — 22 weeks**

This is a full-scale data platform build serving four analytics domains with 26 deliverables and a $250,000 budget. The SOW explicitly states a 22-week engagement across three phases. Given the breadth — 18 data sources, five workstreams, a BQML model, governed semantic layer, and 13 dashboards — this is firmly a Big Batch engagement.

The 22-week appetite is fixed. Scope will be shaped to fit within it, not expanded to match all possible requirements. Any items that cannot be completed within 22 weeks are candidates for a future managed-service arrangement.

---

## 2. Problem Statement

Core Dynamics has no centralised data platform. Revenue, usage, and customer health data are fragmented across six or more disconnected systems. The resulting gaps are directly threatening the company's board-mandated NRR target:

- **CSMs cannot identify at-risk customers before they signal churn.** ChurnZero health scores ignore product usage, support history, and financial signals. A $340K churn was missed despite signals being visible for four months.
- **Marketing cannot prove pipeline impact.** $2.1M in demand gen spend is attributed through last-touch only. LinkedIn's contribution to pipeline is invisible.
- **Metrics are inconsistent.** MRR figures differ by up to 8% between Sales, Finance, and CS, undermining board-level confidence.
- **The single analyst spends 60% of his time on manual data wrangling**, with no capacity to do strategic analysis.
- **Operational performance is opaque.** SLA compliance and infrastructure costs are tracked in spreadsheets updated weekly — no intraday visibility, no alerting.

The company cannot reach NRR 115% without reliable, accessible data. This engagement builds the foundation.

---

## 3. Appetite Statement

**22 weeks, $250,000 — and we will not expand scope beyond what this budget can reliably deliver.**

This budget buys a production-grade Google Cloud data stack (BigQuery + Dataform + Cloud Composer + Fivetran + Looker), four analytics workstreams with 13 dashboards, a BigQuery ML churn risk model, a governed semantic layer, and full knowledge transfer to the Core Dynamics data engineering team.

What it does **not** buy: real-time streaming, a full data catalogue, predictive models beyond churn risk, embedded analytics, or ongoing managed service.

---

## 4. Solution

The core solution is a **governed, multi-domain analytics platform on Google Cloud** that gives every business function at Core Dynamics a reliable, self-service window into the metrics that drive their decisions.

**Fat-marker design:**

```
18 Source Systems
       │
  [Fivetran + Custom Connectors]
       │
  BigQuery Raw Datasets (one per source)
       │
  [Dataform — 3-layer transformation]
  staging → intermediate → warehouse (mart_marketing / mart_product / mart_customer / mart_ops)
       │
  [BigQuery ML — Churn Risk Model]
       │
  [Looker Semantic Layer — Governed Metrics]
       │
  13 Dashboards + Self-Service Explore
  (Marketing × 3, Product × 3, Customer × 3, Operations × 3, Pipeline Health × 1)
```

**Core elements that must exist for the solution to work:**

1. **Reliable pipelines**: All 18 sources landing in BigQuery on schedule, with data quality assertions passing daily.
2. **Unified warehouse layer**: Mart tables (`mart_marketing`, `mart_product`, `mart_customer`, `mart_ops`) as the single source of truth for every governed metric.
3. **Governed semantic layer**: Every metric defined once in LookML — MRR, NRR, CAC, GRR, product engagement score, churn risk — enforced across all dashboards.
4. **Explainable churn risk model**: BQML logistic regression surfacing not just a score but the three contributing signals per account, enabling CSM action.
5. **Self-service Looker**: Dashboards designed so that Rachel Summers, Tara Obinna, and their teams can answer their own questions without engineering involvement.

**Trade-offs and autonomous decisions:**

- **Dataform over dbt**: The SOW specifies Dataform, which aligns with the Google Cloud-native approach and the client's existing GitHub + GCP infrastructure. Wire will generate dbt-compatible SQL artifacts mapped to Dataform syntax conventions.
- **ChurnZero training data gap**: 14 months of ChurnZero data is below the 24-month SOW requirement for BQML training. Salesforce historical opportunity outcomes will be used as a proxy for the pre-ChurnZero period. The model card will document this limitation.
- **BQML threshold at 0.4**: Per Tara Obinna's explicit preference (higher recall over precision — a missed churn is worse than a false alarm), the churn model will be calibrated at a 0.4 probability threshold, subject to final validation with Tara during model evaluation.
- **U-shaped attribution as default**: Confirmed with Rachel Summers in discovery; gives equal weight to first touch and lead conversion, defensible for B2B pipeline discussions with Sales.
- **Marketing influence window: 180 days**: Confirmed with Rachel (not 90 days as in original SOW) to accommodate the ~4-month average enterprise sales cycle.

---

## 5. Rabbit Holes

The following are specific traps to avoid. Each one could consume disproportionate time if not explicitly bounded:

1. **HubSpot-Salesforce contact deduplication**: 12% mismatch rate is a known data quality issue. Do NOT attempt to fix the upstream sync as part of this engagement. Implement fuzzy matching at the Dataform staging layer and document the remaining coverage gap. Upstream fix is a change request.

2. **Salesforce Renewal_Date__c data quality**: 15% null/incorrect for pre-2023 accounts. Do NOT attempt bulk data remediation. Document the gap in the BQML model card and flag to Ben Tran as a client-side cleanup action.

3. **UTM retroactive clean-up**: ~30% of historic campaigns have non-standard UTMs. Do NOT attempt retroactive tag fixing. Accept historic gap, document it, and focus the attribution model on well-tagged data going forward. Niamh Collins owns forward-looking enforcement.

4. **GCP Billing label coverage for per-customer cost**: Coverage is unknown at project start. Do NOT build DO-02 (Infra Cost dashboard) assuming full label coverage. Scope the model to actual label coverage and document gaps. Sean Murphy to provide a label audit before the operations discovery session.

5. **BQML model complexity**: The churn model is a logistic regression, not a deep learning model. Do NOT add feature engineering complexity beyond the seven defined signals in the SOW plus the supplementary onboarding completion signal. Model explainability is more important than marginal AUC improvement.

6. **ChurnZero custom connector scope creep**: ChurnZero requires a custom Cloud Function (no native Fivetran connector). Do NOT over-engineer this into a generic sync framework. Build a targeted incremental sync for the specific ChurnZero objects needed (health scores, NPS, segment data) and document it clearly for Amara's team to maintain.

---

## 6. No-Gos

These are explicitly out of scope and must not be started without a written change request:

- Real-time streaming dashboards (sub-minute latency)
- Self-service ETL tooling or data catalogue (Dataplex, Alation)
- Predictive modelling beyond the churn risk model (expansion propensity, LTV, lead scoring)
- Salesforce, HubSpot, or Zendesk configuration changes
- GDPR/CCPA compliance review or legal sign-off
- Mobile or embedded analytics (Looker embedded in CoreFM)
- Training programme beyond the three defined knowledge transfer sessions
- Ongoing managed service post-engagement
- Salesforce data clean-up or UTM retroactive remediation
- NetSuite advanced financial analytics beyond what feeds the warehouse models

---

## 7. Open Questions

These must be resolved before or during build — they do not block the discovery sprint but will affect design decisions in delivery:

| # | Question | Blocking? | Owner |
|---|----------|-----------|-------|
| OQ-01 | BQML threshold: 0.4 (Tara's preference) or 0.5 (standard)? Run A/B on held-out set during model evaluation. | No | Sophie + Tara |
| OQ-02 | Is `Contract.User_Seats__c` consistently populated in Salesforce? Affects licence_utilisation_pct metric. | Yes — blocks product engagement score | Amara + Leon |
| OQ-03 | GCP Billing label coverage for per-customer cost? Scope DO-02 accordingly. | Yes — blocks ops dashboard design | Sean Murphy |
| OQ-04 | Revised product engagement score weighting — add "work order within 30 days" as 10% component? | Yes — needs sign-off from Claire + Tara before build | Sophie, Claire, Tara |
| OQ-05 | HubSpot-Salesforce 12% contact mismatch: fuzzy match at staging or flag and exclude? | No — document gap; build with clean data | Kofi + Niamh |
| OQ-06 | Salesforce opportunity history as proxy for pre-ChurnZero BQML training data? | Yes — affects model training timeline | Sophie + Ben Tran |
| OQ-07 | Looker Alerts: include recommended playbook action alongside each churn signal? | No — can add post-MVP | Tara Obinna |

---

## 8. Downstream Releases

Based on the 22-week SOW structure, three phases, and four analytics workstreams, the following delivery releases are proposed:

| Release | Name | Type | Scope Summary | Priority |
|---------|------|------|---------------|----------|
| 02 | 02-data-foundation | pipeline_only | GCP project setup, IAM, Fivetran connectors (18 sources), Dataform staging models, Cloud Composer orchestration, data quality assertions, pipeline health dashboard | 1 |
| 03 | 03-marketing-analytics | full_platform | Marketing intermediate and warehouse models, LookML marketing views/explores, dashboards MA-01/MA-02/MA-03, multi-touch attribution, semantic layer contribution | 2 |
| 04 | 04-product-analytics | full_platform | Product warehouse models (with PII pseudonymisation), product engagement score model, feature taxonomy, LookML product views/explores, dashboards PB-01/PB-02/PB-03 | 3 |
| 05 | 05-customer-analytics | full_platform | Customer warehouse models, BQML churn risk model, Looker RLS, Looker Actions (Salesforce task + QBR export), LookML customer views, dashboards CA-01/CA-02/CA-03 + Scheduled Alerts | 4 |
| 06 | 06-operational-analytics | dbt_development | Operations warehouse models, LookML operations views, dashboards DO-01/DO-02/DO-03, semantic layer governance review, documentation + knowledge transfer | 5 |

**Dependencies:**
- 03-marketing-analytics can start once staging models (from 02) are complete for Salesforce, HubSpot, and ad platforms
- 04-product-analytics requires CoreFM PostgreSQL access provisioned by Amara's team
- 05-customer-analytics depends on 04-product-analytics warehouse models (dim_account_product_score feeds dim_account_health)
- 06-operational-analytics depends on Zendesk, PagerDuty, and GCP Billing staging models from 02

---

## 9. Betting Table Case

**Why this is worth doing now:**

1. **The NRR gap is quantified and urgent.** The board has set a specific target (104% → 115%) within 18 months. Without this platform, Core Dynamics has no systematic way to identify which of 312 accounts are driving that gap or what to do about it. The $340K Meridian Healthcare churn is a concrete, documented example of the cost of inaction.

2. **The foundation is absent, not broken.** Core Dynamics doesn't have a legacy data platform to migrate — they have no platform. This means there are no migration risks, no political battles over existing tool ownership, and no decommissioning costs. The build starts from a clean slate.

3. **Stakeholder alignment is exceptionally strong.** All five workstream sponsors (Priya Nair, Rachel Summers, Claire Ashworth, Tara Obinna, Harriet Drummond) have actively participated in discovery, articulated specific pain points, and committed to UAT availability. The kickoff was attended by the CTO personally — unusual for a vendor engagement at this scale.

---

## 10. Metrics for Success

Based on SOW Section 12 (Acceptance Criteria) and stakeholder discovery sessions:

| Metric | Target | Measured By |
|--------|--------|-------------|
| Data pipeline reliability | < 0.1% error rate over 7-day observation; Dataform assertions passing for 3 consecutive daily runs | Fivetran + Cloud Composer monitoring |
| Warehouse data accuracy | Key business metrics (ARR, NRR, CAC) within ±2% of Finance's spreadsheets | Reconciliation exercise with James Petit |
| Dashboard performance | All dashboards load within 5 seconds for default date range (prior 90 days) in production Looker | Looker performance profiler |
| BQML churn model quality | AUC-ROC ≥ 0.75; precision ≥ 60% at 0.5 threshold (or 0.4 if Tara's preference confirmed) | Model evaluation holdout set |
| Row-level security | CSMs cannot view accounts not assigned to them; verified in UAT | UAT test cases in release brief |
| Stakeholder sign-off | UAT sign-off from all four workstream sponsors within 5 business days of UAT delivery | UAT sign-off tracker |
| NRR directional improvement | NRR trending toward 115% within 6 months of platform go-live | Quarterly business review |
| Analyst capacity freed | James Petit's manual reporting time reduced by ≥ 50% within 60 days of go-live | Self-reported time tracking |
