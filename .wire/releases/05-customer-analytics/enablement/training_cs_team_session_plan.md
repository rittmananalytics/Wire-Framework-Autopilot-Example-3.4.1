# Training Session Plan — Customer Analytics (CS Team)
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Session type**: CS Team end-user training (CA-02 focused)
**Duration**: 75 minutes
**Primary audience**: All 6 CSMs, Tara Obinna (VP CS)
**Secondary**: Amara Diallo (RevOps — renewal pipeline)
**Delivered by**: Sophie Tanner, Rittman Analytics
**Format**: Video call with Looker live demo
**Scheduled**: Week 19 (after UAT sign-off)

---

## Learning Objectives

By the end of this session, participants will be able to:
1. Navigate CA-02 to view their book of business and understand health scores
2. Interpret the Customer Health Score and its 5 signal components
3. Identify at-risk accounts and prioritise using churn risk bands
4. Use the "Flag for CSM Follow-up" Looker Action to create Salesforce tasks
5. Understand what the stalled onboarding section means and how to act on it
6. Understand data limitations (NULL churn probability, NULL NRR, renewal date coverage)

---

## Agenda

### Part 1: Introduction (10 min)
- How this replaces the weekly spreadsheet process
- Three dashboards overview: CA-01 (portfolio), CA-02 (your accounts), CA-03 (leadership)
- Data sources: Salesforce, Zendesk, Intercom, BigQuery ML
- Privacy: no individual user IDs; account-level only
- Row-level security: you see only your accounts; Tara sees all

### Part 2: CA-02 CSM Book of Business (30 min)
- Book overview: KPI tiles (your accounts, at-risk, renewals <90 days)
- Health Score: what the 5 components mean
- Churn risk bands: Low/Medium/High/Critical and what action to take per band
- Score trend: what a 7-day decline means
- Account detail view: health trend, score component breakdown
- Renewal context: days to renewal + health score combination for prioritisation
- **Hands-on**: Each CSM filters to their accounts, identifies their #1 at-risk account and notes the lowest health signal

### Part 3: Action Items and Stalled Onboarding (15 min)
- Open actions table: open tickets, overdue onboarding steps, NPS follow-ups
- Stalled onboarding: cross-reference with PB-03 from Release 04
- **Hands-on**: Each CSM identifies one account with stalled onboarding and uses "Flag for CSM Follow-up" action

### Part 4: Expansion Signals (10 min)
- What triggers an expansion signal: high feature breadth + low licence utilisation
- Upsell opportunity signals from Salesforce
- How to use expansion signals in QBR prep

### Part 5: QBR Prep and Getting Help (10 min)
- "Export QBR Data" Looker Action → Google Slides template walkthrough
- Data issues → Slack #data-platform-alerts
- Score recalibration requests → Tara Obinna + Sophie Tanner
- Renewal date issues → Amara Diallo

---

## Post-Session Actions

| Action | Owner | Deadline |
|--------|-------|----------|
| Set CA-02 as Looker homepage bookmark | Each CSM | Within 1 week |
| Identify top 3 at-risk accounts and create Salesforce tasks | Each CSM | Within 2 weeks |
| Review expansion signals list for upsell opportunities | Each CSM | Within 2 weeks |
| Confirm CSM owner field is correct in Salesforce for all accounts | Amara Diallo | Within 2 weeks |
