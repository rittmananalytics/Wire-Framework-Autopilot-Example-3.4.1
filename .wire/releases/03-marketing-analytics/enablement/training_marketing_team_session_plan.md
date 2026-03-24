# Training Session Plan — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Session type**: Marketing team end-user training
**Duration**: 90 minutes
**Audience**: Rachel Summers, Owen Brady, Niamh Collins
**Secondary**: Greg Fontaine (VP Sales — MA-03 section only, 20 minutes)
**Delivered by**: Sophie Tanner, Rittman Analytics
**Format**: Video call with screen share (Looker live demo)
**Scheduled**: Week 16 (after UAT sign-off)

---

## Learning Objectives

By the end of this session, participants will be able to:
1. Navigate MA-01 Demand Generation Performance dashboard for Monday standup
2. Understand what each attribution model represents and when to use it
3. Use MA-02 Multi-Touch Attribution Explore independently for budget reviews
4. Read and interpret MA-03 Pipeline Contribution for board prep
5. Understand the UTM coverage gap and what to do about it
6. Know how to ask for help and request report changes

---

## Agenda

### Part 1: Introduction and Context (10 minutes)

- What has been built and why
- Key business questions each dashboard answers
- Data sources: HubSpot, Salesforce, Google Ads, LinkedIn Ads, Meta Ads, Outreach
- Known data gaps: UTM coverage (~30%) and HubSpot-Salesforce match rate (~88%)
- How to interpret "unattributed" channel

---

### Part 2: MA-01 Demand Generation Performance (25 minutes)

**Facilitator**: Open MA-01 in Looker; walk through live

**Section A: Understanding the Dashboard (10 min)**
- Default view: last 7 days (set for Monday standup at 8am)
- KPI tiles: leads, MQLs, SALs, SQLs, spend — what they measure and where data comes from
- Period-over-period arrows: how % change is calculated (this 7 days vs. prior 7 days)
- Funnel volume bar chart: 13-week view to spot trends

**Section B: Cost Efficiency (10 min)**
- Cost per MQL and Cost per SQL by channel: how to read
- What a "good" cost per SQL looks like (to discuss with Owen Brady)
- Top 10 campaigns table: using majority_pipeline_stage to prioritise
- Spend by channel: this month vs. last month comparison

**Section C: Data Coverage and Limitations (5 min)**
- UTM coverage tile: what "29% unattributed" means
- Why UTM gaps exist and Niamh Collins' forward-looking UTM enforcement plan
- How to interpret campaign tables when UTM data is missing

**Hands-on exercise**: Owen Brady adjusts date range to last 30 days and identifies the top 3 campaigns by pipeline generated

---

### Part 3: MA-02 Multi-Touch Attribution (30 minutes)

**Facilitator**: Open the marketing_attribution Explore with U-shaped model

**Section A: Understanding Attribution Models (15 min)**
- Why last-touch (HubSpot default) understates LinkedIn's contribution
- The 5 attribution models: first-touch, last-touch, linear, time-decay, U-shaped
- Walk through the same opportunity under each model: "Here's a real deal — see how each model allocates credit"
- Why U-shaped is the recommended default for Core Dynamics
- The 180-day influence window: why it matters for enterprise sales cycles

**Live demo**: Pull up a real closed-won opportunity; show the touch journey; walk through how each model would allocate credit

**Section B: Using the Self-Service Explore (15 min)**
- The 5 saved starter views (overview, model comparison, content asset, velocity, trend)
- Switching attribution models using the dropdown filter
- How to add dimensions and measures to customise a view
- Saving a modified Explore view for future use
- How to export to CSV or Google Sheets for board deck preparation

**Hands-on exercise**: Owen Brady opens the "Model Comparison" saved view and identifies which channel looks most different between last-touch and U-shaped. Rachel Summers uses the attribution share trend view to check Q4 2025 vs. Q1 2026.

---

### Part 4: MA-03 Pipeline Contribution (20 minutes)

**Audience for this section**: Rachel Summers, Greg Fontaine (Sales), David Park (CRO — if available)

**Section A: Reading the Executive Dashboard (10 min)**
- Marketing-sourced vs. sales-sourced pipeline: the definitions and why the distinction matters
- Marketing-influenced revenue: "touched at any point in 180-day window"
- CAC by quarter: how it's calculated (total marketing spend / new customers acquired)
- Marketing ROI: pipeline / spend ratio interpretation

**Section B: Board Prep Usage (10 min)**
- How to use MA-03 to answer: "What is marketing's ROI this quarter?"
- Exporting specific tiles for board slides
- LTV:CAC placeholder: when it will be available (Release 05, Q3 2026)
- Weekly refresh cadence: data is weekly, not daily

**Hands-on exercise**: Rachel Summers exports the sourced vs. influenced pipeline chart for last quarter as an image for use in a board slide

---

### Part 5: Getting Help and Change Requests (5 minutes)

- How to report a data issue (Slack #data-platform-alerts)
- How to request a new view or metric (Jira WAEP project — tag 'enhancement')
- What NOT to change: dbt var changes for attribution weights require a developer
- Next planned release that affects marketing: Release 05 (LTV data for LTV:CAC)
- Contact: Sophie Tanner (sophie@rittmananalytics.com)

---

## Post-Session Actions

| Action | Owner | Deadline |
|--------|-------|---------|
| Share Looker quick reference card | Sophie Tanner | Same day |
| Update form_asset_mapping seed with real form IDs | Niamh Collins | Within 2 weeks |
| Set MA-01 as Monday standup start page in Looker | Owen Brady | Within 1 week |
| Confirm attribution model to use for Q1 board deck | Rachel Summers | Before next board prep cycle |

---

## Materials

- `training_marketing_team_slides.md` — Marp slides for presentation
- `training_marketing_team_quick_reference.md` — One-page reference card
- `training_marketing_team_exercises.md` — Exercise scenarios with answers
