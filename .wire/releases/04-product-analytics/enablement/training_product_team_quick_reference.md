# Product Analytics — Quick Reference Card
## Core Dynamics Data Platform

---

## Three Dashboards at a Glance

| Dashboard | When to Use | Default Filter | Refresh |
|-----------|------------|---------------|---------|
| **PB-01** Product Adoption Overview | Weekly product reviews; feature prioritisation | Last 30 days | Daily |
| **PB-02** Account-Level Product Usage | CSM account reviews; QBR prep; CS health check | Current month score | Daily |
| **PB-03** Onboarding Funnel Analysis | Weekly CSM standup; stalled account triage | Last 90 days | Daily |

---

## Product Engagement Score (0–100)

| Signal | Weight | How It's Calculated |
|--------|--------|---------------------|
| DAU/MAU Ratio | 20% | Daily active users / monthly active users (30-day window) |
| Feature Breadth | 20% | Distinct features used / total features in taxonomy |
| Core Activation | 20% | % of core features (Work Order, Asset, Reporting) used |
| Work Order Within 30 Days | 10% | Binary: first work order created in first 30 days? |
| Licence Utilisation | 5% | Active users / contracted seats |
| NPS Response | 15% | Most recent NPS score / 10 (within 180 days) |
| Onboarding Completion | 10% | Core steps completed / 5 |

**Score Bands**: At Risk (<40) | Needs Attention (40–59) | Healthy (60–79) | Excellent (≥80)

---

## Onboarding Steps

| Step | ID | Core? | Target Timeline |
|------|----|-------|----------------|
| 1 | Invite Users | ✓ | Day 1–3 |
| 2 | Create First Asset | ✓ | Day 1–7 |
| 3 | Import Asset List | ✓ | Day 3–14 |
| **4** | **Create Work Order** | **✓** | **Day 7–21** ← KEY RETENTION SIGNAL |
| 5 | Configure Report | ✓ | Day 14–30 |
| 6 | Integrate IoT | Optional | Day 30–90 |
| 7 | QBR Ready | Optional | Day 60–90 |

**Stalled** = No progress on a step for >14 days

---

## Feature Taxonomy

```
Module (8 total)
  └── Feature Group (~30 total)
        └── Feature (~200 total)
```

Examples:
- Maintenance Management → Work Order Management → Create Recurring Work Order
- Reporting → Report Builder → Generate Report

---

## Common Questions

**Q: Why is the licence utilisation showing NULL?**
Some older Salesforce contracts don't have the `User_Seats__c` field populated. NULL means "data not available" — not 0%.

**Q: Can I see which individual users are active?**
No — user IDs are pseudonymised (hashed) for privacy compliance. The dashboards show account-level activity only.

**Q: How do I update the feature taxonomy?**
Contact Leon Yip for an updated CSV. He provides it to Sophie Tanner who reloads it into the pipeline.

**Q: When will this feed into the Customer Health dashboard?**
Release 05 (Customer Analytics) — the Product Engagement Score is an input to the customer health score. Planned Q2 2026.

---

## Getting Help

| Need | Contact | How |
|------|---------|-----|
| Data looks wrong | Sophie Tanner | Slack #data-platform-alerts |
| Feature taxonomy update | Leon Yip → Sophie Tanner | Slack direct message |
| Score weight change | Sophie Tanner (requires Claire + Tara sign-off) | Email |
| Dashboard access | Sophie Tanner | Slack direct message |
