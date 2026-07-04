# Deployment Runbook
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-24
**Target Environment**: core-dynamics-analytics-prod
**Dependency**: 02-data-foundation must be deployed and all staging assertions passing
**Sign-off required from**: Rachel Summers (UAT) before prod deployment

---

## Pre-Deployment Checklist

Before executing any deployment steps, verify all of the following:

- [ ] **UAT complete**: Rachel Summers has signed UAT sign-off form (test/uat_plan.md)
- [ ] **David Park sign-off**: MA-03 approved by David Park (CRO)
- [ ] **02-data-foundation passing**: All staging model assertions passing for ≥3 consecutive daily runs
- [ ] **dbt tests passing in dev**: `dbt test --select warehouse_marketing` 100% pass in dev environment
- [ ] **Looker staging validation**: All 3 dashboards passing Looker content validation in staging
- [ ] **form_asset_mapping received**: Niamh Collins has provided final form-to-asset mapping (seeds/form_asset_mapping.csv updated)
- [ ] **U-shaped weights confirmed**: Rachel Summers has confirmed 40/40/20 weighting (or updated vars if changed)
- [ ] **PII assertion passing**: `assert_marketing_no_plain_text_email` passing in dev
- [ ] **Rollback plan reviewed**: Team has read the rollback procedure in Section 6

---

## Deployment Steps

### Step 1: Deploy Dataform Model Tags to Production

```bash
# 1.1 Ensure the latest code is on the main branch in GitHub
git checkout main
git pull origin main

# 1.2 Create a compilation result in production Dataform repository
gcloud dataform compilation-results create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --git-commitish=main

# Capture the compilation result name for use in steps below
COMPILATION_RESULT=$(gcloud dataform compilation-results list \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --format="value(name)" \
  --sort-by="~createTime" \
  --limit=1)

echo "Using compilation result: $COMPILATION_RESULT"
```

**Verification**: Compilation result shows 0 errors and includes intermediate_marketing and warehouse_marketing models.

---

### Step 2: Run dbt Models in Production

```bash
# 2.1 Navigate to the dbt project directory
cd dbt

# 2.2 Install dbt dependencies (if not already installed)
dbt deps

# 2.3 Run marketing seeds first (utm_channel_mapping, funnel_stage_config, form_asset_mapping)
dbt seed --select attribution_models utm_channel_mapping funnel_stage_config meta_campaign_type_mapping form_asset_mapping \
  --target prod

# 2.4 Run intermediate (integration) marketing models
dbt run --select tag:intermediate_marketing \
  --target prod

# Verify: check row counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'int__contacts__unified' as model, COUNT(*) as rows FROM intermediate.int__contacts__unified
   UNION ALL
   SELECT 'int__marketing_touches__all_channels', COUNT(*) FROM intermediate.int__marketing_touches__all_channels
   UNION ALL
   SELECT 'int__campaign_spend__normalised', COUNT(*) FROM intermediate.int__campaign_spend__normalised"

# 2.5 Run warehouse marketing models
dbt run --select tag:warehouse_marketing \
  --target prod

# Verify: check row counts in mart_marketing
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'fct_attribution_touches' as model, COUNT(*) as rows FROM mart_marketing.fct_attribution_touches
   UNION ALL
   SELECT 'fct_opportunity_attribution', COUNT(*) FROM mart_marketing.fct_opportunity_attribution
   UNION ALL
   SELECT 'dim_contact', COUNT(*) FROM mart_marketing.dim_contact
   UNION ALL
   SELECT 'dim_campaign', COUNT(*) FROM mart_marketing.dim_campaign"

# 2.6 Run dbt tests for marketing models
dbt test --select tag:warehouse_marketing \
  --target prod
```

**Verification**: All dbt tests pass. Row counts appear plausible (see data quality plan volume thresholds).

---

### Step 3: Update Cloud Composer DAG

```bash
# 3.1 Get the Cloud Composer GCS bucket path
COMPOSER_BUCKET=$(gcloud composer environments describe core-dynamics-composer \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --format="value(config.dagGcsPrefix)")

# 3.2 Upload the updated dataform_run_dag.py (with marketing phases added)
# IMPORTANT: This replaces the existing dataform_run_dag.py
gsutil cp .wire/releases/03-marketing-analytics/dev/pipeline/dataform_run_dag_marketing_extension.py \
  ${COMPOSER_BUCKET}/dags/dataform_run_dag.py

# 3.3 Verify the DAG appears in Airflow UI with the new tasks
# Wait 2-3 minutes for Cloud Composer to pick up the new DAG file
# Then verify in Airflow UI:
# - run_intermediate_marketing_models task is present
# - run_warehouse_marketing_models task is present
# - Dependency chain is correct: staging → integration → warehouse → intermediate_marketing → warehouse_marketing
```

**Verification**: Open Cloud Composer Airflow UI. Confirm `dataform_run_dag` shows the two new tasks and the dependency chain is correct.

---

### Step 4: Run Dataform Assertions (Marketing)

```bash
# Run the marketing data quality assertions
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=data_quality_marketing

# Monitor the invocation
gcloud dataform workflow-invocations list \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod
```

**Verification**: All marketing assertions pass, especially:
- `assert_marketing_attribution_weights` — PASS (weights sum to 1.0)
- `assert_marketing_no_plain_text_email` — PASS (PII compliance)
- `assert_all_attribution_models_present` — PASS (5 models present)

---

### Step 5: Deploy LookML to Looker Production

```bash
# 5.1 Deploy LookML view files to Looker production project
# Copy LookML files to the Looker GitHub repository (connected to Looker production)

cp .wire/releases/03-marketing-analytics/dev/semantic_layer/views/marketing/*.lkml \
   [LOOKER_GITHUB_REPO]/views/marketing/

cp .wire/releases/03-marketing-analytics/dev/semantic_layer/marketing.model.lkml \
   [LOOKER_GITHUB_REPO]/marketing.model.lkml

# 5.2 Commit and push to Looker's connected GitHub repository
cd [LOOKER_GITHUB_REPO]
git add views/marketing/ marketing.model.lkml
git commit -m "03-marketing-analytics: add marketing views and explores"
git push origin main

# 5.3 In Looker Admin → Git Deployments → Deploy production branch
# Or via Looker API:
curl -X POST "https://[LOOKER_HOST]/api/4.0/projects/[PROJECT_ID]/deploy_to_production" \
  -H "Authorization: token [LOOKER_API_TOKEN]"
```

**Verification**: Run Looker Content Validation. Confirm 0 errors on marketing views and explores.

---

### Step 6: Publish Dashboards in Looker

```bash
# 6.1 Deploy LookML dashboards to production
cp .wire/releases/03-marketing-analytics/dev/dashboards/*.dashboard.lkml \
   [LOOKER_GITHUB_REPO]/dashboards/

cd [LOOKER_GITHUB_REPO]
git add dashboards/
git commit -m "03-marketing-analytics: add MA-01 and MA-03 LookML dashboards"
git push origin main

# 6.2 Deploy to Looker production
# (Same deploy command as Step 5.3)

# 6.3 Configure dashboard access
# In Looker Admin → Dashboards:
# - MA-01: Share with Rachel Summers, Owen Brady, Niamh Collins
# - MA-02 Explore: Share with Rachel Summers, Owen Brady (Explore access required)
# - MA-03: Share with Marcus Elwood, David Park, Rachel Summers
# - Greg Fontaine: Read access to MA-03 only
```

**Verification**: Open each dashboard as a test user (Rachel Summers' account or Looker viewer test account). Confirm dashboards load within 5 seconds on default date ranges.

---

### Step 7: Configure MA-02 Explore Saved Views

```bash
# Saved Explore views must be created manually in Looker UI by Sophie Tanner
# Reference: .wire/releases/03-marketing-analytics/dev/dashboards/ma02_attribution_explore_saved_views.md

# For each of the 5 saved views described in that document:
# 1. Open the marketing_attribution Explore in Looker staging
# 2. Configure fields, filters, and pivots as specified
# 3. Save as "Explore Look" with the name specified in the document
# 4. Share with Rachel Summers and Owen Brady
```

**Verification**: Rachel Summers can access all 5 saved views from the MA-02 Explore page.

---

### Step 8: End-to-End Validation

```bash
# 8.1 Trigger a full pipeline run to test the extended DAG
# In Airflow UI: trigger dataform_run_dag manually
# Confirm all phases complete successfully:
# - staging: pass
# - integration: pass
# - warehouse: pass
# - intermediate_marketing: pass  ← NEW
# - warehouse_marketing: pass     ← NEW

# 8.2 Verify MA-01 dashboard reflects latest data
# Open MA-01 in Looker production
# Confirm data date shows today's date (or yesterday if pre-7am UTC)

# 8.3 Run attribution consistency check
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT attribution_model, COUNT(DISTINCT opportunity_pk) as opps, ROUND(SUM(attributed_revenue_usd), 2) as total_attributed
   FROM mart_marketing.fct_opportunity_attribution
   WHERE is_closed_won = TRUE
   GROUP BY 1
   ORDER BY 1"
-- Verify all 5 models present and total_attributed is approximately equal across models
```

---

## Post-Deployment Verification Checklist

- [ ] All 6 marketing warehouse models have rows in `mart_marketing` dataset
- [ ] All dbt tests passing (`dbt test --select tag:warehouse_marketing`)
- [ ] All Dataform marketing assertions passing (tag: data_quality_marketing)
- [ ] Cloud Composer `dataform_run_dag` shows 2 new tasks; manual trigger succeeds
- [ ] MA-01 loads within 5 seconds with default date range
- [ ] MA-02 Explore accessible; attribution model filter works; U-shaped is default
- [ ] MA-03 loads within 5 seconds with default date range
- [ ] Rachel Summers has verified dashboards in production and confirms sign-off
- [ ] David Park has verified MA-03 in production
- [ ] Slack alert in `#data-platform-alerts` sent: "Marketing Analytics (03) deployed successfully"

---

## Rollback Procedure

If deployment fails or data quality issues are detected post-deployment:

### Step 1: Pause Marketing DAG Phases
```bash
# In Airflow UI: pause the intermediate_marketing and warehouse_marketing tasks
# OR temporarily revert dataform_run_dag.py to the previous version
gsutil cp [BACKUP_DAG_FILE] ${COMPOSER_BUCKET}/dags/dataform_run_dag.py
```

### Step 2: Drop Marketing Warehouse Tables
```bash
# Only if tables are producing incorrect data and need to be rebuilt
bq rm -f core-dynamics-analytics-prod:mart_marketing.fct_opportunity_attribution
bq rm -f core-dynamics-analytics-prod:mart_marketing.fct_attribution_touches
# etc. for all 6 warehouse models
```

### Step 3: Revert LookML
```bash
cd [LOOKER_GITHUB_REPO]
git revert HEAD  # Reverts the marketing LookML commit
git push origin main
# Re-deploy Looker production
```

### Step 4: Investigate Root Cause
- Check Cloud Logging for Dataform errors
- Check dbt test output for failing assertions
- Check attribution integrity assertions specifically

### Step 5: Resume
- Fix root cause in dev
- Re-run full dbt test suite in dev
- Re-execute deployment runbook from Step 2

---

## Communication Plan

| Event | Communication | Audience | Channel |
|-------|-------------|---------|---------|
| Deployment start | "Starting 03-marketing-analytics deployment at [TIME]" | Rachel Summers, Amara Diallo | Email |
| Deployment complete | "Marketing analytics dashboards are live in production" | Rachel Summers, Owen Brady, Niamh Collins, David Park, Marcus Elwood | Email + Slack |
| Deployment blocked | Issue description + ETA | Rachel Summers, Amara Diallo | Slack #data-engineering |
| Data quality issue post-deploy | Alert with description | Rachel Summers (dashboards affected), Kofi Asante | Slack #data-platform-alerts |
| Milestone sign-off request | Phase 2 milestone sign-off with evidence | Amara Diallo | Email with validation report |
