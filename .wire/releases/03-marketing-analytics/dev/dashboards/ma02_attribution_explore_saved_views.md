# MA-02: Multi-Touch Attribution Analysis — Saved Explore Views
## Release: 03-marketing-analytics

**Note**: MA-02 is a self-service Looker Explore (not a locked dashboard). This document specifies the saved "starter views" that Rachel Summers and Owen Brady will use as starting points for exploration.

The Explore is: `marketing_attribution` in `marketing.model.lkml`

---

## Saved View 1: Attribution Overview (Default)

**Purpose**: Primary view for monthly budget review
**Attribution model filter**: u_shaped

**Fields**:
- `fct_opportunity_attribution.channel`
- `fct_opportunity_attribution.attributed_revenue` (bar chart)
- `fct_opportunity_attribution.attribution_model` (in model comparison table)
- `dim_contact.segment`

**Pivots**: attribution_model (for model comparison table)
**Filters**:
- attribution_model = u_shaped
- is_closed_won = Yes
- opportunity_close_date in last 12 months

---

## Saved View 2: Model Comparison

**Purpose**: Side-by-side channel revenue under all 5 attribution models

**Fields**:
- `dim_campaign.channel`
- `fct_opportunity_attribution.attributed_revenue`
- `fct_opportunity_attribution.attribution_model`

**Pivots**: attribution_model
**Chart type**: Grouped bar
**Filters**: is_closed_won = Yes

---

## Saved View 3: Content Asset Influence

**Purpose**: Which content assets appear in closed-won vs. closed-lost journeys

**Fields**:
- `fct_attribution_touches.asset_category`
- Count of opportunities (closed-won)
- Count of opportunities (closed-lost)
- `fct_opportunity_attribution.is_closed_won`

**Pivots**: is_closed_won
**Sorts**: Closed-won count descending

---

## Saved View 4: Funnel Velocity by Channel

**Purpose**: Average days per funnel stage, split by first-touch channel

**Fields**:
- `fct_lead_funnel_events.stage_name`
- `fct_lead_funnel_events.channel`
- `fct_lead_funnel_events.avg_days_in_stage`

**Pivots**: channel
**Chart type**: Table with bar charts in cells
**Filters**: Stage in (lead, mql, sal, sql, opportunity)

---

## Saved View 5: Attribution Share Trend (12 Months)

**Purpose**: How channel attribution share has evolved over the past year

**Fields**:
- `fct_opportunity_attribution.opportunity_close_month`
- `fct_opportunity_attribution.channel`
- `fct_opportunity_attribution.attributed_revenue` (as percentage of total)

**Pivots**: channel
**Chart type**: Area chart (stacked, percentage)
**Filters**: attribution_model = u_shaped, is_closed_won = Yes

---

## Looker Explore URL Parameters

Save each view via Looker's "Save as" → "Save as Explore Look" with the following look names:

| View Name | Look Name |
|-----------|-----------|
| Attribution Overview | MA-02: Attribution Overview (U-Shaped Default) |
| Model Comparison | MA-02: All Models Comparison |
| Content Asset Influence | MA-02: Content Asset Win/Loss Analysis |
| Funnel Velocity | MA-02: Funnel Velocity by Channel |
| Attribution Share Trend | MA-02: Attribution Share Trend (12mo) |
