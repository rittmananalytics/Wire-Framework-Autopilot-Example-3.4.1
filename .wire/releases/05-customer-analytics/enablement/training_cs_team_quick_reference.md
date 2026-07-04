# Customer Analytics — Quick Reference Card
## Core Dynamics Data Platform

---

## Three Dashboards at a Glance

| Dashboard | When to Use | Default Filter | Refresh |
|-----------|------------|---------------|---------|
| **CA-01** Customer Health Command Centre | Weekly team review; portfolio health overview | All CSMs, last 7 days | Daily |
| **CA-02** CSM Book of Business | Daily CSM workflow; QBR prep; account prioritisation | Your accounts (auto-applied) | Daily |
| **CA-03** CS Leadership Scorecard | NRR/GRR review; leadership reporting | Last 12 months | Daily |

---

## Customer Health Score (0–100)

| Signal | Weight | How It's Calculated |
|--------|--------|---------------------|
| Product Engagement | 30% | From Release 04 Product Engagement Score |
| Financial Health | 25% | ARR stability + renewal proximity |
| Support Health | 20% | CSAT (50%) + resolution time (30%) + volume (20%) |
| Relationship | 15% | QBR recency + exec sponsor + open escalations |
| NPS | 10% | Most recent NPS score within 180 days |

**Score Bands**: At Risk (<40) | Needs Attention (40–59) | Healthy (60–79) | Excellent (≥80)

---

## Churn Risk Bands (from BigQuery ML Model)

| Band | Probability | Recommended Action |
|------|-------------|-------------------|
| Low | < 20% | Standard quarterly check-in |
| Medium | 20–40% | Monthly touch-point; review health signals |
| High | 40–65% | Weekly outreach; escalate to Tara Obinna |
| Critical | ≥ 65% | Immediate executive escalation; recovery plan |

---

## Looker Actions (CA-02)

| Action | How to Use | Result |
|--------|-----------|--------|
| Flag for CSM Follow-up | Click button in account list row | Creates Salesforce Task, assigned to you, due in 7 days |
| Export QBR Data | Click in account detail view | Exports health data to Google Slides QBR template |

---

## Common Questions

**Q: Why can't I see NRR or ARR figures?**
These are financial metrics restricted to Finance and CS leadership. Your dashboards show health scores and churn risk, not revenue figures.

**Q: Why does my account show NULL churn probability?**
The BigQuery ML model needs 30+ days of history to generate a prediction. New accounts in their first month won't have a churn probability.

**Q: Why is my account marked At Risk but I know they're happy?**
The health score is data-driven and may lag a recent positive conversation. Check which component is lowest (product, support, financial, relationship, or NPS) and whether it reflects a real data gap. Contact Sophie Tanner to investigate.

**Q: How do I update the feature taxonomy used in the product signal?**
Contact Leon Yip → Sophie Tanner process (same as Release 04).

**Q: The renewal date looks wrong for one of my accounts.**
Contact Amara Diallo to update in Salesforce. Dashboard pulls renewal dates from Salesforce opportunities.

---

## Getting Help

| Need | Contact | How |
|------|---------|-----|
| Data looks wrong | Sophie Tanner | Slack #data-platform-alerts |
| Score weight change | Tara Obinna + Sophie Tanner | Email |
| User attribute / access issue | Greg Ellison | Slack direct message |
| Renewal date correction | Amara Diallo | Salesforce update |
| Looker Action not working | Sophie Tanner | Slack direct message |
