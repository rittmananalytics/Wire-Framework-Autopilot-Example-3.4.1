# Workshop Agenda — Customer Analytics
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Purpose**: Clarify open questions before delivery sprint begins
**Duration**: 2 hours
**Participants**: Tara Obinna (VP CS), David Park (CFO), Amara Diallo (RevOps), Greg Ellison (Head of BI), Sophie Tanner (Rittman Analytics)
**Format**: Video call with screen share

---

## Part 1: NRR/GRR Methodology Alignment (40 min)

### Questions to Resolve
1. **NRR formula**: Confirm the organisation's definition of NRR — specifically how seat upgrades and cross-sells are classified (expansion vs. new ARR)
2. **Churn recognition date**: Is churn recognised at contract end date or at the point a non-renewal decision is recorded in Salesforce?
3. **Multi-year contracts**: How are multi-year deals annualised in ARR calculations?
4. **Revenue discrepancy root cause**: What does the 8% Finance vs CS MRR discrepancy relate to — timing, scope, or classification differences?
5. **Financial metric access**: Confirm which roles need access to ARR/NRR fields in Looker (David Park to specify)

### Expected Outcome
- Agreed NRR/GRR calculation methodology documented
- David Park sign-off on definition before build begins
- List of Salesforce fields to use for each ARR movement type

---

## Part 2: Customer Health Score Design (35 min)

### Questions to Resolve
1. **Signal weights**: Tara Obinna + Claire Ashworth to confirm default weights (product 30%, support 20%, financial 25%, relationship 15%, NPS 10%) or propose alternatives
2. **Support health definition**: Which Zendesk metrics constitute "good" support health — ticket volume, resolution time, CSAT, or composite?
3. **Relationship health signals**: What constitutes a healthy relationship — executive sponsor identified? QBR completed in last 180 days? Open escalations?
4. **Score frequency**: Daily is planned — is this sufficient or is near-real-time needed for critical accounts?
5. **ChurnZero overlap**: ChurnZero has its own health score. How should we handle the two scores — replace, supplement, or feed ChurnZero?

### Expected Outcome
- Agreed signal weights (documented in dbt vars)
- Definition of "support health" and "relationship health" signals
- Decision on ChurnZero relationship

---

## Part 3: BQML Churn Model Scope (25 min)

### Questions to Resolve
1. **Churn definition**: Binary churn vs. contraction — should the model predict full churn only, or any ARR loss event?
2. **Training window**: Confirm 24-month window acceptable given ChurnZero 14-month limitation (proxy approach)
3. **Feature approval**: Walk through planned features — any proprietary or sensitive features to exclude?
4. **Threshold decision**: Who approves the churn_risk_band thresholds (Low/Medium/High/Critical) — Tara Obinna, or joint decision with Marcus Webb?
5. **Fallback position**: If AUC-ROC < 0.75, confirm rule-based fallback (health score < 40 + renewal < 90 days) is acceptable

### Expected Outcome
- Confirmed churn definition (binary full churn vs. any loss event)
- Risk threshold owners confirmed
- Fallback plan agreed

---

## Part 4: CSM Book of Business & Looker Configuration (15 min)

### Questions to Resolve
1. **CSM owner field**: Confirm Salesforce field used for CSM assignment (`Owner.Name` or custom `CSM_Owner__c`)
2. **User attributes**: Greg Ellison to confirm Looker user attribute provisioning timeline
3. **Looker Actions**: Confirm Salesforce task creation action is approved (requires Salesforce API connection in Looker)
4. **QBR template**: Does a Google Slides QBR template exist, or does one need to be created?

### Expected Outcome
- CSM owner field confirmed
- Looker infrastructure plan (user attributes, groups) agreed with Greg Ellison
- QBR template decision

---

## Decision Matrix

| Topic | Options | Decision | Owner | Deadline |
|-------|---------|----------|-------|----------|
| NRR expansion classification | Include seat upgrades / Exclude cross-sells | TBD | David Park | Before data model build |
| Churn recognition date | Contract end vs. non-renewal recorded | TBD | David Park + Amara Diallo | Before data model build |
| Health score weights | 30/20/25/15/10 as proposed / Alternative | TBD | Tara Obinna + Claire Ashworth | Before data model build |
| Support health metric | CSAT only / Composite (CSAT + resolution time + volume) | TBD | Tara Obinna | Before data model build |
| ChurnZero relationship | Replace / Supplement / Feed | TBD | Tara Obinna | Before build |
| BQML churn definition | Full churn only / Any ARR loss | TBD | Tara Obinna | Before BQML training |
| Financial metric access | Finance + leadership / Broader | TBD | David Park | Before Looker build |
