# Deployment Runbook
## Release: 02-data-foundation
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Kofi Asante, Sophie Tanner — Rittman Analytics
**Date**: 2026-03-24
**Target Environment**: core-dynamics-analytics-prod
**Sign-off required from**: Amara Diallo (Phase 1 milestone sign-off)

---

## Pre-Deployment Checklist

Before executing any deployment steps, verify all of the following:

- [ ] **GCP Access**: Rittman Analytics service account has Owner on dev and Editor on prod (confirm with Amara Diallo)
- [ ] **Fivetran account**: Core Dynamics has procured Fivetran Business Critical account; Rittman Analytics has access to configure connectors
- [ ] **All connector credentials received**: All 15 system owner credentials in hand (track against connector_inventory.md)
- [ ] **NetSuite integration role**: Sandra Kowalski has started integration role creation process
- [ ] **CoreFM PostgreSQL access**: Cloud SQL Auth Proxy configured by Amara + Sean Murphy (read-only service account active)
- [ ] **PII pseudonymisation sign-off**: Written sign-off from Priya Nair + Diane Hooper on file
- [ ] **Feature taxonomy CSV**: Received from Leon Yip; loaded to raw_corefm_db.feature_taxonomy
- [ ] **Segment event mapping**: Received from Leon Yip; deduplication rules implemented in staging models
- [ ] **Secret Manager populated**: All API keys stored in GCP Secret Manager (not in code)
- [ ] **Data quality assertions**: All assertions passing for 3 consecutive daily runs in dev
- [ ] **Dataform repository**: All staging models passing compilation and test runs in dev
- [ ] **Cloud Composer**: Both dev and prod environments healthy; DAGs visible in Airflow UI
- [ ] **Rollback plan reviewed**: Team has read the rollback procedure in Section 6

---

## Deployment Steps

### Step 1: GCP Infrastructure Provisioning

```bash
# 1.1 Create GCP projects (if not already done by Amara Diallo's team)
# Run as: Rittman Analytics service account or Amara Diallo
gcloud projects create core-dynamics-analytics-dev --name="Core Dynamics Analytics Dev"
gcloud projects create core-dynamics-analytics-prod --name="Core Dynamics Analytics Prod"

# 1.2 Link billing accounts
gcloud billing projects link core-dynamics-analytics-dev \
  --billing-account=[BILLING_ACCOUNT_ID]  # [To confirm with Sandra Kowalski]
gcloud billing projects link core-dynamics-analytics-prod \
  --billing-account=[BILLING_ACCOUNT_ID]

# 1.3 Enable APIs (see gcp/iam_config.md)
# Run the API enable commands from iam_config.md for both projects

# 1.4 Create service accounts (see gcp/iam_config.md)
# Run the service account creation and IAM binding commands

# 1.5 Create BigQuery datasets (see gcp/bigquery_datasets.md)
# Run the bq mk commands for all datasets on both projects
```

**Verification**: All datasets visible in BigQuery console; IAM roles confirmed in Cloud Console.

---

### Step 2: Secret Manager Population

```bash
# Populate all credentials in Secret Manager BEFORE configuring connectors
# Run as: Rittman Analytics data engineer

# Example — ChurnZero API key (Ben Tran to provide the key value)
echo -n "CHURNZERO_API_KEY_VALUE" | \
  gcloud secrets create churnzero-api-key \
    --data-file=- \
    --project=core-dynamics-analytics-prod

# Fivetran API credentials (from Fivetran account settings)
echo -n '{"api_key": "FIVETRAN_API_KEY", "api_secret": "FIVETRAN_API_SECRET"}' | \
  gcloud secrets create fivetran-api-credentials \
    --data-file=- \
    --project=core-dynamics-analytics-prod

# Clearbit API key
echo -n "CLEARBIT_API_KEY_VALUE" | \
  gcloud secrets create clearbit-api-key \
    --data-file=- \
    --project=core-dynamics-analytics-prod

# PII pseudonymisation salt (generate a secure random value — never share)
python3 -c "import secrets; print(secrets.token_hex(32))" | \
  gcloud secrets create pii-pseudonymisation-salt \
    --data-file=- \
    --project=core-dynamics-analytics-prod
```

**Verification**: All secrets visible in Secret Manager console; test access from Cloud Function service account.

---

### Step 3: Fivetran Connector Configuration

```bash
# Configure Fivetran BigQuery destination first
# Then configure each connector in the following order:
# 1. Salesforce
# 2. HubSpot
# 3. Zendesk
# 4. CoreFM PostgreSQL (requires Cloud SQL Auth Proxy active)
# 5. Mixpanel, Intercom, Outreach
# 6. Google Ads, LinkedIn Ads, Meta Ads
# 7. NetSuite (when integration role is ready)
# 8. PagerDuty, BambooHR

# For each connector:
# a. Create connector in Fivetran UI
# b. Configure credentials (see connector_inventory.md)
# c. Set sync schedule
# d. Run initial historical sync (may take several hours for Salesforce/HubSpot)
# e. Verify data landing in raw_<source> dataset
```

**Verification**: All connectors show "Connected" status in Fivetran; data visible in raw datasets; no error messages.

---

### Step 4: Cloud Functions Deployment

```bash
# Deploy ChurnZero Sync Cloud Function
gcloud functions deploy churnzero_sync \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=dev/pipeline/cloud_functions/churnzero_sync/ \
  --entry-point=sync_churnzero \
  --trigger-http \
  --allow-unauthenticated=false \
  --service-account=cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com \
  --set-env-vars GCP_PROJECT=core-dynamics-analytics-prod \
  --project=core-dynamics-analytics-prod

# Create Cloud Scheduler job to trigger ChurnZero sync daily at 6am UTC
gcloud scheduler jobs create http churnzero-daily-sync \
  --location=us-central1 \
  --schedule="0 6 * * *" \
  --uri="$(gcloud functions describe churnzero_sync --region=us-central1 --format='value(serviceConfig.uri)')" \
  --oidc-service-account-email=cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com \
  --project=core-dynamics-analytics-prod

# Deploy Clearbit Enrichment Cloud Function
gcloud functions deploy clearbit_enrichment \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=dev/pipeline/cloud_functions/clearbit_enrichment/ \
  --entry-point=enrich_contact \
  --trigger-http \
  --allow-unauthenticated=false \
  --service-account=cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com \
  --set-env-vars GCP_PROJECT=core-dynamics-analytics-prod \
  --project=core-dynamics-analytics-prod

# Register Clearbit function URL as HubSpot webhook
# (Manual step — Niamh Collins to add function URL as HubSpot webhook for 'contact.creation' event)
```

**Verification**: Functions deploy successfully; test trigger returns 200; data appears in BigQuery.

---

### Step 5: Dataform Repository Setup

```bash
# 5.1 Create Dataform repository in GCP
gcloud dataform repositories create core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod

# 5.2 Link to GitHub repository
# Manual step — configure GitHub connection in Dataform UI:
# - GitHub URL: https://github.com/coredynamics/analytics-platform
# - Branch: main
# - Authentication: GitHub App (configure via Dataform UI)

# 5.3 Create compilation result and verify
gcloud dataform compilation-results create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --git-commitish=main

# 5.4 Run staging layer first (validate before deploying intermediate/warehouse)
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=staging
```

**Verification**: All staging models compile without errors; tables appear in staging dataset; no assertion failures.

---

### Step 6: Cloud Composer Deployment

```bash
# 6.1 Create Cloud Composer 2 environment
gcloud composer environments create core-dynamics-composer \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --image-version=composer-2-airflow-2 \
  --service-account=composer-worker@core-dynamics-analytics-prod.iam.gserviceaccount.com

# Wait ~20 minutes for environment to be ready

# 6.2 Upload DAGs to Cloud Composer GCS bucket
COMPOSER_BUCKET=$(gcloud composer environments describe core-dynamics-composer \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --format="value(config.dagGcsPrefix)")

gsutil cp dev/pipeline/composer/dags/*.py ${COMPOSER_BUCKET}/dags/

# 6.3 Verify DAGs are visible in Airflow UI
# Open Airflow UI and confirm all 4 DAGs appear (fivetran_trigger_dag, dataform_run_dag, data_quality_dag, alerting_dag)
```

**Verification**: All DAGs visible in Airflow UI; trigger a manual run of `fivetran_trigger_dag` to test end-to-end flow.

---

### Step 7: End-to-End Validation

```bash
# 7.1 Trigger a full pipeline run manually
# In Airflow UI: trigger fivetran_trigger_dag manually
# Observe: fivetran_trigger_dag → dataform_run_dag → data_quality_dag

# 7.2 Verify data quality assertions pass
# Check Dataform workflow invocation results in Cloud Console
# All assertions should pass

# 7.3 Row count reconciliation
# For Salesforce accounts: BigQuery row count should be within ±1% of Salesforce record count
# Run reconciliation queries:

bq query --project_id=core-dynamics-analytics-prod \
  "SELECT COUNT(*) as bq_account_count FROM staging.stg_salesforce__accounts"
# Compare with Salesforce account count (Greg Fontaine to provide)

# 7.4 Verify pipeline health dashboard
# Open Looker pipeline health dashboard
# All sources should show green status and recent sync times
```

---

## Post-Deployment Verification

- [ ] All 18 source connectors show successful syncs in last 24 hours
- [ ] All Dataform assertions passing (check Dataform workflow invocation results)
- [ ] Cloud Composer DAGs running on schedule without failures
- [ ] Pipeline health dashboard showing green for all sources
- [ ] Row count reconciliation within ±1% for key tables (Salesforce accounts, HubSpot contacts)
- [ ] Alerting configured and tested (simulate a failure; verify Slack alert fires)
- [ ] Amara Diallo has reviewed and confirmed Phase 1 milestone criteria met

---

## Rollback Procedure

If deployment fails or data quality issues are detected:

### Step 1: Pause Fivetran Syncs
```bash
# Pause all Fivetran connectors via Fivetran UI or API
# This prevents further data loading while issues are investigated
```

### Step 2: Disable Cloud Composer DAGs
```bash
# In Airflow UI: pause all 4 DAGs
# This stops scheduled runs while issues are investigated
```

### Step 3: Identify Root Cause
```bash
# Check Cloud Logging for errors
gcloud logging read "resource.type=cloud_composer_environment" \
  --project=core-dynamics-analytics-prod \
  --limit=50

# Check Dataform workflow invocation failures
gcloud dataform workflow-invocations list \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod
```

### Step 4: Restore Previous State
- If data quality assertions fail due to pipeline bug: fix the Dataform model, re-run
- If Fivetran connector fails: check connector status in Fivetran UI; re-configure credentials if needed
- If Cloud Function fails: check Cloud Logging; redeploy function with `gcloud functions deploy`

### Step 5: Resume
- Fix root cause, validate in dev environment first, then re-deploy to prod
- Re-enable Fivetran connectors and Cloud Composer DAGs
- Re-run full pipeline validation (Section 7)

---

## Communication Plan

| Event | Communication | Audience | Channel |
|-------|-------------|---------|---------|
| Deployment start | "Starting Phase 1 deployment at [TIME]" | Amara Diallo, Priya Nair | Email |
| Deployment complete | Phase 1 milestone confirmation with validation results | Amara Diallo, Priya Nair | Email + Slack |
| Deployment blocked | Issue description + ETA to resolution | Amara Diallo | Slack #data-engineering |
| Data quality issue | Alert with description and action required | Amara Diallo, Kofi Asante | Slack #data-platform-alerts |
| Milestone sign-off request | Phase 1 milestone sign-off request with evidence | Amara Diallo | Email with attached validation report |
