# Training Exercises — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Session type**: End-user training exercises
**Audience**: Rachel Summers, Owen Brady, Niamh Collins
**Delivered by**: Sophie Tanner, Rittman Analytics

---

## Exercise 1: MA-01 Date Range and Campaign Analysis

**Duration**: 10 minutes
**Participant**: Owen Brady (primary); others observe
**Dashboard**: MA-01 Demand Generation Performance

### Scenario

Owen Brady wants to prepare for the weekly demand gen review. He needs to identify the top campaigns from the last 30 days and understand which ones have pipeline at the most advanced stages.

### Steps

1. Open MA-01 in Looker
2. Change the date range filter from "Last 7 days" to "Last 30 days"
3. Scroll down to the **Top 10 Campaigns** table
4. Sort by **Pipeline Generated** (highest first)
5. Identify the top 3 campaigns by pipeline generated
6. For each of the top 3, note the **Majority Pipeline Stage** column value

### Questions to Answer

1. Which campaign has the highest pipeline generated in the last 30 days?
2. What is the majority pipeline stage for that campaign? What does this tell you?
3. Is there a campaign with high spend but low pipeline? What would you do next?
4. What percentage of touches are currently unattributed (check the UTM coverage tile)?

### Expected Outcomes

- Owen can independently change date ranges and navigate the campaign table
- Owen can identify campaigns worth reviewing in more detail
- Owen understands the significance of the Majority Pipeline Stage column

### Facilitator Notes

- If "Majority Pipeline Stage" shows "Proposal Sent" or later, this is a strong campaign
- If a campaign shows "MQL" or "SAL" as majority stage, leads are earlier in funnel
- Unattributed % should be approximately 29–31% based on current UTM coverage

---

## Exercise 2: MA-02 Model Comparison — Identifying LinkedIn's True Contribution

**Duration**: 15 minutes
**Participants**: Owen Brady opens; Rachel Summers observes
**Dashboard**: MA-02 Multi-Touch Attribution Explore

### Scenario

Rachel Summers suspects that LinkedIn Ads is being under-credited when using last-touch attribution (the HubSpot default). She wants Owen Brady to demonstrate the difference using the Model Comparison view and prepare talking points for the budget review.

### Steps

1. Open the MA-02 Explore in Looker (navigate to Explore → marketing_attribution)
2. From the saved views dropdown, select **"Model Comparison"**
3. Locate the **LinkedIn Ads** row in the results table
4. Note the attribution share % for each model: first_touch, last_touch, linear, time_decay, u_shaped

### Questions to Answer

1. In which model does LinkedIn Ads have the **highest** attribution share?
2. In which model does LinkedIn Ads have the **lowest** attribution share?
3. What is the difference in attribution share between last_touch and u_shaped for LinkedIn Ads?
4. Why does LinkedIn perform better under first_touch and u_shaped compared to last_touch?
5. If you were presenting to the board and had to justify the LinkedIn budget, which model would you use and why?

### Expected Outcomes

- Owen can navigate to saved views and interpret the comparison table
- Owen and Rachel can articulate why LinkedIn's last-touch attribution understates its contribution
- Rachel has talking points for budget review

### Model Comparison Answer Key (approximate)

| Channel | First Touch | Last Touch | Linear | Time Decay | U-Shaped |
|---------|-------------|------------|--------|------------|----------|
| LinkedIn Ads | ~35% | ~18% | ~28% | ~22% | ~32% |
| Google Ads | ~22% | ~38% | ~26% | ~31% | ~25% |
| SDR Outreach | ~8% | ~25% | ~18% | ~28% | ~12% |

*Note: Actual figures will differ — the key insight is LinkedIn's last-touch is lowest, u-shaped is higher.*

### Facilitator Notes

- Explain: LinkedIn generates awareness and initial interest → tends to be first touch
- SDR Outreach and demos are often the last touch before opportunity creation → inflated in last-touch
- U-shaped balances both by weighting the first touch AND the conversion (SAL) touch

---

## Exercise 3: MA-02 Attribution Trend — Q4 2025 vs Q1 2026

**Duration**: 10 minutes
**Participant**: Rachel Summers
**Dashboard**: MA-02 Multi-Touch Attribution Explore

### Scenario

Rachel wants to understand whether the marketing mix has shifted between Q4 2025 and Q1 2026 — specifically whether LinkedIn's share of pipeline attribution has grown following the budget increase in Q1.

### Steps

1. In the MA-02 Explore, select the saved view **"Attribution Share Trend"**
2. The view shows U-shaped attribution by channel over time (monthly)
3. Filter the date range to: **Q4 2025 (Oct–Dec 2025)** through **Q1 2026 (Jan–Mar 2026)**
4. Observe the LinkedIn Ads and Google Ads trend lines

### Questions to Answer

1. Did LinkedIn Ads' attribution share increase in Q1 2026 compared to Q4 2025?
2. If LinkedIn budget increased by 30% in Q1 2026, is the attribution share increase proportionate?
3. Which channel showed the biggest quarter-over-quarter change?
4. Export this chart to CSV using the gear icon → Download → CSV

### Expected Outcomes

- Rachel can use the trend view to track channel mix over time
- Rachel can export data to Google Sheets for board prep

### Facilitator Notes

- Remind Rachel: this is U-shaped attribution — the most appropriate model for board reporting
- If LinkedIn's share increased proportionately with budget, efficiency is flat
- If share increased more than budget increase, efficiency improved (good news for board)

---

## Exercise 4: MA-03 Board Prep — Export Pipeline Chart

**Duration**: 10 minutes
**Participant**: Rachel Summers
**Dashboard**: MA-03 Pipeline Contribution

### Scenario

Rachel needs to prepare a board slide showing marketing's sourced vs. influenced pipeline for Q1 2026. She needs to export the chart from MA-03 as an image.

### Steps

1. Open MA-03 Pipeline Contribution in Looker
2. Verify the default date range shows **Last 12 months**
3. Locate the **Marketing-Sourced vs. Sales-Sourced Pipeline** stacked bar chart
4. Right-click or use the tile kebab menu (⋮) → **Download** → **PNG**
5. Also note the current quarter's **Marketing-Sourced %** figure
6. Locate the **CAC by Quarter** chart and note the Q1 2026 CAC figure

### Questions to Answer

1. What percentage of Q1 2026 closed-won pipeline was marketing-sourced?
2. What is the current customer acquisition cost (CAC)?
3. What is the Marketing-Influenced % (shown in the KPI tile)?
4. Why is Marketing-Influenced always higher than Marketing-Sourced?

### Expected Outcomes

- Rachel can export dashboard tiles as images for board slides
- Rachel understands the distinction between sourced, influenced, and unattributed pipeline
- Rachel has the Q1 2026 figures she needs for board prep

### Answer to Q4 (for facilitator)

Marketing-Influenced includes all deals where marketing touched the contact within 180 days before opportunity creation — even if sales made the first contact. Marketing-Sourced is a subset: only deals where the *very first touch* was a marketing touch (not SDR).

---

## Exercise 5: Niamh Collins — UTM Coverage Review

**Duration**: 5 minutes
**Participant**: Niamh Collins
**Dashboard**: MA-01 Demand Generation Performance

### Scenario

Niamh is responsible for improving UTM coverage from the current ~70% to >90% over the next quarter. She wants to understand which channels have the worst UTM coverage.

### Steps

1. Open MA-01
2. Locate the **UTM Coverage** data quality tile
3. Note the current overall coverage %
4. In the MA-02 Explore, select the saved view **"Channel Overview"**
5. Add a filter: `fct_attribution_touches.utm_source IS NULL` and observe which channels have the most unattributed touches

### Questions to Answer

1. What is the current UTM coverage % overall?
2. Which channel has the most unattributed touches?
3. If you were to fix UTM coverage for just one channel first, which would have the most impact on attribution accuracy?

### Expected Outcomes

- Niamh understands the scale of the UTM gap and its attribution impact
- Niamh can identify which channel to prioritise for UTM enforcement

### Facilitator Notes

- Unattributed touches are expected primarily from direct traffic, email (if not UTM-tagged), and some LinkedIn posts
- Direct/organic tends to be hardest to fix (no UTM enforcement possible)
- Paid media UTMs (Google, LinkedIn, Meta) should be 100% attributable — any gaps here are fixable

---

## Answer Summary

| Exercise | Key Takeaway |
|----------|-------------|
| 1 — MA-01 Date Range | Use 30-day view for monthly reviews; Majority Pipeline Stage identifies campaign maturity |
| 2 — Model Comparison | LinkedIn last-touch ~18% vs U-shaped ~32% — significant understatement |
| 3 — Attribution Trend | U-shaped trend shows true channel mix shift over time; use for board reporting |
| 4 — MA-03 Board Prep | Export tiles as PNG; sourced < influenced because influenced includes sales-sourced deals touched by marketing |
| 5 — UTM Coverage | Prioritise paid media UTM enforcement first; highest impact, fully controllable |
