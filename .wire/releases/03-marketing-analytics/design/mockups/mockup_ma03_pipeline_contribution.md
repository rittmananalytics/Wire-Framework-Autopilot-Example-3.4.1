# Mockup: MA-03 — Pipeline Contribution Report
## Release: 03-marketing-analytics

**Purpose**: Monthly executive dashboard for board prep and sales/marketing alignment. Answers the question: "What is marketing's contribution to pipeline and revenue, and what is our return on marketing investment?"
**Audience**: Marcus Elwood (CEO), David Park (CRO), Rachel Summers (VP Marketing)
**Refresh**: Weekly
**Default**: Last 12 months

---

## Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║  MA-03: Pipeline Contribution Report                   [Last 12 months ▼] [Date]║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                  ║
║  ┌─────────────────────┐ ┌─────────────────────┐ ┌────────────────────────────┐ ║
║  │  MARKETING-SOURCED  │ │ MARKETING-INFLUENCED │ │  MARKETING ROI (Closed-Won)║ ║
║  │  PIPELINE (12mo)    │ │  PIPELINE (12mo)     │ │                            ║ ║
║  │                     │ │                      │ │  Pipeline / Spend:  4.8×   ║ ║
║  │      $6.2M          │ │       $9.4M          │ │  Closed-Won / Spend: 1.9×  ║ ║
║  │  48% of total       │ │  73% of total        │ │                            ║ ║
║  └─────────────────────┘ └─────────────────────┘ └────────────────────────────┘ ║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  MARKETING-SOURCED vs. SALES-SOURCED PIPELINE — Last 12 Months             │║
║  │  (Stacked bar chart, by month)                                              │║
║  │                                                                              │║
║  │  $1.4M ┤                                                                    │║
║  │  $1.2M ┤  ██████████ ████████████ ██████████                               │║
║  │  $1.0M ┤  ██████████ ████████████ ██████████                               │║
║  │  $0.8M ┤░░░░░░░░░░░ ░░░░░░░░░░░░ ░░░░░░░░░░                               │║
║  │  $0.6M ┤░░░░░░░░░░░ ░░░░░░░░░░░░ ░░░░░░░░░░                               │║
║  │     $0 └──────────────────────────────────                                 │║
║  │        Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec  Jan  Feb  Mar          │║
║  │        [█ Marketing-Sourced] [░ Sales-Sourced]                              │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌────────────────────────────────────────┐  ┌───────────────────────────────┐  ║
║  │  CAC BY QUARTER — Last 8 Quarters      │  │  MARKETING ROI BY QUARTER     │  ║
║  │  (Bar chart + trend line)              │  │  (Pipeline / spend ratio)      │  ║
║  │                                        │  │                                │  ║
║  │ $4000 ┤                      ●         │  │  6.0× ┤               ●        │  ║
║  │ $3500 ┤         ●   ●   ●   ╱          │  │  5.0× ┤   ●   ●   ●  ╱         │  ║
║  │ $3000 ┤  ●   ●  ╱   ─── ─── ────       │  │  4.0× ┤●  ╱   ─── ──────────  │  ║
║  │ $2500 ┤● ─── ───                       │  │  3.0× ┤  ─                     │  ║
║  │       └──────────────────────          │  │       └──────────────────────  │  ║
║  │        Q2  Q3  Q4  Q1  Q2  Q3  Q4  Q1  │  │       Q2 Q3 Q4 Q1 Q2 Q3 Q4 Q1 │  ║
║  │  [Note: CAC = Total Mktg Spend /        │  │  [■ Pipeline/Spend ratio]      │  ║
║  │   New Customers Acquired]               │  └───────────────────────────────┘  ║
║  └────────────────────────────────────────┘                                      ║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  MARKETING-INFLUENCED REVENUE — By Quarter                                 │║
║  │  (Contacts that had ≥1 marketing touch in 180 days before opportunity)     │║
║  │                                                                              │║
║  │  Quarter │ Total Closed-Won ARR │ Mktg-Influenced ARR │ Influence Rate      │║
║  │  ─────────────────────────────────────────────────────────────────────────  │║
║  │  Q2 2025 │      $1.08M          │       $0.82M         │    76%              │║
║  │  Q3 2025 │      $1.14M          │       $0.86M         │    75%              │║
║  │  Q4 2025 │      $0.96M          │       $0.68M         │    71%              │║
║  │  Q1 2026 │      $1.21M          │       $0.91M         │    75%              │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  LTV:CAC RATIO                                                              │║
║  │                                                                              │║
║  │  ⏳ Customer Lifetime Value data available in Customer Analytics release   │║
║  │     (scheduled Release 05 — Q3 2026)                                        │║
║  │                                                                              │║
║  │  Current quarter CAC: $3,840                                                │║
║  │  [LTV:CAC ratio will be calculated when LTV data is available]             │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Data Requirements

| Tile | Models | Key Measures | Key Dimensions |
|------|--------|-------------|---------------|
| Marketing-sourced pipeline KPI | fct_opportunity_attribution | pipeline_usd WHERE is_marketing_sourced = TRUE | (12-month rollup) |
| Marketing-influenced pipeline KPI | fct_opportunity_attribution | pipeline_usd WHERE is_marketing_influenced = TRUE | (12-month rollup) |
| Marketing ROI KPI | fct_opportunity_attribution, fct_campaign_spend | closed_won_arr / total_spend; pipeline / total_spend | (12-month rollup) |
| Sourced vs. sales-sourced stacked bar | fct_opportunity_attribution | pipeline by sourced/sales-sourced flag | month |
| CAC by quarter | fct_campaign_spend, stg_salesforce__opportunities | total_spend / new_customers | quarter |
| ROI by quarter | fct_campaign_spend, fct_opportunity_attribution | pipeline / spend | quarter |
| Marketing-influenced revenue table | fct_opportunity_attribution | closed_won_arr, influenced_arr, influence_rate | quarter |
| LTV:CAC placeholder | (static text) | CAC from fct_campaign_spend calc | quarter |

---

## Filters

| Filter | Field | Default |
|--------|-------|---------|
| Date range | opportunity_close_date | Last 12 months |
| Segment | dim_contact.segment | All |
| Channel | fct_opportunity_attribution.channel | All |

---

## Interactions

- **Stacked bar chart**: Click month to drill into individual campaigns contributing to that month's pipeline
- **CAC trend chart**: Tooltip shows constituent parts (spend, new customers acquired that quarter)
- **Marketing-influenced table**: Click quarter to see which campaigns drove influenced pipeline
- **LTV:CAC tile**: Permanent placeholder until Release 05 delivers LTV model; tooltip explains dependency
