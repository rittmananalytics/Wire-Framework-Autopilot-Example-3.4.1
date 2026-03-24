# Workshop Decision Matrix
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-24
**Version**: 1.0 (pre-workshop — decisions to be populated during/after workshop)

> **Autopilot Note**: Pre-resolved items are marked with a ✓ and their source. Open items are marked with ⚠ and require workshop confirmation. Autopilot has made default decisions for all open items — these defaults are used in artifact generation; workshop should confirm or override them.

---

## Decision Log

| ID | Topic | Options | **Autopilot Default** | Decision | Rationale | Owner | Resolved Date |
|----|-------|---------|----------------------|----------|-----------|-------|--------------|
| A1 | U-shaped: which event defines "lead conversion" | (a) MQL; (b) SAL; (c) First of the two; (d) Last of the two | **SAL** (handoff point, higher intent than MQL; requirement says "MQL/SAL" — SAL preferred per discovery) | ⚠ TBC | Rachel Summers indicated SAL is the handoff point | Rachel Summers | |
| A2 | U-shaped: 2-touch journey fallback | (a) Redistribute 50/50; (b) First-touch fallback; (c) Linear fallback | **Redistribute 50/50 to first and last** (preserves proportional intent) | ⚠ TBC | Simplest mathematically consistent approach | Sophie Tanner | |
| A3 | U-shaped: first touch = lead conversion touch | (a) 80% to single touch; (b) Fall back to first-touch | **80% to that single touch** (mathematically correct — 40+40 = 80%) | ⚠ TBC | Preserves model integrity | Sophie Tanner | |
| B1 | Time-decay half-life reference point | (a) From opp creation date backwards; (b) From first touch forwards | **From opportunity creation date backwards** (more credit to touches closer to close) | ✓ Assumed | Standard industry approach | Sophie Tanner | 2026-03-24 |
| B2 | 180-day boundary condition (day 180 itself) | (a) Include; (b) Exclude | **Include** (>= 0 days and <= 180 days) | ✓ Assumed | Less surprising to business users | Sophie Tanner | 2026-03-24 |
| C1 | Outreach SDR touches: marketing or sales? | (a) Marketing; (b) Sales; (c) Separate channel "sdr" | **Separate "sdr" channel** (distinct from paid/organic marketing; preserves attribution accuracy) | ⚠ TBC | SDR is distinct motion from marketing; Rachel Summers / Owen Brady to confirm | Rachel Summers | |
| C2 | Sales-sourced opp with later marketing touches = marketing-influenced? | (a) Yes; (b) No | **Yes** (definition says "at least one marketing touch in 180-day window") | ✓ Assumed | Matches FR-004 definition | Sophie Tanner | 2026-03-24 |
| D1 | SAL stage: HubSpot lifecycle or custom property? | (a) Lifecycle stage; (b) Custom property | **HubSpot lifecycle stage** (per requirements FR-001; Rachel Summers confirmed SAL is a lifecycle stage) | ✓ Assumed per discovery | Confirmed in Rachel Summers session | Niamh Collins | 2026-03-24 |
| D2 | HubSpot stage timestamps: native fields or audit log? | (a) Native fields; (b) Audit log reconstruction | **Native fields where available; audit log fallback** | ⚠ TBC | Niamh Collins to confirm HubSpot connector configuration | Niamh Collins | |
| D3 | Form-to-asset mapping format | (a) CSV; (b) HubSpot property; (c) Manual table | **CSV to be loaded as dbt seed** | ⚠ TBC | Niamh Collins to provide mapping document | Niamh Collins | |
| D4 | Email opens: include or exclude from attribution? | (a) Include; (b) Exclude; (c) Include but weight 0 | **Include but tag as low-confidence** (email_open tagged separately; Rachel Summers can filter in MA-02 Explore) | ⚠ TBC | Apple MPP inflates open rates post-iOS 15; business decision | Rachel Summers | |
| E1 | LinkedIn Ads granularity: campaign or ad group level? | (a) Ad group (creative) level; (b) Campaign level only | **Ad group level** (as specified in FR-002; assume API access available) | ⚠ TBC | Owen Brady to confirm Fivetran LinkedIn connector access level | Owen Brady | |
| E2 | Meta Ads ad set naming convention | (a) Structured naming; (b) Freeform | **Map ad set to campaign_type via classification rules** (regex-based rules on ad set name) | ⚠ TBC | Owen Brady to provide example ad set names | Owen Brady | |
| E3 | Ad platform historical data availability (24 months?) | (a) 24+ months available; (b) Less than 24 months | **Assume 24 months; document actual availability after initial sync** | ✓ Assumed | Fivetran historical sync typically provides full available history | Kofi Asante | 2026-03-24 |
| F1 | Outreach calls: all calls or SDR-only? | (a) All calls; (b) SDR-initiated only | **All calls logged in Outreach** (Outreach is the SDR tool; all activity should be captured) | ✓ Assumed | Standard Outreach usage | Kofi Asante | 2026-03-24 |
| F2 | Outreach-HubSpot contact identifier | (a) Email; (b) HubSpot contact ID; (c) Custom field | **Email as join key** (fuzzy match fallback for non-matching emails per 12% mismatch handling) | ✓ Assumed | Consistent with FR-003 deduplication approach | Sophie Tanner | 2026-03-24 |
| G1 | Majority pipeline stage: current or last-touch? | (a) Current stage of opp; (b) Stage at last campaign touch | **Current stage of opportunity** (simpler; reflects live pipeline health) | ✓ Assumed | Simpler and more useful for campaign performance review | Sophie Tanner | 2026-03-24 |
| G2 | Cost per MQL/SQL: blended rate or campaign-specific? | (a) Channel blended rate; (b) Campaign-specific | **Channel blended rate** (consistent with MA-01 being a channel performance view) | ✓ Assumed | MA-02 Explore is the place for campaign-specific drilldown | Sophie Tanner | 2026-03-24 |
| G3 | Period-over-period tile metrics | (a) Leads, MQLs, spend, pipeline only; (b) Add SALs, SQLs, opps | **Leads, MQLs, SALs, SQLs, spend, pipeline** (include all funnel stages for completeness) | ⚠ TBC | Rachel Summers / Owen Brady to confirm what they want in standup tile | Rachel Summers | |
| H1 | Content asset influence: count vs. attributed revenue | (a) Count of journeys; (b) Sum of attributed revenue | **Count of journeys** (primary; attributed revenue as secondary column) | ✓ Assumed | Both available in MA-02 Explore; journey count is more intuitive for content team | Sophie Tanner | 2026-03-24 |
| H2 | Funnel velocity "channel" definition | (a) Channel of first touch; (b) Dominant channel in journey | **Channel of first touch** (simpler; clearer attribution anchor) | ✓ Assumed | Dominant channel is ambiguous and harder to explain | Sophie Tanner | 2026-03-24 |
| H3 | Attribution share trend: percentage or absolute? | (a) Percentage share; (b) Absolute revenue | **Percentage share** (more useful for trend analysis; removes seasonality distortion) | ✓ Assumed | Board presentation standard | Sophie Tanner | 2026-03-24 |
| I1 | LTV:CAC ratio tile: placeholder or omit? | (a) Placeholder message; (b) Omit tile | **Placeholder tile with message** ("LTV data available in Customer Analytics release — scheduled Release 05") | ✓ Assumed | Better UX to show context than silent omission; sets expectation | Sophie Tanner | 2026-03-24 |
| I2 | Marketing ROI ratio definition | (a) Closed-won ARR / total spend; (b) Pipeline value / total spend | **Show both**: closed-won ARR / spend AND pipeline / spend as separate rows in MA-03 | ✓ Assumed | Both are valid and commonly requested by Rachel Summers and David Park | Sophie Tanner | 2026-03-24 |

---

## Items Requiring Client Confirmation Before Sprint 5

| ID | Owner | Required By | Blocking Artifact |
|----|-------|------------|------------------|
| A1 | Rachel Summers | Start of Sprint 5 | fct_opportunity_attribution (FR-004), MA-02 |
| A2 | Sophie Tanner (confirm with Rachel) | Start of Sprint 5 | fct_opportunity_attribution |
| A3 | Sophie Tanner (confirm with Rachel) | Start of Sprint 5 | fct_opportunity_attribution |
| C1 | Rachel Summers / Owen Brady | Start of Sprint 5 | fct_attribution_touches, fct_opportunity_attribution |
| D2 | Niamh Collins | Week 7 (before staging build) | fct_lead_funnel_events (FR-001) |
| D3 | Niamh Collins | Week 7 | fct_attribution_touches (FR-003) — asset_category field |
| D4 | Rachel Summers | Week 8 | fct_attribution_touches |
| E1 | Owen Brady | Week 7 (before Fivetran config) | fct_campaign_spend (FR-002) |
| E2 | Owen Brady | Week 7 | dim_campaign (FR-005) |
| G3 | Rachel Summers | Start of Sprint 6 | MA-01 dashboard build |

---

## Pre-Resolved Items (No Workshop Required)

These items were resolved in discovery sessions or requirements documents:

| Item | Resolution | Source |
|------|-----------|--------|
| U-shaped attribution as default | U-shaped is default in MA-02 Explore | Rachel Summers discovery session |
| 180-day influence window | 180 days (not 90 days) | Rachel Summers confirmed; kickoff call |
| SAL stage included in funnel | SAL between MQL and SQL | Rachel Summers discovery session |
| UTM gap: tag as "unattributed" | Do not drop; tag as unattributed channel | Requirements FR-003; NFR-005 |
| 12% HubSpot-Salesforce mismatch | Fuzzy match: email hash + company domain fallback | Kofi Asante; requirements FR-003 |
| Plain-text email in warehouse | SHA-256 hash only; never plain text | PII requirements; NFR-004; FR-006 |
| MA-02 as self-service Explore | Open Looker Explore, not locked dashboard | Rachel Summers discovery session |
| MA-01 majority_pipeline_stage | Mode calculation on Salesforce opportunity stages | FR-007 specification |
| Time-decay half-life | 30-day half-life | FR-004 specification |
| Email as pseudonymised hash | SHA-256 of email; no plain text | FR-006; NFR-004 |
