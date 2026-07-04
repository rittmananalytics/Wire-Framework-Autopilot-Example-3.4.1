# Mockup: PB-01 Product Adoption Overview
## Release: 04-product-analytics

**Purpose**: Show feature adoption breadth across all accounts; identify underutilised modules and features for product/CS intervention
**Audience**: Claire Ashworth (VP Product), Leon Yip, Fatima Al-Rashidi, CS leadership
**Default filters**: Last 30 days; All Modules; All Segments
**Refresh**: Daily

---

## Wireframe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PB-01: Product Adoption Overview                              [Last 30 days▼]│
│                                                   [Module: All▼] [Segment▼] │
├─────────────────┬──────────────────┬──────────────────┬──────────────────────┤
│ Active Accounts │  Avg Feature     │ Avg DAU/MAU      │ Avg Engagement       │
│ [243]           │  Breadth         │ [0.41]           │ Score                │
│ [▲ 8% vs prev] │  [18 features]   │ [▲ 3%]           │ [67]  [▲ 2pts]       │
├─────────────────┴──────────────────┴──────────────────┴──────────────────────┤
│ Feature Adoption Heatmap                          [Group by: Feature Group▼] │
│                                                                               │
│ Account →   Acc1 Acc2 Acc3 Acc4 Acc5 ... Acc243      Feature Group           │
│ Work Order Mgmt ████ ████ ████ ░░░░ ████            Maintenance Mgmt        │
│ Asset Mgmt      ████ ████ ░░░░ ░░░░ ████            Maintenance Mgmt        │
│ Scheduled WO    ████ ░░░░ ░░░░ ░░░░ ░░░░            Maintenance Mgmt        │
│ Report Builder  ████ ████ ░░░░ ████ ░░░░            Reporting               │
│ Dashboard       ████ ░░░░ ░░░░ ░░░░ ░░░░            Reporting               │
│ IoT Connect     ░░░░ ░░░░ ░░░░ ░░░░ ░░░░            Integrations            │
│                 ...                                                           │
│ ████ = Used    ░░░░ = Not Used    [Click cell to see feature detail]         │
│ [Drill through to Feature level ↓]                                           │
├───────────────────────────────────────────────────────────────────────────────┤
│ Module Adoption Summary                   │ Top 10 Underutilised Features     │
│                                           │                                   │
│ Module            | Adoption% | Trend     │ Feature         | Adoption% | Gap │
│ Maintenance Mgmt  |    89%    | ↑         │ Recurring WO    |    23%    | High│
│ Reporting         |    74%    | →         │ IoT Connect     |    18%    | High│
│ Asset Management  |    91%    | ↑         │ QR Asset Scan   |    31%    | Med │
│ Integrations      |    22%    | ↓         │ Report Schedule |    42%    | Med │
│ Mobile App        |    67%    | ↑         │ Bulk Import     |    38%    | Med │
│                                           │                                   │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Requirements

| Tile | Measure | Dimension | Source Model |
|------|---------|-----------|-------------|
| Active Accounts KPI | count distinct account_pk | where has any session in period | fct_session_events |
| Avg Feature Breadth | avg(distinct_features_used) | by account | dim_account_product_score |
| Avg DAU/MAU | avg(dau_mau_ratio) | by account | dim_account_product_score |
| Avg Engagement Score | avg(product_engagement_score) | by account | dim_account_product_score |
| Heatmap | usage flag per account × feature_group | date filter | fct_feature_usage |
| Module Adoption % | accounts using module / total accounts | by module | fct_feature_usage |
| Underutilised Features | adoption % ascending | feature level | fct_feature_usage |

## Interactions

- **Heatmap drill-through**: Click Feature Group row → expand to Feature level (controlled by `group_by` dimension selector)
- **Module filter**: Filters heatmap to show only feature groups within selected module
- **Segment filter**: Filters all tiles to selected account segment (Enterprise / Mid-Market / SMB / Strategic)
- **Cell click**: Opens a tooltip or drill to PB-02 filtered to that account
