# User Guide — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Version**: 1.0
**Date**: 2026-03-24
**Author**: Sophie Tanner, Rittman Analytics
**Audience**: Rachel Summers, Owen Brady, Niamh Collins, Greg Fontaine

---

## 1. Getting Started

### Accessing the Dashboards

All three Marketing Analytics dashboards are available in Looker. Your access level determines what you can see:

| Role | Dashboard Access | Explore Access |
|------|----------------|---------------|
| Rachel Summers (VP Marketing) | MA-01, MA-02, MA-03 | Yes (can run custom queries) |
| Owen Brady (Demand Gen) | MA-01, MA-02 | Yes (can run custom queries) |
| Niamh Collins (Marketing Ops) | MA-01 | No self-service Explore |
| Greg Fontaine (VP Sales) | MA-03 only | No |
| Marcus Elwood (CEO) | MA-03 | No |
| David Park (CRO) | MA-03 | No |

If you cannot access a dashboard you need, contact Sophie Tanner via Slack direct message.

### Dashboard Navigation

In Looker, find the three dashboards under **Dashboards** in the left sidebar, grouped under the **Marketing** folder:
- MA-01 Demand Gen Performance
- MA-02 Attribution Analysis *(saved views only — access via Explore for self-service)*
- MA-03 Pipeline Contribution

---

## 2. MA-01: Demand Generation Performance

**Best used for**: Monday standup, weekly demand gen tracking

### Opening the Dashboard

Navigate to **Dashboards → Marketing → MA-01 Demand Gen Performance**. The dashboard opens with the default date range of "Last 7 days" — designed for your Monday standup.

### What You See

**Top row — KPI tiles** (5 single-value tiles with period-over-period arrows):
- **Leads**: New contacts that reached the Lead lifecycle stage in HubSpot
- **MQLs**: Leads meeting the lead score threshold
- **SALs**: Leads accepted by an SDR (Core Dynamics-specific stage)
- **SQLs**: Leads qualified by the SDR and passed to an account executive
- **Total Spend**: Combined paid media spend (Google + LinkedIn + Meta)

The arrows show the change vs. the prior period. If you're on "Last 7 days", the comparison is the previous 7 days.

**Funnel Volume Chart** — 13-week bar chart showing lead → MQL → SAL → SQL volumes over time. Use this to spot seasonal trends or campaign-driven spikes.

**Cost Efficiency Charts** — Cost per MQL and Cost per SQL broken down by channel. Lower is better; use this to identify which channels are most efficient.

**Top 10 Campaigns Table** — The 10 campaigns generating the most pipeline in the selected period. Columns include:
- Campaign name and channel
- Leads, MQLs, SALs, SQLs generated
- Total spend for the campaign
- Cost per SQL (spend / SQLs from that campaign)
- **Majority Pipeline Stage** — the Salesforce stage where most of this campaign's leads currently sit

**Majority Pipeline Stage** explained: If a campaign shows "Proposal Sent", most of the leads it generated are currently at Proposal Sent in Salesforce — a strong signal. If it shows "MQL", leads are still early in the funnel.

**Spend by Channel** — This month vs. last month comparison. Use this for weekly spend pacing.

**UTM Coverage Tile** — Shows the percentage of marketing touches that have UTM parameters. A figure of ~70% is expected; ~30% of touches cannot be attributed to a specific campaign.

### Changing Date Ranges

Use the **Date Range** filter at the top of the dashboard to switch between:
- Last 7 days (default — Monday standup)
- Last 30 days (monthly review)
- This quarter / last quarter
- Custom date range

### Common Tasks

**Finding the top campaigns for a monthly review**:
1. Change date range to "Last 30 days"
2. Click the pipeline column header to sort by pipeline generated
3. Note the top 3–5 campaigns and their Majority Pipeline Stage

**Checking spend pacing**:
1. Look at the "Spend by Channel" tile
2. If this month's spend is significantly below last month, check for paused campaigns in the ad platforms

---

## 3. MA-02: Multi-Touch Attribution Analysis

**Best used for**: Monthly budget reviews, board preparation, channel ROI analysis

**Important**: MA-02 is a Looker Explore, not a standard dashboard. It requires Explore access (Rachel Summers and Owen Brady only).

### Using Saved Views

To avoid building queries from scratch, use the five pre-saved views:

| Saved View | What It Shows | Best For |
|-----------|--------------|----------|
| **Overview** | Attribution share by channel under U-shaped (default) | Quick channel contribution summary |
| **Model Comparison** | All 5 models side by side for each channel | Understanding how model choice affects results |
| **Content Asset Analysis** | Which content assets appear in winning vs. losing deal journeys | Content ROI and asset effectiveness |
| **Velocity Analysis** | Average time from first touch to opportunity, by channel | Identifying fast vs. slow conversion channels |
| **Attribution Share Trend** | Channel attribution share over time (monthly) | Tracking channel mix shifts quarter over quarter |

**To open a saved view**: In the MA-02 Explore, click the **Saved Views** dropdown at the top and select the view you want.

### Choosing an Attribution Model

The MA-02 Explore has an **Attribution Model** filter. By default it shows `u_shaped`.

To compare models:
1. Open the "Model Comparison" saved view — it shows all 5 models as columns automatically
2. Or use the filter to switch between models and compare channel shares

**Which model to use when**:
- **Board reporting**: U-shaped (recommended default for Core Dynamics)
- **Measuring brand awareness**: First-touch
- **Direct response campaigns**: Last-touch
- **Equal channel weighting**: Linear
- **Prioritising recent touches**: Time-decay

### Why LinkedIn Looks Different by Model

LinkedIn Ads tends to be a **first-touch channel** — it generates initial awareness and gets people into the funnel. The last SDR sequence or demo request tends to be the final touch before opportunity creation.

This means:
- **Last-touch** gives LinkedIn minimal credit (SDR gets most of it)
- **U-shaped** gives LinkedIn proper credit for first-touch acquisition AND conversion events
- **Difference in practice**: LinkedIn's attribution share can be 2× higher in U-shaped vs. last-touch

This is why we recommend **U-shaped for board reporting** — it better reflects LinkedIn's true contribution to pipeline.

### Exporting Data

To export attribution data for a board slide or Google Sheet:
1. Configure the Explore (or open a saved view)
2. Click the **gear icon** (⚙) in the top-right of the results
3. Select **Download** → **CSV** or **Google Sheets**

---

## 4. MA-03: Pipeline Contribution

**Best used for**: Board preparation, executive reporting, CAC tracking

### What You See

**Marketing-Sourced Pipeline** (KPI tile): The percentage of closed-won pipeline where the first marketing touch initiated the relationship — before any SDR outreach.

**Marketing-Influenced Pipeline** (KPI tile): The percentage of closed-won pipeline where at least one marketing touch occurred within 180 days before opportunity creation. This is always higher than Marketing-Sourced.

**Marketing-Sourced vs. Sales-Sourced** (stacked bar chart): 12-month history of pipeline split by source. Use this for the "marketing vs. sales attribution" conversation in board meetings.

**CAC by Quarter** (line chart): Customer Acquisition Cost — total marketing spend divided by new customers acquired, by quarter. Shows last 8 quarters (2 years).

**Marketing ROI** (KPI tile): Pipeline generated divided by marketing spend. A ratio of 3× or above is typically considered strong for B2B SaaS.

**LTV:CAC Placeholder**: Currently shows only the CAC component. Customer Lifetime Value data will be available when the Customer Analytics release (Release 05) is deployed in Q3 2026.

### Key Definitions

**Marketing-Sourced** = The *first ever touch* in a contact's journey was a marketing touch (e.g., LinkedIn ad, Google Ads, form fill), before any SDR outreach.

**Marketing-Influenced** = *At least one* marketing touch occurred in the 180 days before the opportunity was created. The contact may have been originally sourced by sales, but marketing was part of the journey.

**Sales-Sourced** = The first touch was an SDR outreach (e.g., cold email, LinkedIn InMail from a rep). There was no prior marketing touch.

### Using MA-03 for Board Prep

**To prepare the marketing ROI slide**:
1. Open MA-03 with default date range (Last 12 months)
2. Note the Marketing-Sourced %, Marketing-Influenced %, and Marketing ROI figures
3. Export the "Marketing-Sourced vs. Sales-Sourced" chart:
   - Hover over the chart tile; click the kebab menu (⋮) in the top-right corner
   - Select **Download** → **PNG**
4. Import the PNG into your board slide deck

**Note**: MA-03 refreshes weekly (on Monday). If you open it on Wednesday, data is current as of the previous Friday.

---

## 5. Frequently Asked Questions

**Q: Why does the LinkedIn number look so different depending on which attribution model I choose?**

LinkedIn is typically a first-touch channel — people discover Core Dynamics through LinkedIn ads early in the journey. The last touch before an opportunity is usually an SDR email or a demo. Last-touch gives 100% credit to that SDR email; U-shaped gives 40% to LinkedIn's initial touch. The U-shaped model is more accurate for channels like LinkedIn.

**Q: Why is some of my pipeline "unattributed"?**

About 30% of marketing touches lack UTM parameters. These touches happened (HubSpot recorded them), but we can't tell which specific campaign they came from. They're shown as `channel = 'unattributed'`. Niamh Collins is working to improve UTM compliance to reduce this gap.

**Q: Why doesn't my pipeline number match what I see in Salesforce?**

A small difference is expected. About 12% of HubSpot contacts don't have an exact match to a Salesforce contact (slight differences in email formatting, or contacts entered manually in one system). These contacts contribute to attribution but not directly to opportunity revenue. A difference up to ~15% is within the expected range; if you see a larger gap, contact Sophie Tanner.

**Q: When will the LTV:CAC ratio be available?**

LTV data requires Customer Lifetime Value tracking from ChurnZero and revenue data from NetSuite. This is in scope for Release 05 (Customer Analytics), currently scheduled for Q3 2026.

**Q: Can I change the attribution model weights or window?**

These are configurable but require a developer (Sophie Tanner) to make the change and redeploy. They are not adjustable from within Looker. If you want to test a different window or weight configuration, raise it in Jira WAEP with the 'enhancement' label, or contact Sophie directly.

**Q: Can I see an individual contact's full attribution journey?**

Not directly in the current dashboards. The MA-02 Explore shows attribution at the channel and campaign level. To see an individual contact's journey, contact Sophie Tanner — she can run a custom BigQuery query against `fct_attribution_touches` filtered by contact.

**Q: MA-03 shows a different pipeline number than what the board saw last quarter. Why?**

Two possible causes:
1. The board saw a different attribution model or date range
2. Salesforce opportunities have been retrospectively updated (stage changes, close date changes) — the dashboard reflects current Salesforce state, not the historical state

If you need to compare to a specific prior board presentation, let Sophie Tanner know the date and she can recreate the historical view.

---

## 6. Getting Help

| Need | Contact | Channel |
|------|---------|---------|
| Data appears incorrect | Sophie Tanner | Slack #data-platform-alerts |
| Dashboard is slow or not loading | Sophie Tanner | Slack #data-platform-alerts |
| Request a new metric or view | Owen Brady (triage) → Sophie Tanner | Jira WAEP, label 'enhancement' |
| UTM tagging issue | Niamh Collins | Slack direct message |
| Access to additional dashboards | Sophie Tanner | Slack direct message |
| Attribution window / weight change | Sophie Tanner | Email or Slack |

**Sophie Tanner**: sophie@rittmananalytics.com | Slack @sophie.tanner
