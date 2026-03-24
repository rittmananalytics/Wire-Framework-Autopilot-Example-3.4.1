# Requirements Specification
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Release**: 03-marketing-analytics
**Type**: full_platform
**Prepared by**: Wire Autopilot (Sophie Tanner, Rittman Analytics)
**Date**: 2026-03-24
**Version**: 1.0
**Dependency**: 02-data-foundation (staging models for Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads, Outreach must be complete)

---

## 1. Executive Summary

This document specifies the requirements for the Marketing Analytics workstream of the Core Dynamics Data Platform Modernisation engagement. This release delivers multi-touch marketing attribution, campaign ROI analysis, and full-funnel visibility from first touch to closed-won revenue — serving Rachel Summers (VP Marketing), Owen Brady (Demand Gen Manager), and Niamh Collins (Marketing Ops Manager).

Core Dynamics currently spends $2.1M annually on demand generation with no reliable view of which channels or campaigns generate pipeline and closed-won revenue. HubSpot's last-touch attribution makes LinkedIn's contribution invisible and drives marketing budget decisions based on MQL volume rather than pipeline quality. This release corrects that by delivering five attribution models simultaneously, allowing the marketing team to understand revenue impact under different assumptions and make data-driven budget allocation decisions.

This release corresponds to Phase 2 (Weeks 7–8) and Phase 3 (Weeks 15–16) of the SOW, covering deliverables D-07, D-08, D-09, and the marketing contribution to D-04 and D-21.

---

## 2. Business Context

**Client**: Core Dynamics, Inc. — $38.4M ARR, 312 enterprise accounts, B2B SaaS.
**Problem**: $2.1M demand gen spend attributed through last-touch HubSpot model only. LinkedIn, content assets, and SDR touches are invisible. Marketing cannot prove pipeline impact, making budget decisions political.
**Strategic Goal**: Improve NRR from 104% to 115%. This requires understanding which demand gen activities produce high-quality pipeline, not just MQLs.

**Key insights from discovery (Rachel Summers, Owen Brady, Niamh Collins):**
- Owen Brady cannot justify the LinkedIn budget because multi-touch attribution is invisible
- MQL volume is a misleading metric; cost-per-SQL and cost-per-closed-won are what matters
- U-shaped attribution is the preferred default model (first touch + lead conversion weighted most)
- Marketing influence window should be 180 days (not 90 days) — average enterprise sales cycle ~4 months
- HubSpot funnel stages include SAL (Sales Accepted Lead) between MQL and SQL
- ~12% of HubSpot contacts don't match Salesforce contacts (deduplication issue — fuzzy match at staging)
- ~30% of campaigns have non-standard or missing UTMs (documented gap; forward-looking enforcement in progress)

---

## 3. Stakeholders

| Name | Role | Department | Involvement |
|------|------|-----------|-------------|
| Rachel Summers | VP Marketing | Marketing | Primary — dashboards MA-01, MA-02, MA-03; UAT approver |
| Owen Brady | Demand Gen Manager | Marketing | Primary — campaign performance and attribution; UAT |
| Niamh Collins | Marketing Ops Manager | Marketing | Primary — HubSpot data quality; UTM enforcement; UAT |
| David Park | CRO | Revenue | Secondary — MA-03 audience; pipeline/CAC reporting |
| Marcus Elwood | CEO | Executive | MA-03 audience — executive pipeline reporting |
| Greg Fontaine | VP Sales | Sales | Secondary — marketing-sourced vs. sales-sourced pipeline |
| Sophie Tanner | Senior Analytics Engineer | Rittman Analytics | Builder |
| Kofi Asante | Data Engineer | Rittman Analytics | Pipeline validation |

---

## 4. Functional Requirements

### FR-001: Lead Funnel Events Model
**Description**: Build `fct_lead_funnel_events` — one row per lead per funnel stage transition, with timestamps.
**Funnel stages (Core Dynamics-specific)**:
1. Subscriber (HubSpot lifecycle stage)
2. Lead (HubSpot lifecycle stage)
3. MQL — Marketing Qualified Lead (HubSpot lifecycle stage)
4. SAL — Sales Accepted Lead (HubSpot lifecycle stage, handoff point to SDR review)
5. SQL — Sales Qualified Lead (HubSpot lifecycle stage, SDR accepted)
6. Opportunity (Salesforce created)
7. Qualification → Discovery → Demo → Proposal → Negotiation → Closed Won / Closed Lost (Salesforce stages)
**Key fields**: contact_pk, account_fk, stage_name, stage_entered_ts, stage_exited_ts, days_in_stage, is_converted, channel, campaign_id
**Acceptance Criteria**: SAL stage included; stage transition timestamps accurate; conversion events captured; funnel conversion rates calculable.

### FR-002: Campaign Spend Model
**Description**: Build `fct_campaign_spend` — daily spend by channel, campaign, ad group.
**Sources**: Google Ads, LinkedIn Ads, Meta Ads (from 02-data-foundation staging models).
**Key fields**: spend_date, channel, campaign_name, campaign_id, ad_group_name, impressions, clicks, spend_usd, ctr, cpc
**Acceptance Criteria**: All three ad platforms represented; spend aligned with platform-reported totals within ±1%; daily granularity.

### FR-003: Attribution Touches Model
**Description**: Build `fct_attribution_touches` — all marketing touches per contact, with touch type and channel.
**Source**: HubSpot page views, form submissions, email sends, meeting bookings; Outreach calls and email touches.
**Deduplication**: Apply fuzzy matching for ~12% of contacts without clean HubSpot-Salesforce contact match (SHA-256 email hash fallback + company domain fallback).
**UTM gap handling**: Touches without UTMs tagged as "unattributed" channel; not dropped from the dataset.
**Key fields**: contact_pk, touch_ts, touch_type (page_view, form_submit, email_open, email_click, outreach_email, outreach_call, ad_click), channel, campaign_id, asset_id, asset_category
**Acceptance Criteria**: All HubSpot engagement types represented; Outreach touches included; UTM-less touches tagged as "unattributed" not dropped; fuzzy match logic documented.

### FR-004: Opportunity Attribution Model
**Description**: Build `fct_opportunity_attribution` — opportunity value allocated across all touches under five attribution models.
**Models**:
1. **First-touch**: 100% credit to the first touch in the journey
2. **Last-touch**: 100% credit to the last touch before opportunity creation
3. **Linear**: Equal credit split across all touches
4. **Time-decay**: More credit to touches closer to opportunity creation (exponential decay, half-life = 30 days)
5. **U-shaped**: 40% to first touch, 40% to lead conversion (MQL/SAL), 20% split evenly across middle touches
**Influence window**: 180 days (confirmed with Rachel Summers)
**Sourced vs. influenced**:
- Marketing-sourced: marketing generated the initial lead (first touch is a marketing touch)
- Marketing-influenced: at least one marketing touch occurred in the 180 days prior to opportunity creation
**Key fields**: opportunity_pk, touch_pk, attribution_model, attributed_revenue_usd, attributed_pipeline_usd, is_marketing_sourced, is_marketing_influenced
**Acceptance Criteria**: All five models present; U-shaped model calculates correctly; 180-day influence window applied; sourced vs. influenced flags correct.

### FR-005: Campaign Dimension
**Description**: Build `dim_campaign` — campaign dimension with channel, type, target segment.
**Key fields**: campaign_pk, campaign_name, channel, campaign_type (paid_search, paid_social, content, events, sdr_sequence, webinar), target_segment, start_date, end_date, total_budget_usd, is_active
**Acceptance Criteria**: All campaigns from Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads included; no duplicates.

### FR-006: Contact Dimension with Clearbit Enrichment
**Description**: Build `dim_contact` — contacts with Clearbit firmographic enrichment attributes.
**Key fields**: contact_pk, account_fk, email_pseudonymised (hash — not plain text), first_name, last_name, hubspot_lifecycle_stage, salesforce_contact_id, clearbit_company_name, clearbit_industry, clearbit_employees_range, clearbit_country_code, is_mql, mql_date, is_sal, sal_date, is_sql, sql_date
**Note**: Email stored as SHA-256 hash only. Plain-text email NOT stored in warehouse.
**Acceptance Criteria**: Clearbit enrichment joined correctly; lifecycle stage flags accurate; no plain-text PII.

### FR-007: Dashboard MA-01 — Demand Generation Performance
**Description**: Weekly operational dashboard for marketing team's Monday standup.
**Default date range**: Last 7 days (with period-over-period comparison vs. prior 7 days).
**Refresh**: Daily.
**Audience**: Rachel Summers, Owen Brady, Niamh Collins.
**Required tiles**:
- Leads, MQLs, SALs, SQLs, Opportunities by week (bar chart, last 13 weeks)
- Conversion rates at each funnel stage (funnel chart: MQL→SAL, SAL→SQL, SQL→Opp, Opp→Closed-Won)
- Spend by channel this month vs. last month (bar chart)
- Cost per MQL and Cost per SQL by channel (table with sparklines)
- Top 10 campaigns by pipeline generated (table; columns: campaign, channel, spend, pipeline_generated, cost_per_sql, **majority_pipeline_stage**)
- Period-over-period comparison tile (% change vs. prior 7 days for leads, MQLs, spend, pipeline)
**Note**: "Majority pipeline stage" column = the Salesforce stage at which the plurality of leads from that campaign currently sit (mode calculation).
**Acceptance Criteria**: Loads within 5 seconds; last 7 days as default; UAT sign-off from Rachel Summers.

### FR-008: Dashboard MA-02 — Multi-Touch Attribution Analysis (Self-Service Explore)
**Description**: Strategic self-service exploration tool for monthly budget review and board prep.
**Design**: Open Looker Explore with saved "starter views", NOT a locked-down dashboard.
**Attribution model selector**: Dropdown filter to switch between all 5 models (U-shaped as default).
**Refresh**: Daily.
**Audience**: Rachel Summers, Owen Brady.
**Required tiles/views**:
- Revenue attributed by channel under selected model (bar chart)
- Average touches before close by segment (Enterprise, Mid-Market, SMB)
- Content asset influence analysis (which assets appear most frequently in closed-won journeys vs. lost journeys)
- Funnel velocity: average days per stage by channel
- Model comparison view: side-by-side channel revenue under all 5 models
- Attribution share trend over time (area chart, last 12 months)
**Acceptance Criteria**: All 5 attribution models functional; U-shaped default; 180-day influence window applied; UAT sign-off from Rachel Summers.

### FR-009: Dashboard MA-03 — Pipeline Contribution Report (Monthly Executive)
**Description**: Monthly executive dashboard for board prep and sales/marketing alignment.
**Refresh**: Weekly.
**Audience**: Marcus Elwood (CEO), David Park (CRO), Rachel Summers.
**Required tiles**:
- Marketing-sourced vs. sales-sourced pipeline by month (stacked bar chart, last 12 months)
- Marketing-influenced revenue (touched at any point in the 180-day window)
- CAC by quarter with trend line (last 8 quarters)
- Marketing ROI ratio (pipeline generated / total spend) by quarter
- LTV:CAC ratio (requires LTV from customer analytics — may be placeholder until Release 05)
**Acceptance Criteria**: Loads within 5 seconds; sourced vs. influenced distinction correct; UAT sign-off from Rachel Summers.

---

## 5. Non-Functional Requirements

### NFR-001: Dashboard Performance
All three dashboards must load within 5 seconds for the default date range (last 7 days / last 90 days) in production Looker.

### NFR-002: Attribution Model Accuracy
All five attribution models must produce internally consistent results: total attributed revenue across all models equals total closed-won ARR for the same period.

### NFR-003: Data Freshness
Dashboards refresh daily. Marketing attribution is acceptable at T+1 (daily); Demand Generation dashboard is most time-sensitive (daily refresh by 7am UTC before Monday standup).

### NFR-004: PII Handling
No plain-text contact emails in any warehouse model or Looker view. Contact dimension stores pseudonymised email hash only.

### NFR-005: UTM Gap Documentation
The ~30% campaign UTM gap must be documented in the dashboard via a "data coverage" tile or tooltip, so users understand attribution coverage limitations without interpreting the absence of data as zero contribution.

---

## 6. Data Requirements

| Source | Staging Models Required | Key Objects | Notes |
|--------|------------------------|-------------|-------|
| Salesforce | stg_salesforce__accounts, stg_salesforce__contacts, stg_salesforce__opportunities, stg_salesforce__campaigns | Accounts, Contacts, Opportunities (incl. ARR), Campaigns | Stage history required for funnel analysis |
| HubSpot | stg_hubspot__contacts, stg_hubspot__form_submissions, stg_hubspot__email_sends, stg_hubspot__page_views | Contacts, Engagements, Lifecycle stages | 12% contact mismatch with Salesforce — fuzzy match |
| Google Ads | stg_google_ads__campaigns, stg_google_ads__ad_groups | Campaigns, ad groups, spend, impressions, clicks | Daily full refresh |
| LinkedIn Ads | stg_linkedin_ads__campaigns, stg_linkedin_ads__creatives | Campaigns, spend, impressions, clicks | Daily full refresh |
| Meta Ads | stg_meta_ads__campaigns, stg_meta_ads__ad_sets | Campaigns, ad sets, spend, impressions, clicks | Daily full refresh |
| Outreach.io | stg_outreach__sequences, stg_outreach__mailings, stg_outreach__calls | SDR sequences, email/call touches | For attribution touch model |
| Clearbit | raw_hubspot.clearbit_enrichment | Firmographic enrichment for dim_contact | Cloud Function output |

---

## 7. Technical Requirements

- **Platform**: BigQuery (mart_marketing dataset)
- **Transformation**: Dataform (staging models from 02-data-foundation; new intermediate and warehouse models in this release)
- **Semantic Layer**: Looker LookML (marketing.model.lkml, new views in views/marketing/)
- **Dependency**: All staging models from 02-data-foundation must be deployed and passing assertions before this release build begins

---

## 8. Deliverables

| ID | Deliverable | Acceptance Criteria |
|----|-------------|---------------------|
| D-07 | Marketing warehouse models (6 models) | All tests pass; row counts within ±1% of source; NRR definitions agreed |
| D-08 | Dashboard MA-01: Demand Generation Performance | Loads ≤5s; default last 7 days; majority_pipeline_stage column; UAT from Rachel Summers |
| D-09 | Dashboard MA-02: Multi-Touch Attribution Analysis | All 5 models functional; U-shaped default; 180-day window; self-service Explore |
| D-10 | Dashboard MA-03: Pipeline Contribution Report | Sourced vs. influenced; CAC trend; marketing ROI; UAT from Rachel Summers |
| D-11 | LookML marketing views and explores | All views pass Looker content validation; explores functional |

---

## 9. Timeline

| Sprint | Weeks | Activities |
|--------|-------|-----------|
| Sprint 5 | 8–9 | Marketing warehouse models, intermediate models, LookML views |
| Sprint 6 | 10–11 | Marketing dashboards MA-01, MA-02, MA-03; UAT |
| UAT | Week 15–16 | UAT sessions with Rachel Summers + Owen Brady; sign-off |

---

## 10. Assumptions and Dependencies

- All 02-data-foundation staging models for Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads, Outreach are deployed and passing data quality assertions
- Leon Yip has confirmed the 180-day attribution window (vs. 90-day in original SOW)
- Niamh Collins has provided form-to-asset mapping document (maps HubSpot form IDs to asset names and categories)
- Rachel Summers has confirmed U-shaped attribution as the default model
- Fuzzy matching approach for 12% HubSpot-Salesforce contact mismatch agreed with Kofi Asante

---

## 11. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| 12% HubSpot-Salesforce contact mismatch | Attribution coverage gap | Fuzzy match at staging (email hash + company domain fallback); document coverage |
| ~30% campaigns with missing UTMs | Attribution blind spots | Tag as "unattributed"; surface coverage gap in dashboard |
| Retroactive ad platform data changes | Attribution shifts after initial load | Daily full refresh for ad platforms; note in data documentation |
| Salesforce stage history availability | Funnel analysis may have gaps for historical opps | Check Salesforce opportunity stage history; document if incomplete |

---

## 12. Scope Management

**In scope**: 6 warehouse models, 3 dashboards, LookML marketing semantic layer.
**Out of scope**: Predictive lead scoring; Salesforce/HubSpot configuration changes; retroactive UTM clean-up; real-time attribution; embedded analytics.
