# UAT Plan — Product Analytics
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**UAT Lead**: Claire Ashworth (VP Product)
**Supporting**: Leon Yip (feature taxonomy), Tara Obinna (score validation + PB-03)
**Builder**: Sophie Tanner, Rittman Analytics
**Scheduled**: Weeks 15–16

---

## Deliverables Under Test

| ID | Deliverable | Sign-off |
|----|-------------|---------|
| D-12 | Product integration models (3) | Sophie Tanner (internal) |
| D-13 | Product warehouse models (6) | Sophie Tanner + Claire Ashworth |
| D-14 | LookML product semantic layer | Sophie Tanner (internal) |
| D-15 | PB-01: Product Adoption Overview | Claire Ashworth |
| D-16 | PB-02: Account-Level Product Usage | Claire Ashworth + Tara Obinna |
| D-17 | PB-03: Onboarding Funnel Analysis | Tara Obinna |

---

## Test Cases

### TC-P01: PII — No Plain-Text User IDs (CRITICAL — blocks all other UAT)
```sql
SELECT count(*) FROM mart_product.fct_feature_usage
WHERE length(user_pk) != 64 OR regexp_contains(user_pk, r'[^0-9a-f]')
```
**Pass**: Zero rows. Failure blocks all UAT and escalates to Priya Nair.

### TC-P02: Feature Taxonomy Applied
- Verify `SELECT DISTINCT module_name FROM mart_product.fct_feature_usage` returns 7 non-null module names
- Verify `module_id = 'mod_999'` (unmapped) is < 10% of rows
- **Tester**: Leon Yip — validate module names match CoreFM taxonomy

### TC-P03: All 5 Core Models Present and Non-Empty
```sql
SELECT 'fct_feature_usage', COUNT(*) FROM mart_product.fct_feature_usage
UNION ALL SELECT 'fct_session_events', COUNT(*) FROM mart_product.fct_session_events
UNION ALL SELECT 'fct_onboarding_funnel', COUNT(*) FROM mart_product.fct_onboarding_funnel
UNION ALL SELECT 'dim_account', COUNT(*) FROM mart_product.dim_account
UNION ALL SELECT 'dim_account_product_score', COUNT(*) FROM mart_product.dim_account_product_score
```
**Pass**: All 5 models have rows

### TC-P04: Product Engagement Score Range
```sql
SELECT MIN(product_engagement_score), MAX(product_engagement_score)
FROM mart_product.dim_account_product_score
```
**Pass**: Min ≥ 0, Max ≤ 100

### TC-P05: Work Order Within 30 Days Signal
- Tara Obinna: identify 3 accounts known to have created a work order early
- Query: `SELECT account_pk, work_order_within_30_days FROM mart_product.dim_account_product_score WHERE score_month = date_trunc(current_date(), month)`
- **Pass**: The 3 known accounts show `work_order_within_30_days = TRUE`

### TC-P06: Onboarding Steps — 7 per Account
```sql
SELECT account_pk, COUNT(*) FROM mart_product.fct_onboarding_funnel GROUP BY 1 HAVING COUNT(*) != 7
```
**Pass**: Zero rows returned

### TC-P07: PB-01 Loads Within 5 Seconds (Default View)
- Open PB-01 with default filters (last 30 days, all modules, all segments)
- **Pass**: Fully loaded ≤ 5 seconds

### TC-P08: PB-01 Heatmap Drill-Through
- Open PB-01; click a Feature Group row in the heatmap
- **Pass**: Heatmap expands to Feature level for that group

### TC-P09: PB-02 Account Score Components
- Open PB-02; select a known account (e.g., one with high usage)
- **Pass**: All 7 score components visible; score matches business expectation per Claire Ashworth

### TC-P10: PB-02 Licence Utilisation Null Handling
- Open PB-02 for an account known to have null `User_Seats__c` in Salesforce
- **Pass**: Licence utilisation shows "Data not available" tooltip, not 0%

### TC-P11: PB-03 Stalled Accounts
- Open PB-03; filter by CSM = Tara Obinna's CSM team
- **Pass**: Stalled accounts table shows accounts with is_stalled=TRUE; clicking a row opens PB-02

### TC-P12: PB-03 Step 4 Highlight
- **Pass**: Step 4 (Create Work Order) is visually highlighted in the funnel as "Key Step"

---

## Sign-Off Template

```
PRODUCT ANALYTICS RELEASE — UAT SIGN-OFF
Release: 04-product-analytics

☐ D-12/13: Product warehouse models — data quality and business logic verified
☐ D-14: LookML semantic layer — content validation passing
☐ D-15: PB-01 Product Adoption Overview — heatmap functional; drill-through works
☐ D-16: PB-02 Account-Level Usage — score components correct; ≤5s load time
☐ D-17: PB-03 Onboarding Funnel — stalled accounts accurate; CSM filter works

Primary Sign-off: Claire Ashworth, VP Product | Signature: _____ | Date: _____
Secondary Sign-off (PB-03): Tara Obinna, VP CS | Signature: _____ | Date: _____
Builder: Sophie Tanner, Rittman Analytics | Signature: _____ | Date: _____
```
