# Mockup: MA-02 — Multi-Touch Attribution Analysis
## Release: 03-marketing-analytics

**Purpose**: Strategic self-service Explore for monthly budget review and board prep. Shows how revenue and pipeline is attributed to channels under different attribution models, enabling data-driven budget allocation decisions.
**Audience**: Rachel Summers (VP Marketing), Owen Brady (Demand Gen Manager)
**Design**: Open Looker Explore with saved "starter views" — NOT a locked-down dashboard
**Default**: U-shaped attribution model selected; last 12 months
**Refresh**: Daily

---

## Wireframe — Starter View: Attribution Overview

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║  MA-02: Multi-Touch Attribution Analysis (Self-Service Explore)                 ║
║  [Attribution Model: U-Shaped (default) ▼]  [Closed-Won ▼]  [Last 12 months ▼] ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  REVENUE ATTRIBUTED BY CHANNEL — U-Shaped Model                            │║
║  │                                                                              │║
║  │  LinkedIn Ads    ███████████████████████████████  $1,240K (31%)             │║
║  │  Google Ads      ████████████████████████  $980K  (24%)                     │║
║  │  Content/SEO     ███████████████  $620K  (15%)                              │║
║  │  Events          ████████████  $480K  (12%)                                 │║
║  │  SDR Outreach    ████████  $320K  (8%)                                       │║
║  │  Meta Ads        ████  $180K  (4%)                                           │║
║  │  Email           ███  $140K  (3%)                                            │║
║  │  Unattributed    ██  $80K  (2%)                                              │║
║  │                                                                              │║
║  │  Total attributed: $4.04M closed-won ARR                                    │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌────────────────────────────────────┐  ┌─────────────────────────────────────┐║
║  │  MODEL COMPARISON                  │  │  ATTRIBUTION SHARE TREND            │║
║  │                                    │  │  (Last 12 months, area chart)        │║
║  │  Channel     │ 1st │ Last │ Lin │ TD│ Us│  │                                 │║
║  │  ────────────────────────────────  │  │  100% ┤██████████████               │║
║  │  LinkedIn    │ 38% │  12% │ 27% │22%│31%│  │   80% ┤████████████████         │║
║  │  Google      │ 22% │  31% │ 25% │28%│24%│  │   60% ┤███████████████████      │║
║  │  Content     │ 18% │   8% │ 15% │12%│15%│  │   40% ┤████████████████████     │║
║  │  Events      │  8% │  14% │ 12% │13%│12%│  │   20% ┤█████████████████████    │║
║  │  SDR         │  6% │  22% │  8% │12%│ 8%│  │    0% └─────────────────────── │║
║  │  Other       │  8% │  13% │ 13% │13%│10%│  │       Q1   Q2   Q3   Q4        │║
║  │                                    │  │  [■ LinkedIn ■ Google ■ Content ■ Other]│║
║  └────────────────────────────────────┘  └─────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  AVERAGE TOUCHES BEFORE CLOSE BY SEGMENT                                   │║
║  │                                                                              │║
║  │  Segment        │ Avg Touches │ Avg Days to Close │ Primary Channel         │║
║  │  ─────────────────────────────────────────────────────────────────────────  │║
║  │  Enterprise     │     14.2    │       118 days    │ LinkedIn Ads            │║
║  │  Mid-Market     │      9.8    │        76 days    │ Google Ads              │║
║  │  SMB            │      4.1    │        34 days    │ Meta Ads                │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  CONTENT ASSET INFLUENCE — Closed-Won vs. Lost Journeys                    │║
║  │  (Which assets appear most frequently in winning journeys?)                 │║
║  │                                                                              │║
║  │  Asset                      │ Won journeys │ Lost journeys │ Win rate        │║
║  │  ─────────────────────────────────────────────────────────────────────────  │║
║  │  ROI Calculator Tool        │     84        │      31       │   73%           │║
║  │  Enterprise Pricing Guide   │     71        │      28       │   72%           │║
║  │  CoreFM Demo Video          │     63        │      44       │   59%           │║
║  │  Facilities 2024 Report     │     57        │      38       │   60%           │║
║  │  ...                        │     ...       │      ...      │   ...           │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  FUNNEL VELOCITY — Average Days Per Stage By Channel                       │║
║  │                                                                              │║
║  │  Stage          │ Google Ads │ LinkedIn │ Content │ Events │ SDR │ Overall  │║
║  │  ─────────────────────────────────────────────────────────────────────────  │║
║  │  Lead → MQL     │    8.2     │   12.1   │   14.8  │  4.1   │ 3.2 │   9.4   │║
║  │  MQL → SAL      │    3.1     │    4.8   │    5.2  │  2.8   │ 2.4 │   3.8   │║
║  │  SAL → SQL      │    5.4     │    7.2   │    8.1  │  4.2   │ 3.8 │   6.0   │║
║  │  SQL → Opp      │    4.8     │    6.4   │    7.2  │  3.8   │ 3.4 │   5.2   │║
║  │  Opp → Close    │   48.2     │   82.4   │   91.4  │ 62.4   │54.2 │  68.1   │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  💡 Saved Starter Views: [Overview] [Budget Review] [Campaign Drilldown] [Board Prep]║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Data Requirements

| View / Tile | Models | Key Measures | Key Dimensions |
|-------------|--------|-------------|---------------|
| Revenue by channel | fct_opportunity_attribution | attributed_revenue_usd (SUM) | channel, attribution_model |
| Model comparison table | fct_opportunity_attribution | attributed_revenue_usd as pct per model | channel, attribution_model (pivot) |
| Attribution share trend | fct_opportunity_attribution | attributed_revenue_usd as pct | month, channel |
| Avg touches before close | fct_opportunity_attribution | count(touch_pk), avg days | segment (from dim_contact) |
| Content asset influence | fct_attribution_touches, fct_opportunity_attribution | count of journeys with asset, win rate | asset_category, is_closed_won |
| Funnel velocity by channel | fct_lead_funnel_events | avg days_in_stage | stage_name, channel_of_first_touch |

---

## Filters (Explore-Level)

| Filter | Field | Default |
|--------|-------|---------|
| Attribution model | fct_opportunity_attribution.attribution_model | u_shaped |
| Opportunity type | is_closed_won | Closed-Won |
| Date range | opportunity_close_date | Last 12 months |
| Segment | dim_contact.clearbit_employees_range (mapped) | All |
| Channel | fct_opportunity_attribution.channel | All |
| Campaign | dim_campaign.campaign_name | All |

---

## Saved Starter Views

| View Name | Description | Default Filters |
|-----------|-------------|----------------|
| Overview | Revenue by channel + model comparison | U-shaped, last 12 months, closed-won |
| Budget Review | Channel ROI, cost per SQL, attribution share | U-shaped, last quarter |
| Campaign Drilldown | Top campaigns by attributed revenue per model | U-shaped, last 6 months |
| Board Prep | Executive summary: sourced vs influenced, ROI ratios | All models visible, last 4 quarters |

---

## Interactions

- **Attribution model selector**: Global dropdown changes all tiles simultaneously
- **Channel bar chart**: Click to filter content asset and velocity tables to that channel
- **Model comparison table**: Cells highlight when U-shaped and first-touch differ by >10pp
- **Content asset table**: Sort by win rate to identify highest-converting content
- **Explore link**: "Explore from here" on any tile opens full Looker Explore for ad-hoc analysis
