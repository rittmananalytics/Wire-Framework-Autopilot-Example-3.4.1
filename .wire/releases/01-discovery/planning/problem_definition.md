# Problem Definition
## Core Dynamics Data Platform Modernisation

**Engagement**: data_platform_modernisation
**Client**: Core Dynamics, Inc.
**Prepared by**: Mark Rittman, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (Autopilot — self-reviewed)

---

## 1. Who Has the Problem

**Primary stakeholders:**

| Stakeholder | Role | Pain Point |
|-------------|------|------------|
| Priya Nair | CTO / Executive Sponsor | Cannot reliably measure NRR progress toward board target of 115%; no platform for data-driven decision-making |
| Tara Obinna | VP Customer Success | Reactive churn management; ChurnZero health scores lack product usage signals; CSMs rely on gut feel |
| Rachel Summers | VP Marketing | $2.1M demand gen spend with no reliable multi-touch attribution; LinkedIn contribution invisible; last-touch only |
| Claire Ashworth | VP Product | No account-level product usage visibility; cannot identify at-risk users or prioritise roadmap with data |
| Harriet Drummond | COO | SLA performance tracked in Google Sheets with no intraday visibility; no per-customer infrastructure cost data |
| James Petit | Finance Analyst | 60% of time spent on manual CSV exports, VLOOKUP reconciliations, and ad-hoc requests |
| 14 CSMs (Tara's team) | Customer Success Managers | 3–5 hours per QBR prep; no data-driven account prioritisation; cannot identify at-risk accounts proactively |

**Secondary stakeholders:** Owen Brady (Demand Gen), Niamh Collins (Marketing Ops), Ben Tran (CS Ops), Carlos Vega (Support Engineering), Leon Yip (Senior PM), Sandra Kowalski (CFO).

---

## 2. What They Are Trying to Do

Core Dynamics stakeholders have distinct but interconnected jobs-to-be-done:

1. **CTO / Board**: Demonstrate progress toward NRR 115% within 18 months by identifying and acting on churn risk and expansion signals before they manifest in the renewal cycle.

2. **Customer Success team**: Proactively identify which of 312 enterprise accounts are at risk of churning or ripe for expansion — before the customer signals it themselves — and equip CSMs with specific, actionable reasons to act on.

3. **Marketing team**: Understand which channels, campaigns, and content assets are actually generating pipeline and closed-won revenue (not just MQLs), so that $2.1M of demand gen spend can be reallocated to what works.

4. **Product team**: Know which CoreFM features are being adopted at what depth by which accounts, so that roadmap prioritisation is driven by usage data rather than loudest-voice stakeholder requests.

5. **Operations team**: Track SLA compliance, infrastructure cost efficiency, and on-call burden in real time, without manual spreadsheet reconciliation each week.

6. **Finance**: Have a single, agreed definition of key metrics (MRR, NRR, CAC) that all teams reference — eliminating the 8% discrepancy in MRR figures that has reached board level.

---

## 3. What Is in the Way

Six distinct obstacles prevent stakeholders from doing their jobs effectively today:

**Obstacle 1 — No single source of truth.** Revenue, usage, and customer health data exist in at least six separate systems (Salesforce, ChurnZero, Mixpanel, NetSuite, Zendesk, CoreFM PostgreSQL). There is no automated reconciliation between them. MRR figures reported by Sales, Finance, and Customer Success differ by up to 8%.

**Obstacle 2 — Analyst bottleneck.** James Petit (Finance) is the sole data analyst. He spends approximately 60% of his time on manual CSV exports, VLOOKUP reconciliations, and ad-hoc requests. Business stakeholders cannot self-serve. The analyst is a single point of failure and a constraint on the entire business.

**Obstacle 3 — No product usage visibility at account level.** CoreFM generates rich product usage telemetry but it is only accessible to engineers querying the production PostgreSQL database directly. Product and CS teams have no visibility into feature adoption, session depth, or onboarding completion at the account level.

**Obstacle 4 — Marketing attribution is last-touch only.** HubSpot's native attribution captures only the last-touch conversion before an MQL. Multi-touch attribution across paid channels (Google, LinkedIn, Meta), SDR outreach, and content assets is entirely blind. LinkedIn's contribution to pipeline is invisible, making budget decisions politically rather than analytically driven.

**Obstacle 5 — Reactive customer success.** ChurnZero health scores are based primarily on login events and do not incorporate product feature usage, support history, or financial signals. The CS team identifies churn risk when accounts decline renewal calls — by which point intervention is usually too late (example: Meridian Healthcare, $340K ARR lost despite signals being visible for 4 months).

**Obstacle 6 — Operational data trapped in spreadsheets.** Support ticket SLA performance is tracked in a combination of Zendesk and a Google Sheet updated once per week. Infrastructure cost allocation is a monthly manual exercise. There is no alerting, no intraday visibility, and no historical trending for operational metrics.

---

## 4. Current Workarounds

| Problem | Current Workaround | Why It Falls Short |
|---------|--------------------|-------------------|
| No single MRR source | Each team maintains its own spreadsheet | 8% discrepancy reaches board level; undermines confidence in all data |
| Marketing attribution | Last-touch HubSpot attribution | LinkedIn, content, and SDR contribution invisible; budget decisions are political |
| HubSpot-Salesforce sync | Niamh Collins runs weekly manual CSV export and VLOOKUP | 12% contact mismatch rate; ~2 hours per week; attribution drops out for unmatched contacts |
| Customer health | ChurnZero login-event health scores + CSM gut feel | Reactive only; $340K churn example cited; CSMs call accounts they like, not accounts that need attention |
| QBR preparation | CSMs pull data from Salesforce + ChurnZero + Zendesk manually | 3–5 hours per QBR; not scalable with 14 CSMs and 312 accounts |
| CS-Salesforce renewal reconciliation | Ben Tran and Tara Obinna do manual VLOOKUP every Monday morning | ~2 hours per week; error-prone |
| Product usage data | Engineers query production PostgreSQL directly | No self-service; no account-level aggregates; PII exposure risk |
| SLA tracking | Google Sheet updated once per week by support analyst | No intraday visibility; no alerting; no trend analysis |
| Infrastructure cost | Sean Murphy monthly manual GCP billing reconciliation | No per-customer visibility; no anomaly alerting |

---

## 5. What "Solved" Looks Like

Success for this engagement means:

**For the business:**
- NRR trajectory measurably improving toward 115% target, with data visibility to track and intervene
- Single agreed definition of MRR, NRR, CAC, and GRR, referenced by all teams, verified against Finance's spreadsheets within ±2%
- Board-level confidence in the numbers — the 8% discrepancy is eliminated

**For Customer Success:**
- CSMs start each day with an automated priority list: which three accounts need attention today, with specific reasons (e.g., "Asset management module usage dropped 60% in 30 days")
- Early-warning alerts fire in Slack when an account enters the At Risk band, before the customer signals it
- QBR prep time reduced from 3–5 hours to ~1 hour via one-click data pull
- Churn risk model with AUC-ROC ≥ 0.75 and precision ≥ 60% at 0.5 threshold; calibrated toward higher recall (Tara's preference: 0.4 threshold under consideration)

**For Marketing:**
- Multi-touch attribution visible across all five models (first-touch, last-touch, linear, time-decay, U-shaped); U-shaped as default
- Campaign-level cost-per-SQL and cost-per-closed-won available; LinkedIn contribution quantified
- Budget reallocation decisions based on pipeline-to-spend ratio, not MQL volume
- Marketing influence window set to 180 days (confirmed in discovery)

**For Product:**
- Account-level feature adoption visible at Module, Feature Group, and Feature level
- Product engagement score (0–100) refreshed daily, incorporating DAU/MAU, feature breadth, core feature activation, NPS, and onboarding completion
- Onboarding funnel visible step-by-step; accounts stalled at each step identifiable by CSM

**For Operations:**
- SLA compliance rate by priority (P1/P2/P3) visible in real time (4-hour refresh)
- Per-customer infrastructure cost tracked daily; anomaly alerts when cost spikes >20% week-over-week
- MTTA and MTTR trended over 13 weeks; on-call burden distributed equitably

**For Finance / All teams:**
- Self-service analytics via Looker; James Petit's manual report burden eliminated
- All governed metrics defined once in the Looker semantic layer; no analyst-written SQL in dashboards

---

## 6. Constraints

| Constraint | Detail |
|-----------|--------|
| **Budget** | $250,000 total; milestone-based payment ($42.5K on signature, through to $25K on final sign-off) |
| **Timeline** | 22 weeks across 3 phases; Phase 1 ends Week 4, Phase 2 ends Week 14, Phase 3 ends Week 22 |
| **Technology** | Google Cloud (BigQuery, Dataform, Cloud Composer); Looker; Fivetran; GitHub |
| **PII handling** | CoreFM PostgreSQL contains PII (user emails, names); pseudonymisation at staging layer required; legal sign-off from Diane Hooper before implementation (Priya Nair to introduce) |
| **Looker licences** | Core Dynamics must procure Looker Standard/Enterprise with minimum 30 Standard Users + 5 Developer users |
| **Fivetran** | Core Dynamics must hold/procure Fivetran Business Critical account with sufficient MAR for 18 connectors |
| **Data availability** | ChurnZero historical data only 14 months (SoW assumes 24 for BQML training); Salesforce opportunity data proposed as proxy |
| **Credential provisioning** | All API credentials/tokens required within 5 business days of written request; delays cause timeline adjustment |
| **CoreFM PostgreSQL** | Network access (Cloud SQL Auth Proxy) must be provisioned by Amara Diallo's team before Phase 2 |
| **Stakeholder availability** | Workstream sponsors available for 1-hour requirements review (Week 1) and 2-hour UAT (Phase 3) |
| **Fiscal year** | Core Dynamics FY starts 1 February; date dimension must include fiscal calendar offsets |
| **Row-level security** | CSMs may only see their own accounts; financial metrics restricted to finance_viewers and leadership groups |

---

## 7. Previously Ruled Out

Based on the SOW Section 10 (Out of Scope) and stakeholder sessions:

| Item | Why Ruled Out |
|------|--------------|
| Real-time streaming dashboards (sub-minute latency) | Out of scope; all dashboards refresh on schedules (4h–daily); streaming architecture is a future phase |
| Self-service ETL tooling or data catalogue (Dataplex, Alation) | Out of scope; runbook covers operational documentation; full catalogue is future phase |
| Predictive modelling beyond churn risk | Expansion propensity, LTV prediction, lead scoring are not in scope |
| Salesforce / HubSpot / Zendesk configuration changes | RA will read from these systems only; schema/workflow changes are client responsibility |
| GDPR/CCPA compliance review or legal sign-off | PII pseudonymisation will be implemented; formal compliance sign-off is Core Dynamics legal team's responsibility |
| Mobile or embedded analytics | All Looker content via Looker web app; embedded analytics (CoreFM in-app) is future phase |
| Training programme beyond 3 knowledge transfer sessions | Three KT sessions (D-25) are in scope; a broader enablement programme is not |
| Ongoing managed service | Engagement covers build and handover only; managed service is a separate post-engagement retainer |
| UTM retroactive clean-up | ~30% of campaigns have non-standard UTMs; historic gap accepted and documented; Niamh Collins is driving forward-looking enforcement |
| Salesforce data clean-up | ~15% null/incorrect Renewal_Date__c fields; client-owned remediation; RA will document impact |

---

## 8. Impact Table

| Domain | Current State | Desired State | Key Metric |
|--------|--------------|---------------|------------|
| NRR / Board Reporting | 104% NRR; board-level confidence low due to metric inconsistency | 115% NRR target within 18 months; single-definition metrics across all teams | NRR trend; MRR discrepancy eliminated |
| Marketing Attribution | Last-touch only; LinkedIn contribution invisible; $2.1M spend with no reliable ROI | Multi-touch attribution across 5 models; pipeline-to-spend ratio by channel | CAC by channel; pipeline generated per $ spend |
| Customer Health | Reactive; ChurnZero login-only health scores; churn identified at renewal call | Proactive; explainable health scores; at-risk alerts 60–90 days before renewal | Early warning rate; NRR improvement |
| Product Analytics | Product usage only accessible to engineers; no account-level data | Daily account-level product engagement scores; feature adoption visible at module/feature group/feature | DAU/MAU by account; onboarding completion rate |
| Operational Efficiency | SLA tracked in weekly Google Sheet; no intraday visibility | Real-time SLA compliance by priority; per-customer cost visibility | SLA compliance rate; infra cost per customer |
| Analyst Capacity | James Petit spends 60% on manual work | Self-service analytics via Looker; analyst freed for strategic work | Hours freed per week |

---

## 9. Stakeholder Sign-off Requirements

The following sign-offs are required before or during execution:

| Sign-off | Owner | When |
|----------|-------|------|
| PII pseudonymisation approach | Priya Nair + Diane Hooper (legal) | End of Week 2 |
| Revised product engagement score weighting | Claire Ashworth + Tara Obinna | Before data model build |
| Metric Definitions document (MRR, NRR, CAC, etc.) | All workstream sponsors | Phase 2 |
| BQML model card | Tara Obinna | Phase 3 |
| Phase 1 milestone sign-off | Amara Diallo | End of Week 4 |
| Phase 2 milestone sign-off | Amara Diallo + workstream leads | End of Week 14 |
| Final sign-off | Priya Nair | End of Week 22 |

---

## 10. Open Questions

| # | Question | Owner | Priority |
|---|----------|-------|----------|
| OQ-01 | Should the BQML churn model probability threshold be set at 0.4 (higher recall, Tara's preference) or 0.5 (standard)? | Sophie Tanner + Tara Obinna | High |
| OQ-02 | Is `Contract.User_Seats__c` consistently populated in Salesforce for licence utilisation calculation? | Amara Diallo + Leon Yip | High |
| OQ-03 | What is the GCP Billing label coverage for per-customer cost attribution? Sean Murphy to provide audit before operations discovery session. | Sean Murphy | High |
| OQ-04 | Should "work order created within 30 days" be added as a 10% weighted component in the product engagement score (reducing DAU/MAU and core feature activation from 25% to 20% each)? | Sophie Tanner, Claire Ashworth, Tara Obinna | Medium |
| OQ-05 | What is the recommended approach to handle the 12% HubSpot-Salesforce contact mismatch — upstream fix or fuzzy matching at staging layer? | Kofi Asante + Niamh Collins | High |
| OQ-06 | Can Salesforce opportunity data (pre-ChurnZero) be used as a proxy to extend BQML training data from 14 months to 24 months? | Sophie Tanner + Ben Tran | Medium |
| OQ-07 | For the Looker Alerts — should CSM Slack notifications include a recommended action (playbook) alongside each risk signal? | Tara Obinna | Medium |
