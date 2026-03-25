# Mockup: PB-03 Onboarding Funnel Analysis
## Release: 04-product-analytics

**Purpose**: Show onboarding progress across all accounts; surface stalled accounts for CSM intervention; track time-to-completion per step
**Audience**: Tara Obinna (VP CS), CSMs, Claire Ashworth
**Default filters**: All CSMs; Last 90 days (signup date range); All Segments
**Refresh**: Daily

---

## Wireframe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PB-03: Onboarding Funnel Analysis                          [CSM: All▼]      │
│                                                [Signup Date▼] [Segment▼]    │
├───────────────┬───────────────┬──────────────────────────────────────────────┤
│ Accounts in   │ Fully         │ Accounts Stalled  │ Avg Days to         │
│ Onboarding    │ Onboarded     │ (>14d on step)    │ Core Complete       │
│ [47]          │ [201/312]     │ [12]  ⚠           │ [34 days]           │
│               │ [64%]         │                   │                     │
├───────────────┴───────────────┴───────────────────────────────────────────--─┤
│ Onboarding Funnel                                                             │
│                                                                               │
│ Step 1: Invite Users       ████████████████████████████████████████  94%     │
│ Step 2: Create First Asset ████████████████████████████████████      89%     │
│ Step 3: Import Asset List  ██████████████████████████████████        82%     │
│ Step 4: Create Work Order  █████████████████████████████             72%  ← KEY STEP│
│ Step 5: Configure Report   ██████████████████████                    58%     │
│ ─── Core Complete Line ─────────────────────────────────────────────────     │
│ Step 6: IoT Integration    ████████                                  22%  (optional)│
│ Step 7: QBR Ready          ██████████████████████████████████████    88%     │
│                                                                               │
│ [Filter by Core Steps Only] [Show Drop-off %]                                │
├───────────────────────────────────────────────────────────────────────────────┤
│ Stalled Accounts (>14 days without progress)                                  │
│                                                                               │
│ Account Name       | Segment    | CSM           | Stalled On  | Days Stalled │
│ Brownfield Corp    | Enterprise | Sarah Evans   | Step 4 WO   | 21 days  ⚠  │
│ Metro Facilities   | Mid-Market | James Okonkwo | Step 3 Import| 18 days ⚠  │
│ TechBuild Ltd      | SMB        | Sarah Evans   | Step 2 Asset | 16 days ⚠  │
│ ...                                                                           │
│ [Click row → open PB-02 for that account]                                    │
├───────────────────────────────────────────────────────────────────────────────┤
│ Step Completion Time Distribution (Violin/Box Plot)                           │
│                                                                               │
│        Step 1  Step 2  Step 3  Step 4  Step 5                                │
│   P75  5d      12d     21d     31d     45d                                   │
│   P50  2d      6d      14d     18d     30d                                   │
│   P25  1d      3d      8d      9d      20d                                   │
│                                                                               │
│ Dashed line: Target completion date per step                                 │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Requirements

| Tile | Measure | Source Model |
|------|---------|-------------|
| Accounts in Onboarding | count distinct account_pk where any step not complete | fct_onboarding_funnel |
| Fully Onboarded | count distinct account_pk where all 5 core steps complete | fct_onboarding_funnel |
| Stalled Accounts | count distinct account_pk where any step is_stalled=TRUE | fct_onboarding_funnel |
| Avg Days to Core Complete | avg(days_since_signup) for accounts at step 5 completion | fct_onboarding_funnel |
| Funnel bars | % accounts completing each step | fct_onboarding_funnel |
| Stalled table | account, csm, step, days_stalled | fct_onboarding_funnel + dim_account |
| Time distribution | percentiles of days_since_signup per step | fct_onboarding_funnel |

## Interactions

- **CSM filter**: Filters all tiles to accounts assigned to selected CSM
- **Stalled row click**: Drill-through to PB-02 for that account
- **Step 4 highlight**: Work order step highlighted as "KEY STEP" per Claire Ashworth's note — critical for retention
- **Segment filter**: Enterprise/Mid-Market/SMB/Strategic
- **Core steps only toggle**: Hides Steps 6–7 from funnel for cleaner executive view
