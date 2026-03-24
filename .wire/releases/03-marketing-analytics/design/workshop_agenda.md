# Workshop Agenda
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Facilitator**: Sophie Tanner (Rittman Analytics)
**Date**: TBD (Week 7, Sprint 5)
**Duration**: 2 hours
**Format**: Video call (Zoom/Teams) + shared Miro board
**Attendees**: Rachel Summers, Owen Brady, Niamh Collins, Sophie Tanner, Kofi Asante

> **Autopilot Note**: Workshop materials generated as reference — no workshop conducted in Autopilot mode. These materials serve as a guide for the optional live discovery session. All ambiguities with a known answer from discovery docs (kickoff transcript, Rachel Summers session) have been pre-resolved; only unresolved items remain as workshop topics.

---

## Pre-Workshop Preparation

**For Rittman Analytics (Sophie Tanner)**:
- [ ] Share requirements_specification.md with attendees 3 days in advance
- [ ] Prepare Miro board with attribution model comparison whiteboard
- [ ] Pull example HubSpot funnel report to demonstrate stage naming conventions
- [ ] Prepare sample UTM coverage analysis from HubSpot (Niamh Collins to pull)

**For Core Dynamics attendees**:
- [ ] Review requirements_specification.md (FR-001 through FR-009)
- [ ] Niamh Collins: bring HubSpot form-to-asset mapping document (or status update)
- [ ] Owen Brady: bring example LinkedIn campaign report for spend field review
- [ ] Rachel Summers: confirm U-shaped attribution weight parameters (40/40/20 as specified)

---

## Agenda

### Part 1: Attribution Model Definitions (40 minutes)

**Goal**: Confirm the five attribution model calculation rules, especially U-shaped, and agree on edge cases.

#### 1.1 U-Shaped Model — Weights and Edge Cases (20 min)

**Facilitator**: Walk through U-shaped model as specified (FR-004):
- 40% first touch, 40% lead conversion touch (MQL or SAL — whichever comes first), 20% split across middle touches

**Open questions to resolve**:

| # | Question | Context | Decision Options |
|---|----------|---------|-----------------|
| A1 | **Which event defines "lead conversion" in U-shaped?** | Requirements spec says "MQL/SAL" — if both exist in the journey, which one receives the 40%? | (a) Always MQL; (b) Always SAL; (c) First of the two in the journey; (d) Last of the two |
| A2 | **What if the journey has only 2 touches (no middle)?** | With first + last = 100% in a 2-touch journey, the 20% has nowhere to go | (a) Redistribute to first/last 50/50; (b) First-touch only for 2-touch journeys; (c) Linear model fallback |
| A3 | **What if first touch = lead conversion touch?** | Contact's first ever interaction is the MQL event (e.g., directly from a form) | (a) 80% to that single touch; (b) Fall back to first-touch model |

#### 1.2 Influence Window Confirmation (10 min)

**Topic**: 180-day window is confirmed (Rachel Summers, kickoff doc). Clarify calculation:
- Does 180-day window apply from **opportunity creation date** backwards? ✓ (assumed yes)
- Does it include or exclude the day of opportunity creation?
- For time-decay model: is the 30-day half-life measured from **opportunity creation date** or **touch date**?

| # | Question | Decision Options |
|---|----------|-----------------|
| B1 | **Time-decay half-life reference point** | (a) Decay from opportunity creation date backwards (closer to opp = more credit); (b) Decay from first touch forwards |
| B2 | **Boundary condition: touch exactly on day 180** | (a) Include touches on day 180; (b) Strictly less than 180 days |

#### 1.3 Marketing-Sourced vs. Marketing-Influenced Definition (10 min)

**Topic**: Confirm the sourced/influenced definitions in FR-004:
- **Marketing-sourced**: first touch in the journey is a marketing touch (not SDR/outreach)
- **Marketing-influenced**: at least one marketing touch in the 180-day window

**Open questions**:

| # | Question | Context |
|---|----------|---------|
| C1 | **Are Outreach.io SDR touches classified as "marketing" or "sales"?** | Currently: Outreach touches are in fct_attribution_touches but SDR-originated. For sourced/influenced flags, should they count as marketing touches? |
| C2 | **If a contact was sourced by sales outreach but later had marketing touches, is the opportunity "marketing-influenced"?** | Definition says "at least one marketing touch" — confirm yes, even if first touch was SDR |

---

### Part 2: Data Source Clarifications (30 minutes)

**Goal**: Clarify specific data availability questions for the six marketing data sources.

#### 2.1 HubSpot Funnel Stage Mapping (15 min)

**Attendee**: Niamh Collins

| # | Question | Impact |
|---|----------|--------|
| D1 | **SAL stage: is it a HubSpot lifecycle stage or a custom property?** | Determines how we extract it in staging; custom property needs separate stg_ model |
| D2 | **Stage timestamp availability**: Does HubSpot provide `became_mql_date`, `became_sal_date`, `became_sql_date` as native fields, or do we need to reconstruct from audit log? | If audit log only, funnel model (FR-001) requires HubSpot Contacts audit history — confirm connector pulls this |
| D3 | **Form-to-asset mapping**: Niamh's mapping doc — what format? CSV / HubSpot property / manual table? | Determines how `asset_id` and `asset_category` are populated in FR-003 |
| D4 | **Email open vs. click distinction in HubSpot engagement data**: Are open events reliably captured post-Apple MPP (iOS 15+)? Should opens be excluded from attribution touches? | Rachel Summers / Niamh Collins to decide whether email opens should be devalued or excluded |

#### 2.2 Ad Platform Spend Data (10 min)

**Attendee**: Owen Brady

| # | Question | Impact |
|---|----------|--------|
| E1 | **LinkedIn Ads: campaign vs. ad group granularity** — Requirements specify ad-group level. Does Owen's LinkedIn account have API access at ad group (Creative) level, or campaign level only? | If campaign-level only, FR-002 granularity for LinkedIn changes |
| E2 | **Meta Ads: ad set naming convention** — Is there a standard naming convention for Meta ad sets that maps to campaign type? Or is it freeform? | Affects `dim_campaign` campaign_type classification logic |
| E3 | **Historical spend: how far back does ad platform data go?** — Google Ads / LinkedIn Ads / Meta Ads. Is 24+ months of history available for CAC trend analysis in MA-03? | Affects FR-009 CAC by quarter (last 8 quarters = 24 months needed) |

#### 2.3 Outreach.io Touch Completeness (5 min)

**Attendee**: Sophie Tanner (confirm with Kofi Asante)

| # | Question | Impact |
|---|----------|--------|
| F1 | **Outreach calls: are all inbound + outbound calls logged in Outreach, or only SDR-initiated?** | Determines completeness of attribution touches from Outreach |
| F2 | **Outreach-to-HubSpot contact match**: Does Outreach use the same contact email as HubSpot, or a different identifier? | Affects join logic in fct_attribution_touches |

---

### Part 3: Dashboard Design Decisions (25 minutes)

**Goal**: Confirm dashboard layout choices and metrics definitions before mockup generation.

#### 3.1 MA-01 Demand Generation Performance (10 min)

**Attendee**: Rachel Summers, Owen Brady

| # | Question | Context |
|---|----------|---------|
| G1 | **Majority pipeline stage calculation**: Requirements specify "mode of Salesforce stages for leads from that campaign." Should this use (a) current stage of the opportunity, or (b) the stage the opportunity was most recently at when last touched by this campaign? | Complex — mode of current stage is simpler |
| G2 | **Cost per MQL/SQL by channel**: Should this use (a) total channel spend / total channel MQLs (blended rate), or (b) campaign-specific rates? | Determines whether the "by channel" table is aggregated or campaign-level |
| G3 | **Period-over-period tile: which metrics get % change arrows?** | FR-007 lists "leads, MQLs, spend, pipeline" — confirm these four only, or add SALs, SQLs, opportunities? |

#### 3.2 MA-02 Multi-Touch Attribution Explore (10 min)

**Attendee**: Rachel Summers

| # | Question | Context |
|---|----------|---------|
| H1 | **Content asset influence analysis (FR-008)**: "assets appearing in closed-won vs. lost journeys" — should this be (a) count of journeys containing the asset, or (b) sum of attributed revenue to touches involving the asset? | Different metrics tell different stories |
| H2 | **Funnel velocity (FR-008)**: "average days per stage by channel" — does "channel" here mean the channel of the first touch, or the dominant channel in the journey? | First touch is simpler; dominant requires aggregation |
| H3 | **Attribution share trend (FR-008)**: 12-month area chart — should this show (a) percentage of attributed revenue by channel, or (b) absolute attributed revenue? | Percentage share is more useful for trend analysis |

#### 3.3 MA-03 Pipeline Contribution (5 min)

**Attendee**: Rachel Summers, David Park (CRO)

| # | Question | Context |
|---|----------|---------|
| I1 | **LTV:CAC ratio placeholder (FR-009)**: Spec says "may be placeholder until Release 05." Confirm: show tile with "LTV data available in Release 05" message, or omit tile entirely from MA-03? | User experience decision |
| I2 | **Marketing ROI ratio definition**: Spec says "pipeline generated / total spend." Should it be (a) closed-won ARR / total spend, or (b) pipeline value created / total spend? These give very different numbers | Aligns with how Rachel presents to board |

---

### Part 4: Wrap-Up and Decisions Log (15 minutes)

- **Review decisions made** during the session
- **Assign owners** for open items not resolved today
- **Confirm timeline**: Sprints 5–6 (Weeks 8–11), UAT Weeks 15–16
- **Action items**:
  - Niamh Collins: Provide form-to-asset mapping by [DATE]
  - Owen Brady: Confirm LinkedIn Ads API granularity by [DATE]
  - Rachel Summers: Confirm U-shaped lead conversion event definition by [DATE]
  - Sophie Tanner: Update requirements spec with all confirmed decisions

---

## Post-Workshop Follow-Up

- Sophie Tanner to send decision log within 24 hours
- Niamh Collins to share form-to-asset mapping document
- All confirmed decisions to be reflected in updated requirements_specification.md before Sprint 5 kickoff
