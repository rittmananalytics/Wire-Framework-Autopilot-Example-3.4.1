# Deployment Runbook — Customer Analytics
## Release: 05-customer-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Target**: core-dynamics-analytics-prod
**Dependencies**: 02, 03, and 04 deployed and passing; `mart_product` dataset accessible
**Sign-off required**: Tara Obinna (UAT) + David Park (NRR/GRR) before prod deployment

---

## Pre-Deployment Checklist

- [ ] UAT complete: Tara Obinna has signed UAT sign-off
- [ ] David Park has signed off NRR/GRR methodology and TC-C04 passed
- [ ] TC-C01 (RLS check) passed in staging — mandatory before any deployment
- [ ] `dbt test --select tag:warehouse_customer` 100% pass in dev
- [ ] Looker user attributes provisioned by Greg Ellison (`csm_owner` per CSM)
- [ ] `finance_viewers` and `leadership` Looker groups created
- [ ] BQML training completed in dev environment (AUC-ROC ≥ 0.75 confirmed)
- [ ] `ml_models` BigQuery dataset created in prod with correct IAM
- [ ] `mart_customer` BigQuery dataset created in prod
- [ ] Salesforce → Looker API connection configured for Looker Actions
- [ ] Renewal dates backfilled by Amara Diallo
- [ ] Rollback plan reviewed

---

## Deployment Steps

### Step 1: Create BigQuery Datasets

```bash
# Create mart_customer dataset
bq mk --location=us-central1 --dataset core-dynamics-analytics-prod:mart_customer

# Create ml_models dataset (restricted IAM)
bq mk --location=us-central1 --dataset core-dynamics-analytics-prod:ml_models

# Grant dbt service account access
bq add-iam-policy-binding \
  --member=serviceAccount:dbt-sa@core-dynamics-analytics-prod.iam.gserviceaccount.com \
  --role=roles/bigquery.dataEditor \
  core-dynamics-analytics-prod:mart_customer

bq add-iam-policy-binding \
  --member=serviceAccount:dbt-sa@core-dynamics-analytics-prod.iam.gserviceaccount.com \
  --role=roles/bigquery.dataEditor \
  core-dynamics-analytics-prod:ml_models
```

### Step 2: Deploy Integration (Customer) Models

```bash
cd dbt
dbt run --select tag:intermediate_customer --target prod
dbt test --select tag:intermediate_customer --target prod

# Verify row counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'int__account_health' as model, COUNT(*) FROM intermediate.int__account_health
   UNION ALL SELECT 'int__renewal_pipeline', COUNT(*) FROM intermediate.int__renewal_pipeline
   UNION ALL SELECT 'int__csm_book', COUNT(*) FROM intermediate.int__csm_book"
```

### Step 3: Run Warehouse (Customer) Models

```bash
dbt run --select tag:warehouse_customer --target prod
dbt test --select tag:warehouse_customer --target prod

# Verify counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'dim_account_health' as model, COUNT(*) FROM mart_customer.dim_account_health
   UNION ALL SELECT 'fct_renewal_pipeline', COUNT(*) FROM mart_customer.fct_renewal_pipeline
   UNION ALL SELECT 'fct_csm_book_of_business', COUNT(*) FROM mart_customer.fct_csm_book_of_business
   UNION ALL SELECT 'fct_nrr_grr', COUNT(*) FROM mart_customer.fct_nrr_grr
   UNION ALL SELECT 'fct_churn_events', COUNT(*) FROM mart_customer.fct_churn_events
   UNION ALL SELECT 'fct_expansion_signals', COUNT(*) FROM mart_customer.fct_expansion_signals"
```

### Step 4: Train BQML Churn Model (Initial Training)

```bash
# Run BQML training directly in BigQuery (first run; subsequent runs via Cloud Composer)
bq query --project_id=core-dynamics-analytics-prod --location=us-central1 \
  --use_legacy_sql=false \
  "CREATE OR REPLACE MODEL ml_models.customer_churn_logistic_reg
   OPTIONS (model_type='logistic_reg', input_label_cols=['is_churned'],
            data_split_method='random', data_split_eval_fraction=0.2)
   AS SELECT health_score, product_component, support_component, financial_component,
             relationship_component, nps_component, is_churned
   FROM ml_models.customer_churn_training_set"

# Evaluate model — verify AUC-ROC ≥ 0.75
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT roc_auc FROM ML.EVALUATE(MODEL ml_models.customer_churn_logistic_reg)"
```

**STOP**: If AUC-ROC < 0.75, do not proceed to Looker deployment. Activate fallback rule-based risk banding.

### Step 5: Run BQML Daily Inference (First Run)

```bash
bq query --project_id=core-dynamics-analytics-prod --location=us-central1 \
  --use_legacy_sql=false \
  "CREATE OR REPLACE TABLE ml_models.customer_churn_predictions AS
   SELECT account_pk, CURRENT_DATE() AS prediction_date,
     predicted_is_churned_probs[OFFSET(1)].prob AS churn_probability,
     CASE WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.65 THEN 'Critical'
          WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.40 THEN 'High'
          WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.20 THEN 'Medium'
          ELSE 'Low' END AS churn_risk_band
   FROM ML.PREDICT(MODEL ml_models.customer_churn_logistic_reg,
     TABLE mart_customer.dim_account_health)
   WHERE score_date = CURRENT_DATE() - 1"
```

### Step 6: Update Cloud Composer DAG

```bash
COMPOSER_BUCKET=$(gcloud composer environments describe core-dynamics-composer \
  --location=us-central1 --project=core-dynamics-analytics-prod \
  --format="value(config.dagGcsPrefix)")

# Replace DAG (now includes marketing + product in parallel, customer phase sequential after product)
gsutil cp .wire/releases/05-customer-analytics/dev/pipeline/dataform_run_dag_customer_extension.py \
  ${COMPOSER_BUCKET}/dags/dataform_run_dag.py

# Wait 2–3 min, then verify in Airflow UI:
# - run_intermediate_customer_models task is present
# - run_warehouse_customer_models task is present
# - bqml_branch, bqml_train_churn_model, bqml_predict_churn tasks are present
# - Customer phase runs AFTER product phase (not in parallel)
```

### Step 7: Run Dataform Assertions

```bash
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=data_quality_customer
```

**Critical**: Verify DQ-C01 (account coverage) and DQ-C04 (NRR reconciliation) PASS before Looker deployment.

### Step 8: Deploy LookML to Looker Production

```bash
# Copy customer views
cp .wire/releases/05-customer-analytics/dev/semantic_layer/views/customer/*.lkml \
   [LOOKER_GITHUB_REPO]/views/customer/

# Copy customer model
cp .wire/releases/05-customer-analytics/dev/semantic_layer/customer.model.lkml \
   [LOOKER_GITHUB_REPO]/customer.model.lkml

cd [LOOKER_GITHUB_REPO]
git add views/customer/ customer.model.lkml
git commit -m "05-customer-analytics: add customer views, explores, RLS"
git push origin main
```

**Validate in Looker**:
- LookML validation passes (0 errors)
- `csm_book_of_business` explore has `sql_always_where` with RLS filter applied
- `fct_nrr_grr.total_arr_usd` shows `required_access_grants`

### Step 9: Deploy Dashboards

```bash
cp .wire/releases/05-customer-analytics/dev/dashboards/*.dashboard.lkml \
   [LOOKER_GITHUB_REPO]/dashboards/
cd [LOOKER_GITHUB_REPO]
git add dashboards/
git commit -m "05-customer-analytics: add CA-01, CA-02, CA-03 dashboards"
git push origin main
```

Configure access:
- **CA-01**: Tara Obinna, all CSMs, Marcus Webb, Claire Ashworth
- **CA-02**: All CSMs, Tara Obinna (with `is_leadership=true` user attribute)
- **CA-03**: Tara Obinna, David Park, Marcus Webb (finance_viewers + leadership groups)

Configure Looker user attributes per CSM:
```
Greg Ellison to set in Looker Admin → User Attributes:
  - csm_owner: "Sarah Patel" for user sarah.patel@coredynamics.io
  - csm_owner: "Karen Osei" for user karen.osei@coredynamics.io
  - (repeat for all 6 CSMs)
  - is_leadership: "true" for Tara Obinna, Marcus Webb
```

### Step 10: Configure Looker Scheduled Alerts

In Looker → Admin → Alerts:
1. **At-risk account alert** — daily, filter: `is_at_risk = Yes AND score_trend_7d = declining`, destination: Slack CSM channel
2. **Weekly health digest** — Monday 08:00 UTC, CA-01 snapshot, destination: #cs-team
3. **Renewal at-risk alert** — daily, filter: `is_at_risk = Yes AND days_to_renewal <= 90`, destination: #revenue-ops
4. **NRR weekly summary** — Monday 08:00 UTC, CA-03 NRR tile, destination: #cs-leadership

### Step 11: End-to-End Validation

```bash
# Trigger full pipeline run
# Airflow UI: trigger dataform_run_dag manually
# Confirm all phases complete including customer and BQML phases

# Verify CA-01 loads within 5 seconds
# Verify CA-02 shows only Sarah Patel's accounts when logged in as Sarah Patel
# Verify CA-03 NRR tiles visible to David Park; hidden from CSM user
# Trigger one Looker Action and verify Salesforce Task creation
```

---

## Post-Deployment Checklist

- [ ] All 6 customer warehouse models have rows in `mart_customer`
- [ ] BQML model trained with AUC-ROC ≥ 0.75 (or fallback activated and documented)
- [ ] DQ assertions passing (DQ-C01 account coverage, DQ-C04 NRR reconciliation)
- [ ] CA-01 loads within 5 seconds
- [ ] CA-02 RLS verified — CSMs only see own accounts
- [ ] CA-03 financial metrics visible to finance_viewers; hidden from CSMs
- [ ] Cloud Composer shows customer phase running after product phase
- [ ] Looker Scheduled Alerts configured and test alerts sent
- [ ] Looker Action verified (Salesforce Task creation)
- [ ] Tara Obinna verifies dashboards in prod and signs off
- [ ] Slack alert sent to #data-platform-alerts: "Customer Analytics (05) deployed"

---

## Rollback Procedure

### Step 1: Revert DAG to product-only version

```bash
gsutil cp .wire/releases/04-product-analytics/dev/pipeline/dataform_run_dag_product_extension.py \
  ${COMPOSER_BUCKET}/dags/dataform_run_dag.py
```

### Step 2: Drop customer warehouse tables (if data incorrect)

```bash
bq rm -f core-dynamics-analytics-prod:mart_customer.dim_account_health
bq rm -f core-dynamics-analytics-prod:mart_customer.fct_renewal_pipeline
bq rm -f core-dynamics-analytics-prod:mart_customer.fct_csm_book_of_business
bq rm -f core-dynamics-analytics-prod:mart_customer.fct_nrr_grr
bq rm -f core-dynamics-analytics-prod:mart_customer.fct_churn_events
bq rm -f core-dynamics-analytics-prod:mart_customer.fct_expansion_signals
bq rm -f core-dynamics-analytics-prod:ml_models.customer_churn_predictions
```

### Step 3: Revert LookML

```bash
cd [LOOKER_GITHUB_REPO]
git revert HEAD~1 HEAD~2  # Reverts the two customer LookML commits
git push origin main
```
