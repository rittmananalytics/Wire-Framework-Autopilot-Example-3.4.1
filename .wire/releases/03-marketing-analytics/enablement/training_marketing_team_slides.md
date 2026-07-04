---
marp: true
theme: default
paginate: true
header: 'Core Dynamics — Marketing Analytics Training'
footer: 'Rittman Analytics | Confidential'
---

# Marketing Analytics
## Core Dynamics Data Platform

**Training Session**
Sophie Tanner, Rittman Analytics
Week 16

---

## What We've Built

Three dashboards that answer three key questions:

| Dashboard | Key Question |
|-----------|-------------|
| **MA-01** Demand Gen Performance | Is our demand generation working this week? |
| **MA-02** Multi-Touch Attribution | Which channels actually drive pipeline? |
| **MA-03** Pipeline Contribution | What is marketing's ROI this quarter? |

---

## Data Sources

```
HubSpot     → Contacts, MQLs, SALs, SQLs, form fills
Salesforce  → Opportunities, accounts, pipeline stages
Google Ads  → Campaign spend, impressions, clicks
LinkedIn    → Campaign spend, engagement
Meta Ads    → Campaign spend, conversion events
Outreach    → SDR sequences, email opens, meetings booked
```

**Known gaps to be aware of:**
- ~30% of marketing touches are unattributed (missing UTM tags)
- HubSpot-Salesforce contact match rate: ~88%

---

## MA-01: Demand Generation Performance

**Use this dashboard for**: Monday standup, weekly tracking

**Default filter**: Last 7 days (refreshed daily by 7am UTC)

---

## MA-01: Key Metrics

| Metric | Meaning |
|--------|---------|
| **Leads** | Contacts that reached "Lead" stage in HubSpot |
| **MQLs** | Leads meeting the lead score threshold |
| **SALs** | Leads accepted by an SDR |
| **SQLs** | Leads qualified by SDR, passed to AE |
| **Spend** | Google Ads + LinkedIn + Meta combined |
| **Cost per SQL** | Channel spend ÷ SQLs from that channel |

---

## MA-01: The Funnel View

```
Leads
  ↓
MQLs  (lead score threshold met)
  ↓
SALs  (SDR accepts the lead)
  ↓
SQLs  (SDR qualifies, passes to AE)
  ↓
Opportunities (Salesforce)
```

The **13-week bar chart** shows this funnel volume over time — spot trends early.

---

## MA-01: Majority Pipeline Stage

The **Top 10 Campaigns** table includes a column: **Majority Pipeline Stage**

This shows the Salesforce stage where most of a campaign's leads currently sit.

- **"Proposal Sent"** → strong signal: leads are converting
- **"MQL / SAL"** → leads are early — pipeline impact coming later
- Use this to prioritise which campaigns to review in detail

---

## MA-01: UTM Coverage Tile

You will see a tile showing something like: **"71% attributed"**

This means:
- 71% of marketing touches have UTM parameters → we know which channel/campaign
- 29% of touches are **unattributed** — we know they happened, but not from which campaign
- Unattributed touches are shown as `channel = 'unattributed'`
- **Niamh Collins is implementing UTM enforcement** to improve this

---

## MA-02: Multi-Touch Attribution

**Use this dashboard for**: Monthly budget reviews, board prep

**Default**: U-shaped model, last 12 months

---

## Why Last-Touch Alone Is Misleading

**Example: a typical enterprise deal**

```
Day 1:    LinkedIn ad → whitepaper download     [first touch]
Day 14:   Google ad → product page visit
Day 30:   LinkedIn ad → webinar registration
Day 45:   Outreach email → demo booked          [last touch]
Day 60:   Opportunity created
```

**Last-touch gives 100% credit to Outreach.**

LinkedIn generated the lead in the first place — but gets 0%.

---

## The 5 Attribution Models

| Model | How Credit Is Allocated |
|-------|------------------------|
| **First Touch** | 100% to the first marketing touch |
| **Last Touch** | 100% to the touch before opportunity creation |
| **Linear** | Equal share to every touch |
| **Time Decay** | More weight to recent touches (30-day half-life) |
| **U-Shaped** ⭐ | 40% first + 40% SAL conversion + 20% middle |

---

## Why U-Shaped is Our Default

For Core Dynamics' enterprise sales cycle:

- **First touch matters** — where did this person first hear about us?
- **The conversion event matters** — what made them raise their hand?
- **Middle touches matter less** — nurture is important but harder to single out

U-shaped gives credit to both the channel that acquired the lead **and** the event that converted them.

---

## The 180-Day Influence Window

Only touches within **180 days before opportunity creation** count.

- Confirmed with Rachel Summers (vs. HubSpot default of 90 days)
- Reflects Core Dynamics' ~4-month average enterprise sales cycle
- A touch from 2 years ago is unlikely to have influenced this deal

---

## MA-02: Self-Service Explore

Five saved views to start from:

| View | Use Case |
|------|----------|
| **Overview** | Channel attribution share — U-shaped default |
| **Model Comparison** | Side-by-side: all 5 models for each channel |
| **Content Asset Analysis** | Which assets appear in winning deals? |
| **Velocity Analysis** | Time from first touch to opportunity by channel |
| **Attribution Share Trend** | Channel mix change over time |

---

## MA-03: Pipeline Contribution

**Use this dashboard for**: Board prep, exec reporting, CAC tracking

**Default**: Last 12 months (weekly refresh)

---

## Sourced vs. Influenced

| Term | Meaning |
|------|---------|
| **Marketing-Sourced** | First touch ever was a marketing touch — marketing generated the lead |
| **Marketing-Influenced** | At least one marketing touch in 180 days before opportunity |
| **Sales-Sourced** | First touch was SDR outreach — no prior marketing touch |

**Important**: Marketing-Influenced is always ≥ Marketing-Sourced

---

## CAC and ROI in MA-03

**Customer Acquisition Cost (CAC)**
= Total marketing spend ÷ new customers acquired
*(quarterly view going back 8 quarters)*

**Marketing ROI**
= Pipeline generated ÷ marketing spend
*(ratio: >3x is generally considered strong for B2B SaaS)*

**LTV:CAC** — coming in Release 05 (Customer Analytics, Q3 2026)

---

## Getting Help

| Need | Contact | How |
|------|---------|-----|
| Data looks wrong | Sophie Tanner | Slack #data-platform-alerts |
| New metric request | Owen Brady → Sophie Tanner | Jira WAEP, label 'enhancement' |
| UTM issue | Niamh Collins | Slack DM |
| Dashboard access | Sophie Tanner | Slack DM |

**Do NOT change**: Attribution weights or window are dbt variables — requires a developer.

---

## What's Next

- Release 05 (Q3 2026): Customer Analytics — LTV, churn prediction, NRR tracking
- UTM coverage improvement (Niamh Collins — target: >90% by end of Q2)
- Attribution model confirmation for Q1 board deck (Rachel Summers)

---

## Questions?

**Training materials** (shared after session):
- `training_marketing_team_quick_reference.md` — one-page reference card
- `training_marketing_team_exercises.md` — hands-on exercise scenarios
- Looker saved views: pre-configured for common use cases

**sophie@rittmananalytics.com** | Slack #data-platform-alerts
