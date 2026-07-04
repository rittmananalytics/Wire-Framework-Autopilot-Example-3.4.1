# Deployment Runbook — Product Analytics
## Release: 04-product-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Target**: core-dynamics-analytics-prod
**Dependency**: 02-data-foundation and 03-marketing-analytics deployed and passing
**Sign-off required**: Claire Ashworth (UAT) + Tara Obinna (PB-03) before prod deployment

---

## Pre-Deployment Checklist

- [ ] UAT complete: Claire Ashworth has signed UAT sign-off
- [ ] Tara Obinna sign-off: PB-03 approved
- [ ] TC-P01 (PII check) PASSED in dev — mandatory before any deployment
- [ ] `dbt test --select tag:warehouse_product` 100% pass in dev
- [ ] Looker staging content validation: 0 errors for product views
- [ ] `feature_taxonomy.csv` provided by Leon Yip (or placeholder accepted)
- [ ] Product Engagement Score weights confirmed by Claire Ashworth and Tara Obinna
- [ ] `User_Seats__c` null handling confirmed by Amara Diallo
- [ ] Rollback plan reviewed

---

## Deployment Steps

### Step 1: Deploy Updated Seeds

```bash
cd dbt
dbt seed --select feature_taxonomy onboarding_steps product_health_thresholds \
  --target prod
```

### Step 2: Run Integration (Product) Models

```bash
dbt run --select tag:intermediate_product --target prod
dbt test --select tag:intermediate_product --target prod

# Verify row counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'int__feature_usage' as model, COUNT(*) FROM intermediate.int__feature_usage
   UNION ALL SELECT 'int__account_sessions', COUNT(*) FROM intermediate.int__account_sessions
   UNION ALL SELECT 'int__onboarding', COUNT(*) FROM intermediate.int__onboarding"
```

### Step 3: Run Warehouse (Product) Models

```bash
dbt run --select tag:warehouse_product --target prod
dbt test --select tag:warehouse_product --target prod

# Verify counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'fct_feature_usage' as model, COUNT(*) FROM mart_product.fct_feature_usage
   UNION ALL SELECT 'fct_session_events', COUNT(*) FROM mart_product.fct_session_events
   UNION ALL SELECT 'fct_onboarding_funnel', COUNT(*) FROM mart_product.fct_onboarding_funnel
   UNION ALL SELECT 'dim_account', COUNT(*) FROM mart_product.dim_account
   UNION ALL SELECT 'dim_account_product_score', COUNT(*) FROM mart_product.dim_account_product_score"
```

### Step 4: Update Cloud Composer DAG

```bash
COMPOSER_BUCKET=$(gcloud composer environments describe core-dynamics-composer \
  --location=us-central1 --project=core-dynamics-analytics-prod \
  --format="value(config.dagGcsPrefix)")

# Replace the DAG file (now includes both marketing and product phases in parallel)
gsutil cp .wire/releases/04-product-analytics/dev/pipeline/dataform_run_dag_product_extension.py \
  ${COMPOSER_BUCKET}/dags/dataform_run_dag.py

# Wait 2-3 min, then verify in Airflow UI:
# - run_intermediate_product_models task is present
# - run_warehouse_product_models task is present
# - Both run in PARALLEL with their marketing equivalents (not sequential)
```

### Step 5: Run Dataform Assertions

```bash
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=data_quality_product
```

**Critical**: Verify DQ-P01 (PII check) PASSES before proceeding to LookML deployment.

### Step 6: Deploy LookML to Looker Production

```bash
cp .wire/releases/04-product-analytics/dev/semantic_layer/views/product/*.lkml \
   [LOOKER_GITHUB_REPO]/views/product/
cp .wire/releases/04-product-analytics/dev/semantic_layer/product.model.lkml \
   [LOOKER_GITHUB_REPO]/product.model.lkml

cd [LOOKER_GITHUB_REPO]
git add views/product/ product.model.lkml
git commit -m "04-product-analytics: add product views and explores"
git push origin main
```

### Step 7: Deploy Dashboards

```bash
cp .wire/releases/04-product-analytics/dev/dashboards/*.dashboard.lkml \
   [LOOKER_GITHUB_REPO]/dashboards/
cd [LOOKER_GITHUB_REPO]
git add dashboards/
git commit -m "04-product-analytics: add PB-01, PB-02, PB-03 dashboards"
git push origin main
```

Configure access:
- **PB-01**: Claire Ashworth, Leon Yip, Fatima Al-Rashidi
- **PB-02**: All CSMs, Tara Obinna, David Park
- **PB-03**: All CSMs, Tara Obinna (CSM filter pre-set per user if possible via Looker user attributes)

### Step 8: End-to-End Validation

```bash
# Trigger a full pipeline run
# Airflow UI: trigger dataform_run_dag manually
# Confirm all phases complete, including the two new product phases

# Verify PB-01 loads within 5 seconds
# Verify PB-02 shows score for a known account
# Verify PB-03 shows stalled accounts
```

---

## Post-Deployment Checklist

- [ ] All 5 product warehouse models have rows in `mart_product`
- [ ] DQ assertions passing (especially DQ-P01 PII check)
- [ ] PB-01 loads within 5 seconds; heatmap drill-through works
- [ ] PB-02 account selector works; score components visible
- [ ] PB-03 CSM filter works; stalled accounts table populated
- [ ] Cloud Composer shows parallel marketing + product phases running
- [ ] Claire Ashworth verifies dashboards in prod and signs off
- [ ] Slack alert sent to #data-platform-alerts: "Product Analytics (04) deployed"

---

## Rollback Procedure

### Step 1: Revert DAG to marketing-only version
```bash
gsutil cp .wire/releases/03-marketing-analytics/dev/pipeline/dataform_run_dag_marketing_extension.py \
  ${COMPOSER_BUCKET}/dags/dataform_run_dag.py
```

### Step 2: Drop product warehouse tables (if data incorrect)
```bash
bq rm -f core-dynamics-analytics-prod:mart_product.fct_feature_usage
bq rm -f core-dynamics-analytics-prod:mart_product.dim_account_product_score
# etc. for all mart_product models
```

### Step 3: Revert LookML
```bash
cd [LOOKER_GITHUB_REPO]
git revert HEAD~1  # Reverts the product LookML commits
git push origin main
```
