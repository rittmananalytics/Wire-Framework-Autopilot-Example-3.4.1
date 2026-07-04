# Mockup: CA-01 Customer Health Command Centre
## Release: 05-customer-analytics

**Dashboard ID**: CA-01
**Purpose**: Portfolio-level view of all 312 accounts — health distribution, at-risk ARR, churn trend, and renewal pipeline
**Primary audience**: Tara Obinna (VP CS), CS leadership, Marcus Webb (VP Sales)
**Refresh**: Daily
**Default filter**: All segments, all CSMs, last 30 days

---

## Wireframe

```
+------------------------------------------------------------------+
| CA-01 CUSTOMER HEALTH COMMAND CENTRE                             |
| Filters: [Segment ▼] [CSM Owner ▼] [Region ▼] [Date Range ▼]   |
+------------------------------------------------------------------+

ROW 1 — KPI TILES (5 tiles)
+----------+ +----------+ +----------+ +----------+ +----------+
| HEALTHY  | | NEEDS    | | AT RISK  | | AT-RISK  | | CHURN    |
| ACCOUNTS | | ATTN     | | ACCOUNTS | | ARR      | | PROB     |
|          | |          | |          | |          | | (30-DAY) |
|   187    | |   89     | |   36     | |$4.2M     | |  11.5%   |
| ████████ | | ██████░░ | | ████░░░░ | | of $38M  | |▼ -0.3pp  |
+----------+ +----------+ +----------+ +----------+ +----------+

ROW 2 — HEALTH DISTRIBUTION + AT-RISK ARR WATERFALL
+----------------------------------+  +----------------------------------+
| HEALTH SCORE DISTRIBUTION        |  | AT-RISK ARR WATERFALL            |
| (stacked bar, last 12 months)    |  | (accounts moving between bands)  |
|                                  |  |                                  |
|  Dec ██████████░░░░░░░░░░        |  |  Excellent→Healthy    +$800K     |
|  Jan ██████████░░░░░░░░░░        |  |  Healthy→Needs Attn   -$1.2M     |
|  Feb ████████████░░░░░░░         |  |  Needs Attn→At Risk   -$600K     |
|  Mar ████████████████░░░░░       |  |  At Risk→Churned      -$200K     |
|                                  |  |  Net Movement:        -$1.2M     |
|  [■ Excellent ■ Healthy          |  |                                  |
|   □ Needs Attention □ At Risk]   |  |                                  |
+----------------------------------+  +----------------------------------+

ROW 3 — RENEWAL PIPELINE + CHURN TREND
+----------------------------------+  +----------------------------------+
| RENEWAL PIPELINE (180 days)      |  | CHURN TREND (12 months)          |
| (bar chart, grouped by bucket)   |  | (line: GRR % by month)           |
|                                  |  |                                  |
|  0-30d  ██ $2.1M  (8 accounts)  |  |  100%|                            |
|  31-60d ████ $4.5M (14 accts)   |  |   95%|  ~~~~~~~~~~~~~~~~~~~       |
|  61-90d ██████ $6.2M (20 accts) |  |   90%|                            |
|  91-180d █████████ $9.8M        |  |   85%|                            |
|                                  |  |  Target ----                     |
|  [■ Healthy □ Needs Attn        |  |  [— GRR  --- NRR  ··· Target]    |
|   ■ At Risk]                     |  |                                  |
+----------------------------------+  +----------------------------------+

ROW 4 — AT-RISK ACCOUNT TABLE
+------------------------------------------------------------------+
| AT-RISK ACCOUNTS (Health Score < 40 or Renewal < 90 Days)       |
+----------------+-------+-------+----------+----------+----------+
| ACCOUNT        | ARR   | HEALTH| CHURN    | RENEWAL  | CSM      |
|                |       | SCORE | RISK     | IN DAYS  |          |
+----------------+-------+-------+----------+----------+----------+
| Meridian Corp  | $285K |  28   | Critical | 45 days  | S.Patel  |
| Apex Systems   | $420K |  35   | High     | 62 days  | K.Osei   |
| Thornfield Ltd | $195K |  31   | Critical | 18 days  | J.Lee    |
| ...            |       |       |          |          |          |
+----------------+-------+-------+----------+----------+----------+
| [Export CSV]   [Flag Selected for Review →]                      |
+------------------------------------------------------------------+

ROW 5 — EXPANSION SIGNALS
+------------------------------------------------------------------+
| EXPANSION OPPORTUNITIES (High Engagement + Low Utilisation)     |
+----------------+-------+----------+----------+------------------+
| ACCOUNT        | ARR   | FEAT     | LICENCE  | SIGNAL TYPE      |
|                |       | BREADTH  | UTIL %   |                  |
+----------------+-------+----------+----------+------------------+
| GlobalMaint    | $380K |  82%     |  54%     | Expansion        |
| MetroFacility  | $210K |  79%     |  61%     | Upsell Opp       |
| ...            |       |          |          |                  |
+----------------+-------+----------+----------+------------------+
+------------------------------------------------------------------+
```

---

## Data Requirements

| Tile/Chart | Explore | Measures | Dimensions |
|-----------|---------|----------|-----------|
| KPI tiles | customer_health | count_accounts_by_band, arr_at_risk_usd, avg_churn_probability | health_band, is_at_risk |
| Health distribution | customer_health | count_accounts | health_band, score_month |
| At-risk ARR waterfall | customer_health_trend | arr_by_band, arr_band_change | health_band, prior_health_band, month |
| Renewal pipeline | renewal_pipeline | arr_usd, weighted_arr_usd, count_renewals | renewal_bucket, health_band |
| Churn trend | nrr_grr | grr, nrr | month_start |
| At-risk account table | customer_health | account_name, arr_usd, health_score, churn_risk_band, days_to_renewal, csm_owner | is_at_risk, days_to_renewal |
| Expansion signals | expansion_signals | count_signals, arr_usd | signal_type, is_active |

---

## Filters

| Filter | Type | Values |
|--------|------|--------|
| Segment | Multi-select | Strategic, Enterprise, Mid-Market, SMB |
| CSM Owner | Multi-select | All CSMs |
| Region | Multi-select | North America, EMEA |
| Date Range | Date picker | Default: last 30 days |

---

## Interactions

- Drill-through: Click account name in at-risk table → opens CA-02 filtered to that account
- Alert: "Weekly health digest" Scheduled Alert → Slack #cs-team (Monday 08:00)
- Export: At-risk table → CSV download
- Action (Row 4): "Flag Selected for Review" → triggers Looker Action to create Salesforce tasks
