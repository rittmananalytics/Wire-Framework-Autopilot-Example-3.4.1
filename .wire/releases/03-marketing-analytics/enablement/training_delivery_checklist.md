# Training Delivery Checklist
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Session**: Marketing Analytics End-User Training
**Facilitator**: Sophie Tanner, Rittman Analytics
**Scheduled**: Week 16 (after UAT sign-off)

---

## Pre-Session (3 days before)

### Environment
- [ ] All three dashboards deployed to Looker staging and passing content validation
- [ ] MA-02 Explore saved views configured (all 5 views accessible)
- [ ] Rachel Summers, Owen Brady, Niamh Collins have Looker staging login and Viewer access
- [ ] Greg Fontaine (VP Sales) has Looker staging login (read-only; MA-03 only)
- [ ] Sophie Tanner screen share tested in Zoom/Teams; Looker staging accessible
- [ ] Test account available for demo (or use Sophie's account with test data visible)

### Materials
- [ ] `training_marketing_team_slides.md` exported/ready for presentation
- [ ] `training_marketing_team_quick_reference.md` shared with participants in advance
- [ ] `training_marketing_team_exercises.md` shared with participants (optional — can share after)
- [ ] Calendar invites sent: Rachel Summers, Owen Brady, Niamh Collins (90 min full session)
- [ ] Separate 20-min invite for Greg Fontaine (MA-03 section only)

### Data
- [ ] MA-01 dashboard shows realistic data (at least 7 days of demand gen activity visible)
- [ ] MA-02 Explore contains at least 5 closed-won opportunities with multi-touch journeys
- [ ] MA-03 shows at least 4 complete quarters of pipeline history
- [ ] Example closed-won opportunity prepared for the attribution model comparison demo
- [ ] UTM coverage tile shows a realistic coverage % (not 0% or 100%)

---

## Pre-Session (day before)

- [ ] Send reminder email with Looker staging URL and login instructions
- [ ] Confirm Greg Fontaine is still available for the MA-03 section
- [ ] Confirm Rachel Summers has completed UAT sign-off (required before training)
- [ ] Prepare "real deal" journey example for live demo in MA-02:
  - Pick a closed-won opportunity from the staging data
  - Walk through it under all 5 attribution models
  - Note the LinkedIn vs. SDR credit split for talking points

---

## Session Start

- [ ] Wait for all primary attendees (Rachel Summers, Owen Brady, Niamh Collins) to join
- [ ] Confirm screen share is visible to all participants
- [ ] Open MA-01 in Looker staging before starting (avoid delays during session)
- [ ] Open exercise file for reference during hands-on sections
- [ ] Note start time for pacing (90 minutes total)

---

## During Session

### Part 1 — Introduction and Context (10 min)
- [ ] Overview of three dashboards and their use cases delivered
- [ ] Data sources explained (HubSpot, Salesforce, ad platforms, Outreach)
- [ ] UTM gap (~30%) acknowledged; Niamh's UTM enforcement plan mentioned
- [ ] HubSpot-Salesforce match rate (~88%) acknowledged

### Part 2 — MA-01 (25 min)
- [ ] Default date range (Last 7 days) demonstrated and explained
- [ ] All 5 KPI tiles walked through
- [ ] Period-over-period comparison explained
- [ ] Top 10 campaigns table explained; Majority Pipeline Stage column explained
- [ ] UTM coverage tile demonstrated with tooltip
- [ ] **Hands-on exercise**: Owen Brady completes Exercise 1 (30-day view, top 3 campaigns)

### Part 3 — MA-02 (30 min)
- [ ] Last-touch limitation explained with example journey
- [ ] All 5 attribution models explained (table walkthrough)
- [ ] Live demo: real closed-won opportunity walked through under all 5 models
- [ ] U-shaped explained as recommended default; 180-day window explained
- [ ] All 5 saved views demonstrated
- [ ] How to switch models using the filter dropdown demonstrated
- [ ] How to export to CSV demonstrated
- [ ] **Hands-on exercise**: Owen Brady completes Exercise 2 (Model Comparison — LinkedIn); Rachel completes Exercise 3 (Q4 2025 vs Q1 2026 trend)

### Part 4 — MA-03 (20 min)
- [ ] Greg Fontaine joins (or note if unavailable)
- [ ] Marketing-sourced vs. sales-sourced definition explained
- [ ] Marketing-influenced definition explained (180-day window)
- [ ] CAC by Quarter chart explained
- [ ] LTV:CAC placeholder explained (Release 05, Q3 2026)
- [ ] MA-03 weekly (not daily) refresh cadence noted
- [ ] **Hands-on exercise**: Rachel completes Exercise 4 (export pipeline chart for board slide)

### Part 5 — Getting Help (5 min)
- [ ] Data issue reporting process: Slack #data-platform-alerts
- [ ] Change request process: Jira WAEP with 'enhancement' label
- [ ] Attribution weights / window: dbt variables, require developer to change
- [ ] Contact details confirmed: Sophie Tanner, sophie@rittmananalytics.com

---

## Post-Session (same day)

- [ ] Send `training_marketing_team_quick_reference.md` to all attendees
- [ ] Send `training_marketing_team_exercises.md` with answers for self-study
- [ ] Send Looker production URL (once deployment is complete)
- [ ] Follow up with Rachel Summers on attribution model decision for Q1 board deck
- [ ] Log training session completion in status.md

---

## Post-Session Actions (within 1–2 weeks)

| Action | Owner | Deadline |
|--------|-------|---------|
| Update `form_asset_mapping.csv` seed with real HubSpot form IDs | Niamh Collins | Within 2 weeks of session |
| Set MA-01 as Monday standup start page in Looker | Owen Brady | Within 1 week |
| Confirm attribution model for Q1 board deck | Rachel Summers | Before next board prep cycle |
| Confirm Q1 board slide prepared from MA-03 export | Rachel Summers | Within 2 weeks |

---

## Facilitator Notes

**Common questions to prepare for:**

1. "Why does LinkedIn's share look different in different models?"
   → It's a first-touch and mid-funnel channel; last-touch undercounts it because SDR sequences tend to be the last touch before opportunity creation.

2. "Can we change the attribution window from 180 to 90 days?"
   → Yes, it's a dbt variable but requires a developer (Sophie) to change and redeploy. Confirmed 180 days with Rachel Summers based on ~4-month average enterprise cycle.

3. "Why is the LTV:CAC tile empty?"
   → Placeholder — LTV data comes from ChurnZero and NetSuite, which are in scope for Release 05 (Customer Analytics, Q3 2026).

4. "Can I see individual contact journeys?"
   → Not in the current dashboards — would require a custom Explore query. Log as an enhancement in Jira WAEP.

5. "Why doesn't the pipeline number match what I see in Salesforce?"
   → A small difference is expected: ~12% of HubSpot contacts don't match to a Salesforce contact. Unmatched contacts contribute to attribution touches but not to opportunity pipeline. If the difference is >20%, flag to Sophie.
