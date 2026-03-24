# Mockup: MA-01 — Demand Generation Performance
## Release: 03-marketing-analytics

**Purpose**: Weekly operational dashboard for Monday marketing standup — shows pipeline, funnel conversion, spend, and cost efficiency for the last 7 days with period-over-period comparison.
**Audience**: Rachel Summers (VP Marketing), Owen Brady (Demand Gen Manager), Niamh Collins (Marketing Ops)
**Default date range**: Last 7 days (period-over-period vs. prior 7 days)
**Refresh**: Daily by 07:00 UTC

---

## Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║  MA-01: Demand Generation Performance                    [Last 7 days ▼] [Date] ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                  ║
║  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ ║
║  │   LEADS     │ │    MQLs     │ │    SALs     │ │    SQLs     │ │   SPEND   │ ║
║  │     247     │ │      89     │ │      41     │ │      28     │ │  $84,200  │ ║
║  │  ▲ +12%     │ │  ▲ +8%     │ │  ▼ -3%     │ │  ▲ +15%    │ │  ▲ +6%   │ ║
║  │ vs prior 7d │ │ vs prior 7d │ │ vs prior 7d │ │ vs prior 7d │ │vs prior 7d║ ║
║  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ ║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────┐                   ║
║  │  FUNNEL VOLUME — Last 13 Weeks (bar chart)               │                   ║
║  │                                                          │                   ║
║  │  300 ┤█████████████████████████                         │                   ║
║  │  200 ┤  ███████ ███████████████                         │                   ║
║  │  100 ┤      ███████████   █████                         │                   ║
║  │   50 ┤          ████████████                            │                   ║
║  │    0 └──────────────────────────────────────            │                   ║
║  │       Wk1 Wk2 Wk3 Wk4 Wk5 Wk6 Wk7 Wk8 Wk9 ...        │                   ║
║  │       [■ Leads] [■ MQLs] [■ SALs] [■ SQLs] [■ Opps]   │                   ║
║  └──────────────────────────────────────────────────────────┘                   ║
║                                                                                  ║
║  ┌───────────────────────────────────┐  ┌──────────────────────────────────────┐║
║  │  FUNNEL CONVERSION RATES          │  │  SPEND BY CHANNEL — This vs Last Mo  │║
║  │                                   │  │                                      │║
║  │  MQL → SAL    ████████░░  46%     │  │  Google Ads   ████████████  $38,400  │║
║  │  SAL → SQL    ██████░░░░  68%     │  │  LinkedIn     ████████      $28,100  │║
║  │  SQL → Opp    ████████░░  78%     │  │  Meta         ████          $14,200  │║
║  │  Opp → Close  ████░░░░░░  31%     │  │                                      │║
║  │                                   │  │  [■ This month] [░ Last month]       │║
║  └───────────────────────────────────┘  └──────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────────────────────────┐║
║  │  TOP 10 CAMPAIGNS BY PIPELINE GENERATED                                     │║
║  │                                                                              │║
║  │  Campaign                    │ Channel      │ Spend    │ Pipeline │ CPsql   │ Maj.Stage  ║
║  │  ──────────────────────────────────────────────────────────────────────────  │║
║  │  Q1 ABM Enterprise Wave      │ LinkedIn     │ $14,200  │ $320K    │ $2,840  │ Demo       ║
║  │  Google Brand Awareness      │ Paid Search  │ $8,100   │ $218K    │ $1,620  │ Proposal   ║
║  │  March Webinar — AI in FM    │ Content      │ $2,400   │ $185K    │ $960    │ Discovery  ║
║  │  Meta Retargeting Wave 3     │ Meta Ads     │ $5,200   │ $142K    │ $2,080  │ Demo       ║
║  │  ...                         │ ...          │ ...      │ ...      │ ...     │ ...        ║
║  │                                                                              │║
║  │  [majority pipeline stage = mode of Salesforce opp stage for leads from     │║
║  │   this campaign; shows where leads are progressing in the funnel]           │║
║  └──────────────────────────────────────────────────────────────────────────────┘║
║                                                                                  ║
║  ┌──────────────────────────────────────────────────────────┐                   ║
║  │  COST PER MQL AND SQL BY CHANNEL                         │                   ║
║  │                                                          │                   ║
║  │  Channel       │ Spend    │ MQLs │ CPM    │ SQLs │ CPsql  │ Trend (4wk)    │ ║
║  │  ──────────────────────────────────────────────────────  │                   ║
║  │  Google Ads    │ $38,400  │  42  │ $914   │  15  │ $2,560 │ ▼ (improving)  │ ║
║  │  LinkedIn Ads  │ $28,100  │  28  │ $1,004 │  10  │ $2,810 │ → (stable)     │ ║
║  │  Meta Ads      │ $14,200  │  19  │ $747   │   3  │ $4,733 │ ▲ (worsening)  │ ║
║  └──────────────────────────────────────────────────────────┘                   ║
║                                                                                  ║
║  ⚠ Data Coverage: 71% of touches have UTM attribution. 29% tagged "unattributed"║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Data Requirements

| Tile | Models | Key Measures | Key Dimensions |
|------|--------|-------------|---------------|
| KPI tiles (5) | fct_lead_funnel_events | leads, mqls, sals, sqls, spend_usd | period (this 7d vs prior 7d) |
| Funnel volume (13 weeks) | fct_lead_funnel_events | count by stage | week, stage_name |
| Funnel conversion rates | fct_lead_funnel_events | conversion_rate (pct) | stage transition pair |
| Spend by channel | fct_campaign_spend | spend_usd | channel, month (this vs last) |
| Top 10 campaigns | fct_campaign_spend, fct_opportunity_attribution | spend, pipeline, cost_per_sql, majority_pipeline_stage | campaign_name, channel |
| Cost per MQL/SQL by channel | fct_lead_funnel_events, fct_campaign_spend | cpm, cpsql, trend sparkline | channel |
| Data coverage tile | fct_attribution_touches | pct_attributed, pct_unattributed | (summary) |

---

## Filters

| Filter | Field | Default |
|--------|-------|---------|
| Date range | stage_entered_date | Last 7 days |
| Channel | channel | All |
| Segment | dim_contact.clearbit_employees_range mapped to segment | All |

---

## Interactions

- **Funnel bar chart**: Click on a bar to filter all tiles to that week
- **Top 10 campaigns table**: Click campaign name → opens MA-02 Explore filtered to that campaign
- **Cost per channel table**: Trend column shows 4-week sparkline inline
- **Majority pipeline stage**: Tooltip explains "Mode calculation — the stage where the most leads from this campaign currently sit"
- **Data coverage tile**: Tooltip links to UTM enforcement documentation
