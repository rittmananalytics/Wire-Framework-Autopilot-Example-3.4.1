# Mockup: CA-03 CS Leadership Scorecard
## Release: 05-customer-analytics

**Dashboard ID**: CA-03
**Purpose**: NRR/GRR trending, churn analysis, and CS team performance for CS and Finance leadership
**Primary audience**: Tara Obinna (VP CS), David Park (CFO), Marcus Webb (VP Sales)
**Refresh**: Daily
**Default filter**: Trailing 12 months, all segments
**Access control**: NRR/GRR and ARR tiles restricted to `finance_viewers` and `leadership` Looker groups

---

## Wireframe

```
+------------------------------------------------------------------+
| CA-03 CS LEADERSHIP SCORECARD                                    |
| Filters: [Period ▼] [Segment ▼] [Region ▼]                     |
| [🔒 Financial metrics visible to Finance + Leadership only]      |
+------------------------------------------------------------------+

ROW 1 — NRR/GRR KPI TILES (finance_viewers + leadership only)
+----------+ +----------+ +----------+ +----------+ +----------+
| TRAILING | | TRAILING | | NET ARR  | | CHURNED  | | EXPANSION|
| 12M NRR  | | 12M GRR  | | MOVEMENT | | ARR (YTD)| | ARR (YTD)|
|          | |          | |          | |          | |          |
|  107.3%  | |  96.8%   | | +$1.4M   | | -$2.1M   | | +$3.5M   |
| ▲ +2.1pp | | ▲ +1.2pp | | vs prior | |          | |          |
+----------+ +----------+ +----------+ +----------+ +----------+

ROW 2 — NRR/GRR TREND + ARR BRIDGE
+----------------------------------+  +----------------------------------+
| NRR / GRR TREND (12 MONTHS)     |  | ARR BRIDGE — LAST 12 MONTHS      |
| (line chart, monthly)            |  | (waterfall chart)                |
|                                  |  |                                  |
|  115%|  ···········Target         |  | Begin: $36.1M                   |
|  110%|           /               |  | +Expansion: +$3.5M ████         |
|  105%|    /~~~~~~                |  | -Contraction: -$0.8M ░░         |
|  100%|~~~                        |  | -Churn: -$2.1M ░░░░             |
|   95%|                           |  | New: +$1.7M ████                |
|      +--J-F-M-A-M-J-J-A-S-O-N-D |  | End: $38.4M                    |
|  [— NRR  --- GRR  ··· Target]   |  |                                  |
+----------------------------------+  +----------------------------------+

ROW 3 — CHURN ANALYSIS
+----------------------------------+  +----------------------------------+
| CHURNED ARR BY REASON            |  | CHURN BY COHORT (MONTHS SINCE    |
| (bar chart, trailing 12 months)  |  | CONTRACT START)                  |
|                                  |  |                                  |
| Product Fit  ████████ $800K      |  | 0-6m   ██░░░░░░░░ 12%           |
| Price/Budget ████░░░░ $450K      |  | 7-12m  ████░░░░░░ 18%           |
| Competitor   ███░░░░░ $380K      |  | 13-18m ██████░░░░ 28%           |
| No Engagement████░░░░ $310K      |  | 19-24m ████████░░ 35%           |
| Unknown      ██░░░░░░ $160K      |  |                                  |
+----------------------------------+  +----------------------------------+

ROW 4 — AT-RISK RENEWAL PIPELINE (finance_viewers + leadership)
+------------------------------------------------------------------+
| RENEWAL PIPELINE AT RISK (Next 90 Days)                          |
+------------------+-------+-------+----------+----------+--------+
| ACCOUNT          | ARR   | SCORE | CHURN    | RENEWAL  | CSM    |
|                  |       |       | RISK     | DATE     |        |
+------------------+-------+-------+----------+----------+--------+
| Meridian Corp    | $285K |  28   | Critical | Apr 15   |S.Patel |
| Thornfield Ltd   | $195K |  31   | Critical | Mar 29   | J.Lee  |
| Apex Systems     | $420K |  35   | High     | May 2    | K.Osei |
| (6 more rows)    |       |       |          |          |        |
+------------------+-------+-------+----------+----------+--------+
| Total At-Risk ARR: $2.3M  |  Weighted ARR: $1.1M                |
+------------------------------------------------------------------+

ROW 5 — CSM PERFORMANCE (non-financial)
+------------------------------------------------------------------+
| CSM HEALTH OUTCOMES (Not financial — health score outcomes only) |
+-----------+--------+--------+----------+----------+--------------+
| CSM       | ACCTS  | AVG    | AT-RISK  | RECOVERED| EXPANSION    |
|           |        | HEALTH | ACCTS    | (WAS <40)| SIGNALS      |
+-----------+--------+--------+----------+----------+--------------+
| S.Patel   |  52    |  62    |   8      |    3     |    7         |
| K.Osei    |  48    |  68    |   5      |    4     |    5         |
| J.Lee     |  56    |  59    |   9      |    2     |    6         |
| (+ 3 more)|        |        |          |          |              |
+-----------+--------+--------+----------+----------+--------------+
+------------------------------------------------------------------+
```

---

## Data Requirements

| Chart/Tile | Explore | Measures | Dimensions | Access |
|-----------|---------|----------|-----------|--------|
| NRR/GRR tiles | nrr_grr | nrr_trailing_12m, grr_trailing_12m | — | finance_viewers + leadership |
| ARR movement tiles | nrr_grr | expansion_arr, churn_arr, net_arr | — | finance_viewers + leadership |
| NRR/GRR trend | nrr_grr | nrr, grr | month_start | finance_viewers + leadership |
| ARR bridge | nrr_grr | beginning_arr, expansion_arr, contraction_arr, churn_arr, ending_arr | — | finance_viewers + leadership |
| Churn by reason | churn_events | arr_impacted, count_events | reason_category | All |
| Churn by cohort | churn_events | arr_impacted | months_since_contract_start | All |
| At-risk renewal table | renewal_pipeline | account_name, arr_usd, health_score, churn_risk_band, renewal_date, csm_owner | is_at_risk, days_to_renewal | finance_viewers + leadership (ARR); All (health/risk) |
| CSM performance | csm_book | count_accounts, avg_health_score, count_at_risk, count_recovered, count_expansion | csm_owner | All (non-financial) |

---

## Filters

| Filter | Type | Default | Values |
|--------|------|---------|--------|
| Period | Single-select | Last 12 months | Last 3m, 6m, 12m, 24m, Custom |
| Segment | Multi-select | All | Strategic, Enterprise, Mid-Market, SMB |
| Region | Multi-select | All | North America, EMEA |
| CSM Owner | Multi-select | All | All CSMs (leadership only) |

---

## Interactions

- Drill-through: NRR/GRR tile → modal with NRR bridge detail
- Drill-through: Churn by reason bar → table of accounts with that churn reason
- Drill-through: At-risk account → opens CA-02 filtered to that account
- Alert: Weekly NRR summary → #cs-leadership Slack (Monday 08:00)
- Alert: Renewal at-risk → #revenue-ops Slack (daily, accounts <40 health + renewal <90 days)
