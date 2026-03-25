# Mockup: PB-02 Account-Level Product Usage
## Release: 04-product-analytics

**Purpose**: Deep-dive view of a single account's product usage; designed as a drill-through destination from CA-01 (Release 05 Customer Analytics) and PB-01
**Audience**: CSMs, Account Executives, Tara Obinna (VP CS)
**Default filters**: Single account selector (required); Last 90 days
**Refresh**: Daily

---

## Wireframe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PB-02: Account-Level Product Usage                                           │
│ Account: [Select Account▼]                               [Last 90 days▼]    │
│                                                                               │
│ ┌─────────────────────────────────────────────────────────────────────────┐  │
│ │ PINNACLE FACILITIES GROUP                         [View in Salesforce↗]  │  │
│ │ Segment: Enterprise  |  CSM: Tara Obinna  |  Contract: $220K ACV        │  │
│ └─────────────────────────────────────────────────────────────────────────┘  │
├───────────────┬───────────────┬───────────────┬──────────────────────────────┤
│ Engagement    │ DAU / MAU     │ Licence Util  │ Onboarding                   │
│ Score         │               │               │ Completion                   │
│ [78]          │ [0.52]        │ [74%]         │ [5/5 core steps] ✓           │
│ [Healthy]     │ [↑ 0.06]      │ [63/85 seats] │ [Extended: 1/2]              │
├───────────────┴───────────────┴───────────────┴──────────────────────────────┤
│ Score Components (Radar chart)    │ Feature Usage Trend (Line chart)          │
│                                   │                                           │
│     DAU/MAU     NPS               │  Distinct features used over time         │
│       ○───────○                   │  25 ┤    ___________                      │
│      /         \                  │  20 ┤  _/                                 │
│ Onboarding     Feature Breadth    │  15 ┤_/                                   │
│      \         /                  │     └────────────────────────             │
│       ○───────○                   │       Oct    Nov    Dec    Jan            │
│   Work Order  Lic. Util           │                                           │
├────────────────────────────────────────────────────────────────────────────--─┤
│ Feature Adoption by Module        │ Top 10 Features Used (Last 30 days)       │
│                                   │                                           │
│ Module           | % Adopted      │ Feature                | Sessions | Users │
│ Work Order Mgmt  | ████████ 91%   │ Create Work Order      |   1,240  |  48   │
│ Asset Management | ███████  84%   │ Update Asset Status    |     890  |  31   │
│ Reporting        | █████    62%   │ Generate PDF Report    |     445  |  12   │
│ Mobile App       | ████     55%   │ Assign Work Order      |     412  |  38   │
│ Integrations     | ██       28%   │ View Asset History     |     388  |  22   │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Requirements

| Tile | Measure | Source Model |
|------|---------|-------------|
| Engagement Score | product_engagement_score | dim_account_product_score |
| DAU/MAU | dau_mau_ratio | dim_account_product_score |
| Licence Utilisation | licence_utilisation_pct; active_users / contracted_seats | dim_account_product_score + dim_account |
| Onboarding Completion | core_steps_completed / 5; extended steps | fct_onboarding_funnel |
| Score Radar | All 7 score component values | dim_account_product_score |
| Feature Usage Trend | distinct features per month | fct_feature_usage |
| Module Adoption | % features used per module | fct_feature_usage |
| Top Features | count sessions per feature | fct_feature_usage |

## Interactions

- **Account selector**: Required filter; all tiles update to show selected account only
- **Salesforce link**: Opens Salesforce account record in new tab
- **Drill from PB-01**: Account pre-populated when drilled from heatmap cell
- **Drill to CA-01**: "View Customer Health" link (available in Release 05)
- **CSM filter note**: In PB-03, filtered by CSM; PB-02 accessed per account from PB-03 drill-through
