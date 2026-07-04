# Discovery Session Notes — Rachel Summers, VP Marketing

**Interview Type:** Workstream Discovery — Marketing Analytics
**Date:** Wednesday, 4 February 2026
**Duration:** 85 minutes
**Interviewer:** Sophie Tanner
**Note-taker:** Daniel Osei
**Interviewees:** Rachel Summers (VP Marketing), Owen Brady (Demand Gen Manager), Niamh Collins (Marketing Ops Manager)

---

## Current State

**Rachel:** Our current attribution situation is genuinely embarrassing given how much we spend on demand gen. We're running $2.1M a year across paid channels and the only attribution we have is HubSpot's last-touch model, which tells us the last thing a lead clicked before converting to an MQL. That means Google Ads gets credited for almost everything because most of our paid search campaigns are branded — people search "CoreFM" after seeing a LinkedIn ad or attending a webinar, click a Google ad, and Google gets 100% of the credit. LinkedIn's entire contribution to pipeline is essentially invisible.

**Owen:** The way I currently justify the LinkedIn budget is by pointing to anecdotal deal stories and the LinkedIn company page engagement metrics, which are meaningless for revenue attribution. I know LinkedIn is working — I've got CSMs telling me that prospects mention our LinkedIn content in discovery calls — but I can't prove it in a spreadsheet, which means it's always the first thing on the chopping block when marketing budgets get reviewed.

**Niamh:** The manual sync between HubSpot and Salesforce is also a big pain point. Every Monday morning I export contacts from HubSpot and opportunities from Salesforce and reconcile them. The main problem is that `Contact.Id` values sometimes don't match between the systems because of how leads get deduped on the Salesforce side. I'd say roughly 12% of contacts don't have a clean match, which means those journeys drop out of any attribution analysis entirely.

> **Note:** 12% unmatched contact rate is a significant data quality issue. Will need Kofi to assess the deduplication logic in the Salesforce-HubSpot sync and either fix it upstream or implement fuzzy matching at the staging layer.

---

## Attribution Model Requirements

**Q: When you say multi-touch attribution — what are the key questions you actually want to be able to answer?**

**Rachel:** The single most important question is: if I had $500K to reallocate between channels tomorrow, where should it go? That requires me to know the pipeline-to-spend ratio for each channel, not just the MQL volume. LinkedIn might generate fewer MQLs than Google but if the MQLs from LinkedIn are higher quality — higher ACV, faster sales cycle, better close rate — that should be reflected.

**Owen:** For me, the tactical question is campaign-level. Which campaigns are generating pipeline, not just form fills? Right now I optimise campaigns based on CPC and conversion rate to MQL. I want to optimise based on cost-per-SQL and cost-per-closed-won. That requires connecting the ad campaign data to the Salesforce opportunity all the way to closed-won, which I currently can't do.

**Sophie Tanner:** The data model in the SoW handles this via the `fct_opportunity_attribution` table — it allocates opportunity value back to every touch in the journey, so you can aggregate by campaign and get revenue-attributed pipeline and closed-won value per campaign. What I want to understand is whether the UTM parameter hygiene in your current setup is sufficient to make that connection.

**Niamh:** The UTM hygiene is... inconsistent. We have a UTM naming convention but it's not enforced. Owen and I built a UTM builder in Google Sheets that campaigns are supposed to use, but probably 30% of campaigns have non-standard UTMs or none at all. Particularly events and content syndication — those almost never have UTMs applied correctly.

**Sophie Tanner:** That's going to limit the coverage of the attribution model for those channels. We can still build the model with clean data for the well-tagged channels and mark the others as "direct or unattributed." But it's worth having a parallel initiative to improve UTM discipline going forward — that's not something we can fix retroactively in the data.

**Rachel:** Agreed. Niamh, let's make UTM audit and enforcement a Q1 initiative alongside this project. Can you put a proposal together?

**Niamh:** Will do.

---

## Funnel Definition & Stage Mapping

**Sophie Tanner:** I want to walk through the funnel stages and make sure we have the right definitions. In the SoW we have Lead → MQL → SQL → Opportunity → Closed-Won. Is that right, or does Core Dynamics use a different stage naming?

**Niamh:** Slightly different. In HubSpot we have: Subscriber → Lead → MQL → SAL (Sales Accepted Lead) → SQL → Opportunity. Then in Salesforce: Opportunity with stages — Qualification, Discovery, Demo, Proposal, Negotiation, Closed Won, Closed Lost.

**Sophie Tanner:** Good to know. So the handoff point between HubSpot and Salesforce is at the SAL stage?

**Niamh:** Technically SAL. When a lead reaches SAL status in HubSpot, an SDR reviews it and if they accept it, a Contact and Opportunity are created in Salesforce. The acceptance rate from SAL to SQL is about 65% currently.

> **Note:** Update SoW data model to include SAL stage. The `fct_lead_funnel_events` model needs to capture the HubSpot lifecycle stage transitions including SAL, not just MQL. Flag to Sophie for data model revision.

**Owen:** One thing I'd add — we have a concept of "Marketing-Sourced" vs. "Marketing-Influenced" opportunities. Marketing-Sourced means marketing generated the initial lead. Marketing-Influenced means marketing touched the deal at some point even if Sales sourced the original lead through outbound. The attribution model should track both.

**Sophie Tanner:** Yes, that's covered in MA-03 — the Pipeline Contribution Report distinguishes marketing-sourced vs. marketing-influenced. We calculate influenced as "any opportunity where at least one marketing touch occurred in the 90 days prior to opportunity creation." Is that the right window or should it be longer?

**Rachel:** 90 days might be too short. Our average sales cycle from first touch to opportunity is about 4 months for enterprise accounts. I'd suggest 180 days for the influenced attribution window.

> **Note:** Update attribution window assumption in data model to 180 days. Update SoW if required.

---

## Content Attribution Requirements

**Rachel:** One thing that isn't fully captured in the SoW but is really important to me — content asset attribution. We produce a lot of content: whitepapers, webinars, case studies, benchmark reports. I want to know which content assets are actually influencing deals. Not just which ones get downloaded — I already have that from HubSpot — but which ones appear in the paths of deals that close.

**Sophie Tanner:** That's captured in MA-02 — the "content asset influence analysis" panel. The way it works: every form submission or content download in HubSpot is treated as a marketing touch. If we can identify the asset associated with each touch, we can aggregate by asset and see how often each asset appears in closed-won journeys versus lost journeys. The challenge is whether the HubSpot form data is structured enough to identify the specific asset for each conversion.

**Niamh:** Most of our content gates use unique form IDs per asset, so we can map form ID to asset name. I can give you a form-to-asset mapping document.

**Sophie Tanner:** Perfect. Can you include the asset category too — whitepaper, webinar, case study, etc.? That lets us do category-level analysis as well as individual asset analysis.

**Niamh:** Yes, I'll build that out.

---

## Reporting Cadence & Audience

**Rachel:** The Demand Generation dashboard — I want that to be the thing my team looks at every Monday morning in our weekly standup. So it needs to show last week's numbers prominently, not just trailing 30-day. Can we make "last 7 days" the default date range with easy comparison to the prior period?

**Sophie Tanner:** Easily done. We'll set the default to last 7 days with a period-over-period comparison tile showing the percentage change vs. the prior 7 days.

**Owen:** For the campaign-level table — can we have a column that shows the stage the majority of leads from that campaign are currently sitting at? So I can see at a glance whether a campaign is generating a lot of leads that are stuck in MQL and not converting, versus leads that are flowing through to SQL.

> **Note:** Add "majority pipeline stage" derived metric to the campaign performance table in MA-01. May require a mode/percentile calculation in the data model.

**Rachel:** The attribution analysis dashboard — that one doesn't need to be a daily operational thing. That's more of a strategic tool that I'll use once a month for budget review conversations and board prep. Can it be designed more like an exploration tool than a KPI dashboard? I want to be able to slice it lots of different ways without it feeling like it's telling me one thing.

**Sophie Tanner:** Yes. MA-02 is intentionally designed as a self-service Explore in Looker, not a locked-down dashboard. You'll have full filter control over date range, channel, segment, attribution model, and content type. We'll provide a few saved "starter views" but the underlying exploration is open.

---

## Open Questions / Follow-ups

| Question | Owner | Due |
|---|---|---|
| UTM audit and enforcement proposal | Niamh Collins | End of Week 3 |
| HubSpot form-to-asset mapping document with asset categories | Niamh Collins | Before Phase 2 staging model build |
| Assess Salesforce-HubSpot contact deduplication logic; quantify 12% mismatch rate | Kofi Asante | Phase 2 start |
| Update `fct_lead_funnel_events` data model spec to include SAL stage | Sophie Tanner | Before Phase 2 model design review |
| Confirm attribution influenced window as 180 days (not 90 days as in SoW) | Sophie Tanner / Mark Rittman | SoW amendment if required |
