# Training Session Plan — Product Analytics
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**Session type**: Product and CS team end-user training
**Duration**: 75 minutes
**Primary audience**: Claire Ashworth (VP Product), Leon Yip (Senior PM), Tara Obinna (VP CS), CSM team
**Secondary**: Fatima Al-Rashidi (Integrations PM — optional)
**Delivered by**: Sophie Tanner, Rittman Analytics
**Format**: Video call with Looker live demo
**Scheduled**: Week 16 (after UAT sign-off)

---

## Learning Objectives

By the end of this session, participants will be able to:
1. Navigate PB-01 to understand feature adoption breadth across the customer base
2. Use PB-02 to drill into a specific account's product usage and score
3. Use PB-03 to identify stalled onboarding accounts for CSM intervention
4. Understand what the Product Engagement Score measures and how it is calculated
5. Know the data sources and limitations (event taxonomy coverage, licence utilisation nulls)

---

## Agenda

### Part 1: Introduction (10 min)
- Three dashboards and their use cases
- Data sources: CoreFM, Segment, Mixpanel, Intercom
- Feature taxonomy: Module → Feature Group → Feature
- PII note: user IDs are hashed — no individual user identification possible
- Known limitations: feature taxonomy may need updating (Leon Yip process)

### Part 2: PB-01 Product Adoption Overview (20 min)
- Feature heatmap: Feature Group default; drill to Feature level
- Module adoption summary: which modules are underutilised
- Filtering by segment and module
- **Hands-on**: Leon Yip identifies the top 3 underutilised feature groups

### Part 3: PB-02 Account-Level Usage (20 min)
- Account selector; score components explained (all 7)
- Work Order Within 30 Days signal: why it matters for retention
- Licence utilisation: what a null means
- Score trend over time
- **Hands-on**: Tara Obinna pulls up a specific at-risk account and notes the lowest-scoring component

### Part 4: PB-03 Onboarding Funnel (20 min)
- Funnel: % completion by step; Step 4 highlighted as key retention signal
- Stalled accounts table: what triggers a stall (>14 days without progress)
- CSM filter: how each CSM sees their book of business
- Drill-through to PB-02
- **Hands-on**: Each CSM filters to their accounts and identifies their top 3 stalled accounts

### Part 5: Getting Help (5 min)
- Data issues → Slack #data-platform-alerts
- Feature taxonomy update process → Leon Yip provides CSV → Sophie Tanner redeploys
- Product Engagement Score recalibration → requires developer + sign-off
- Release 05 (Customer Analytics): score feeds into customer health and BQML churn model

---

## Post-Session Actions

| Action | Owner | Deadline |
|--------|-------|---------|
| Provide final feature_taxonomy.csv with real event names | Leon Yip | Within 2 weeks |
| Confirm User_Seats__c is populated for all active contracts | Amara Diallo | Within 2 weeks |
| Set PB-03 bookmark with CSM filter per CSM | Each CSM | Within 1 week |
| Sign off Product Engagement Score weights (if not already done) | Claire Ashworth, Tara Obinna | Same day |
