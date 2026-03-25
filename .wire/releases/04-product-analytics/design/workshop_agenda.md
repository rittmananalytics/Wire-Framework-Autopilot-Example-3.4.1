# Workshop Agenda — Product Analytics
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**Note**: Workshop materials generated as reference — no workshop conducted in Autopilot mode. Key decisions resolved from supplementary requirements document (04-supplementary-requirements-product-analytics.md) gathered during the discovery session with Claire Ashworth and Leon Yip on 5 February 2026.

---

## Workshop Purpose

Clarify open product analytics requirements, confirm the Product Engagement Score weighting, and agree the feature taxonomy and event sourcing approach before the dbt model build sprint begins.

**Attendees**: Claire Ashworth (VP Product), Leon Yip (Senior PM), Fatima Al-Rashidi (Senior PM), Tara Obinna (VP CS), Sophie Tanner
**Duration**: 90 minutes

---

## Agenda

### Part 1: Feature Taxonomy Confirmation (20 min)
- Walk through the draft `Module → Feature Group → Feature` hierarchy
- Confirm event-to-taxonomy mapping approach
- **Decision A1**: Are all Mixpanel `event_name` values covered in Leon's taxonomy CSV? If not, how should unmapped events be handled?
- **Decision A2**: Should PB-01 heatmap be fixed to Feature Group level, or user-selectable?

### Part 2: Segment vs. Mixpanel Deduplication (20 min)
- Walk through Addition 4 findings from supplementary requirements
- Review the agreed event-to-source mapping table
- **Decision B1**: Confirm Segment as authoritative for `work_order_created` and `asset_created`
- **Decision B2**: How to handle Mixpanel events that lack a Segment equivalent — include all?

### Part 3: Product Engagement Score Weights (25 min)
- Walk through the 7-component revised weighting (from supplementary requirements)
- **Decision C1**: Claire Ashworth confirms 20/20/20/10/5/15/10 weighting
- **Decision C2**: Tara Obinna confirms weighting is acceptable for CS usage
- **Decision C3**: What score threshold defines "at-risk" (for PB-03 alert flag)?

### Part 4: Onboarding Funnel Edge Cases (15 min)
- **Decision D1**: Is Step 6 (IoT integration) in scope? Or should it track as optional?
- **Decision D2**: Definition of "stalled" — is >14 days without progress on a step correct?
- **Decision D3**: Which CSM field in Salesforce to use for CSM book-of-business filter in PB-03?

### Part 5: Licence Utilisation (10 min)
- **Decision E1**: Amara Diallo to confirm `User_Seats__c` field population status
- **Decision E2**: How to surface null licence utilisation in PB-02? Show as "Data pending" or hide tile?

---

## Pre-Resolved Decisions (from Supplementary Requirements)

| ID | Decision | Resolution |
|----|----------|-----------|
| A1 | Feature taxonomy coverage | Leon Yip to provide CSV; unmapped events → `module = 'Other'` |
| B1 | Source for core transactional events | Segment (server-side; confirmed more reliable) |
| B2 | Source for discovery events | Mixpanel (only source available) |
| C1 | Score component weights | Confirmed in supplementary requirements doc |
| D1 | IoT step in scope | Included as optional step; tracked but not required for "core onboarding complete" |
| D2 | Stalled definition | >14 days without progress; flagged in PB-03 |

## Open Decisions (requiring confirmation before build)

| ID | Question | Owner | Impact if delayed |
|----|---------|-------|------------------|
| C2 | Tara Obinna signs off score weights | Tara Obinna | `dim_account_product_score` build blocked |
| C3 | At-risk score threshold | Claire Ashworth | PB-03 alert flag cannot be built |
| D3 | Salesforce CSM field name | Leon Yip / Tara Obinna | PB-03 CSM filter blocked |
| E1 | User_Seats__c population | Amara Diallo | licence_utilisation_pct may have high null rate |
