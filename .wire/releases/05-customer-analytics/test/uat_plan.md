# UAT Plan — Customer Analytics
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**UAT Environment**: Looker staging (core-dynamics-analytics-staging)
**UAT Window**: Sprint 10 (Week 19)
**Sign-off required**: Tara Obinna (all), David Park (NRR/GRR only), CSM team (CA-02)

---

## Test Cases

### TC-C01: Row-Level Security — CSM Can Only See Own Accounts
**Dashboard**: CA-02
**Tester**: Sarah Patel (CSM) + Karen Osei (CSM) — independently
**Priority**: Critical (security)
**Steps**:
1. Sarah Patel logs in to Looker staging with her credentials
2. Opens CA-02 CSM Book of Business
3. Verifies that all accounts listed have csm_owner = "Sarah Patel"
4. Karen Osei repeats, verifying all accounts = "Karen Osei"
5. Sophie Tanner logs in as Tara Obinna — verifies all 312 accounts visible with CSM filter
**Pass Criteria**: No CSM sees another CSM's accounts. Tara Obinna sees all accounts.
**Fail Action**: Block deployment — immediate RLS misconfiguration fix required

### TC-C02: Health Score Reasonableness
**Dashboard**: CA-01
**Tester**: Tara Obinna
**Priority**: High
**Steps**:
1. Open CA-01 Customer Health Command Centre
2. Select 5 accounts Tara knows well — 2 healthy, 2 at-risk, 1 borderline
3. Compare health scores with Tara's subjective assessment of each account
4. Check that "At Risk" accounts match known problem accounts
**Pass Criteria**: Health bands match Tara's assessment for ≥4 of 5 accounts
**Fail Action**: Investigate signal weights; recalibrate if systematic misalignment

### TC-C03: BQML Churn Risk Reasonableness
**Dashboard**: CA-01 + CA-02
**Tester**: Tara Obinna
**Priority**: High
**Steps**:
1. Find 3 accounts that recently churned in ChurnZero
2. Verify they appear as Critical or High churn risk in the dashboards
3. Find 3 accounts with recent QBRs and high engagement
4. Verify they appear as Low churn risk
**Pass Criteria**: ≥5 of 6 assessments correct directionally
**Fail Action**: Review model features; consider fallback to rule-based risk if AUC-ROC < 0.75

### TC-C04: NRR/GRR Reconciliation
**Dashboard**: CA-03
**Tester**: David Park (CFO)
**Priority**: Critical (financial accuracy)
**Steps**:
1. David Park opens CA-03 CS Leadership Scorecard
2. Notes the Trailing 12M NRR figure
3. Compares against Finance's own NRR calculation for the same period
4. Acceptable variance: ±2 percentage points
**Pass Criteria**: NRR within 2pp of Finance reference number
**Fail Action**: Block deployment of CA-03; investigate methodology discrepancy with Amara Diallo

### TC-C05: Financial Metrics Access Control
**Dashboard**: CA-03
**Tester**: Sophie Tanner (as CSM user, then as finance_viewer)
**Priority**: High (compliance)
**Steps**:
1. Log in as a CSM (non-finance user)
2. Open CA-03 — verify ARR, NRR, GRR tiles are NOT visible
3. Log in as David Park (finance_viewers group)
4. Open CA-03 — verify all financial metrics are visible
**Pass Criteria**: Financial metrics hidden for CSMs; visible for finance_viewers
**Fail Action**: Fix Looker group/access grant configuration; retest before deployment

### TC-C06: Renewal Pipeline — Days to Renewal Accuracy
**Dashboard**: CA-01, CA-02
**Tester**: Amara Diallo (RevOps)
**Priority**: Medium
**Steps**:
1. Open renewal pipeline on CA-01
2. Select 5 accounts with known renewal dates from Salesforce
3. Compare days_to_renewal in the dashboard vs manual calculation from Salesforce
**Pass Criteria**: Days_to_renewal within 1 day of Salesforce for all 5 accounts
**Fail Action**: Debug Salesforce opportunity query; check close_date field mapping

### TC-C07: Looker Action — Flag for CSM Follow-up
**Dashboard**: CA-02
**Tester**: Sophie Tanner (with Salesforce access)
**Priority**: Medium
**Steps**:
1. In CA-02, select an at-risk account
2. Click "Flag for CSM Follow-up" Looker Action
3. Verify a Salesforce Task is created for the CSM owner with correct account name and due date
**Pass Criteria**: Salesforce Task created with correct account, assigned to correct CSM, due date = today+7
**Fail Action**: Debug Looker Action → Salesforce API configuration

### TC-C08: Expansion Signals Accuracy
**Dashboard**: CA-01
**Tester**: Leon Yip (Sr. PM, product knowledge)
**Priority**: Medium
**Steps**:
1. Open expansion signals section of CA-01
2. Review 5 flagged accounts
3. Leon Yip verifies that feature_breadth and licence_utilisation figures match his product knowledge
**Pass Criteria**: Signal criteria match product data for ≥4 of 5 accounts
**Fail Action**: Debug product score cross-release join

### TC-C09: Dashboard Performance
**Dashboard**: CA-01, CA-02, CA-03
**Tester**: Sophie Tanner
**Priority**: Medium
**Steps**:
1. Load CA-01 with default filters — record load time
2. Load CA-02 with Sarah Patel's credentials — record load time
3. Load CA-03 with all filters cleared — record load time
**Pass Criteria**: CA-01 ≤5s, CA-02 ≤3s (RLS), CA-03 ≤5s
**Fail Action**: Investigate query performance; check BQ partition/cluster usage

### TC-C10: Scheduled Alert — At-Risk Account Notification
**Tester**: Sophie Tanner (test Slack account)
**Priority**: Medium
**Steps**:
1. Configure test Looker Scheduled Alert for at-risk accounts
2. Manually trigger the alert
3. Verify Slack DM received with correct account(s) listed
**Pass Criteria**: Slack message received within 5 minutes of trigger with correct content
**Fail Action**: Debug Looker Scheduled Alerts → Slack integration

---

## Sign-off Template

| Role | Name | Scope | Signature | Date |
|------|------|-------|-----------|------|
| VP Customer Success | Tara Obinna | All dashboards, health score, churn risk | _______________ | ________ |
| CFO | David Park | CA-03 NRR/GRR only | _______________ | ________ |
| RevOps | Amara Diallo | Renewal pipeline accuracy | _______________ | ________ |
| CSM (representative) | Sarah Patel | CA-02 RLS + usability | _______________ | ________ |

**Deployment blocked** until Tara Obinna and David Park have signed. TC-C01 (RLS) must pass before any UAT proceeds.

---

## Post-UAT Actions

| Action | Owner | Deadline |
|--------|-------|----------|
| Backfill renewal dates in Salesforce | Amara Diallo | 1 week before deployment |
| Provision Looker user attributes (csm_owner per CSM) | Greg Ellison | 2 days before UAT |
| Create finance_viewers + leadership Looker groups | Greg Ellison | 2 days before UAT |
| Confirm NRR methodology in writing | David Park | Before TC-C04 |
| Connect Looker → Salesforce API for Action | Greg Ellison + Sophie Tanner | 1 week before UAT |
