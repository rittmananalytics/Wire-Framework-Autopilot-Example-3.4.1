# Mockup: CA-02 CSM Book of Business
## Release: 05-customer-analytics

**Dashboard ID**: CA-02
**Purpose**: Per-CSM view of assigned accounts with health scores, churn risk, action items, and expansion signals. Row-level security ensures each CSM sees only their accounts.
**Primary audience**: Individual CSMs (6 users), Tara Obinna (sees all accounts)
**Refresh**: Daily
**Default filter**: Current CSM's accounts (auto-applied via RLS)

---

## Row-Level Security Note

Looker `csm_owner` user attribute is set per user to match `stg_salesforce__accounts.csm_owner`. The `dim_account_health` explore filters by `${fct_csm_book_of_business.csm_owner} = {% parameter current_user_csm %}`. Tara Obinna has `is_leadership` = true — her view shows all accounts across all CSMs.

---

## Wireframe

```
+------------------------------------------------------------------+
| CA-02 CSM BOOK OF BUSINESS                                       |
| [RLS: Showing accounts for: Sarah Patel]  [Date: Today]         |
| Filters: [Health Band ▼] [Churn Risk ▼] [Renewal Window ▼]     |
+------------------------------------------------------------------+

ROW 1 — MY BOOK SUMMARY (KPI tiles)
+----------+ +----------+ +----------+ +----------+ +----------+
| MY       | | AT-RISK  | | RENEWALS | | OPEN     | | EXPAN-   |
| ACCOUNTS | | ACCOUNTS | | <90 DAYS | | ACTIONS  | | SION OPP |
|          | |          | |          | |          | |          |
|    52    | |    8     | |    6     | |   14     | |   7      |
| $6.8M ARR| | $980K    | | $1.4M    | | (tickets | |          |
+----------+ +----------+ +----------+ +----------+ +----------+

ROW 2 — ACCOUNT HEALTH OVERVIEW
+------------------------------------------------------------------+
| MY ACCOUNTS — HEALTH OVERVIEW                                    |
| (scatter plot: x=health_score, y=arr_usd, size=days_to_renewal) |
|                                                                  |
|  ARR↑                    ●●                                     |
|       ●●    ●  ●●●    ●    ● ●                                  |
|   ●●     ●●  ●   ●  ●●                                         |
|                              ●●  ●●●                            |
|                                                                  |
|    [At Risk] [Needs Attn] [Healthy] [Excellent]                  |
|    (Bubble size = days to renewal; smaller = sooner)             |
+------------------------------------------------------------------+

ROW 3 — ACCOUNT LIST TABLE (sortable, paginated)
+------------------------------------------------------------------+
| ACCOUNT LIST                                     [Export CSV]   |
+------------+------+------+-------+-------+-------+------+------+
| ACCOUNT    | ARR  | HLTH | TREND | CHURN | RENEWL| LAST | ACTN |
|            |      | SCRE |  7D   | RISK  |  DAYS | QBR  |      |
+------------+------+------+-------+-------+-------+------+------+
| Meridian   | $285K|  28  | ▼-12  | CRIT  |  45   | 180d | ★★★  |
| Global FM  | $380K|  72  | ▲+5   | Low   | 120   | 45d  |      |
| MetroFac   | $210K|  64  | ─ 0   | Med   |  89   | 60d  | ★    |
| Apex Sys   | $420K|  35  | ▼-8   | High  |  62   | 210d | ★★   |
| ...        |      |      |       |       |       |      |      |
+------------+------+------+-------+-------+-------+------+------+
| ★ = Open action items; ★★★ = 3+ actions                        |
+------------------------------------------------------------------+

ROW 4 — ACCOUNT DETAIL (click row to expand)
+------------------------------------------------------------------+
| MERIDIAN CORP — DETAIL                              [← Back]    |
+-------------------------------+  +-----------------------------+
| HEALTH SCORE TREND (90 days) |  | SCORE COMPONENTS            |
|                               |  |                             |
|  60|                          |  | Product      ██████ 45%     |
|  40|~~~___                    |  | Support      ████   35%     |
|  20|      \_____              |  | Financial    ██     20%     |
|    +--Jan-Feb-Mar             |  | Relationship ███    30%     |
|                               |  | NPS          █      15%     |
+-------------------------------+  +-----------------------------+
| CHURN RISK: CRITICAL (82%)   |  | RENEWAL: 45 days ($285K)    |
| OPEN ACTIONS (3):             |  | EXPANSION: No signal        |
| • Step 4 (Work Order) overdue |  |                             |
| • 2 open P1 tickets           |  | [Flag for CSM Follow-up ►] |
| • No QBR in 180+ days         |  | [Export QBR Data ►]        |
+-------------------------------+  +-----------------------------+

ROW 5 — STALLED ONBOARDING (cross-release from Release 04)
+------------------------------------------------------------------+
| ACCOUNTS WITH STALLED ONBOARDING (>14 days, no progress)       |
+----------------+-----------+----------+------------------------+
| ACCOUNT        | STEP      | DAYS     | RECOMMENDED ACTION     |
|                | STALLED   | STALLED  |                        |
+----------------+-----------+----------+------------------------+
| Meridian Corp  | Step 4    | 28 days  | Create Work Order      |
| Apex Systems   | Step 3    | 16 days  | Import Asset List      |
| ...            |           |          |                        |
+----------------+-----------+----------+------------------------+
+------------------------------------------------------------------+
```

---

## Data Requirements

| Chart/Table | Explore | Measures | Dimensions |
|------------|---------|----------|-----------|
| KPI tiles | csm_book | count_accounts, total_arr_usd, count_at_risk, count_renewals_90d, count_open_actions | csm_owner (RLS), is_at_risk, days_to_renewal |
| Scatter plot | csm_book | health_score, arr_usd, days_to_renewal | account_name, health_band, churn_risk_band |
| Account table | csm_book | account_name, arr_usd, health_score, score_change_7d, churn_risk_band, days_to_renewal, days_since_qbr, open_action_count | csm_owner (RLS) |
| Health trend | customer_health | health_score | account_pk, score_date |
| Score components | customer_health | product/support/financial/relationship/nps_component | account_pk, score_date |
| Stalled onboarding | onboarding_funnel (R04) | step_name, days_stalled | account_pk, is_stalled |

---

## Filters

| Filter | Type | Values |
|--------|------|--------|
| Health Band | Multi-select | At Risk, Needs Attention, Healthy, Excellent |
| Churn Risk | Multi-select | Critical, High, Medium, Low |
| Renewal Window | Single-select | < 30 days, < 60 days, < 90 days, < 180 days, All |
| Account Search | Free text | Account name search |

---

## Looker Actions

| Action | Trigger | Destination | Payload |
|--------|---------|-------------|---------|
| Flag for CSM Follow-up | Row-level button in account table | Salesforce Task API | Account name, CSM owner, health score, churn risk, due date = today+7 |
| Export QBR Data | Account detail button | Google Slides template | Account name, health score trend (90d), score components, renewal date, expansion signals, open actions |

---

## Interactions

- Click account row → expands inline detail view (health trend, score components, churn risk, open actions)
- Drill-through from stalled onboarding → opens Release 04 PB-03 filtered to account
- Tara Obinna sees all CSMs with a "CSM Owner" column and filter enabled
- Alert: "At-risk account alert" → daily Slack DM to CSM when new account crosses below health score 40
