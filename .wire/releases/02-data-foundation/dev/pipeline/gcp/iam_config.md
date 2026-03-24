# GCP IAM Configuration
## Core Dynamics Data Platform Modernisation

**Target Projects**: `core-dynamics-analytics-dev`, `core-dynamics-analytics-prod`
**Prepared by**: Kofi Asante (Rittman Analytics)
**Date**: 2026-03-24

---

## 1. Service Accounts Required

| Service Account | Purpose | Project |
|----------------|---------|---------|
| `fivetran@core-dynamics-analytics-prod.iam.gserviceaccount.com` | Fivetran BigQuery writes | prod + dev |
| `dataform-runner@core-dynamics-analytics-prod.iam.gserviceaccount.com` | Dataform transformation runs | prod + dev |
| `looker-service@core-dynamics-analytics-prod.iam.gserviceaccount.com` | Looker BigQuery reads | prod |
| `cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com` | Cloud Function execution | prod + dev |
| `composer-worker@core-dynamics-analytics-prod.iam.gserviceaccount.com` | Cloud Composer DAG execution | prod + dev |

---

## 2. IAM Role Assignments

### 2.1 Custom Roles

```bash
# Create data-engineers role (dev + prod)
gcloud iam roles create data_engineers \
  --project=core-dynamics-analytics-prod \
  --title="Data Engineers" \
  --permissions="bigquery.datasets.get,bigquery.tables.get,bigquery.tables.list,bigquery.tables.getData,bigquery.tables.create,bigquery.tables.update,bigquery.tables.delete,dataform.compilationResults.get,dataform.compilationResults.list,dataform.repositories.get,dataform.workflowInvocations.create"

# Create analysts role (read-only to warehouse, restricted from raw)
gcloud iam roles create analysts \
  --project=core-dynamics-analytics-prod \
  --title="Analysts" \
  --permissions="bigquery.datasets.get,bigquery.tables.get,bigquery.tables.list,bigquery.tables.getData"
```

### 2.2 Fivetran Service Account Permissions

```bash
# Fivetran needs BigQuery Data Editor on raw datasets only
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:fivetran@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"

# Add BigQuery Job User for running load jobs
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:fivetran@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"
```

### 2.3 Dataform Service Account Permissions

```bash
# Dataform runner needs read access to all datasets + write to staging/intermediate/warehouse
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:dataform-runner@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:dataform-runner@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"

# Dataform also needs Secret Manager access for credentials
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:dataform-runner@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### 2.4 Looker Service Account Permissions

```bash
# Looker needs read-only access to warehouse/marts datasets only (not raw or staging)
# Apply at dataset level, not project level
for dataset in mart_marketing mart_product mart_customer mart_ops looker_scratch; do
  bq update --source <(echo '{
    "access": [
      {"role": "READER", "userByEmail": "looker-service@core-dynamics-analytics-prod.iam.gserviceaccount.com"}
    ]
  }') core-dynamics-analytics-prod:$dataset
done

# BigQuery Job User at project level for query execution
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:looker-service@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"
```

### 2.5 Cloud Functions Service Account

```bash
# Cloud Functions need BigQuery write access to raw datasets + Secret Manager
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"

gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="serviceAccount:cloud-functions@core-dynamics-analytics-prod.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

---

## 3. Required APIs

```bash
# Enable all required APIs on both projects
for project in core-dynamics-analytics-dev core-dynamics-analytics-prod; do
  gcloud services enable \
    bigquery.googleapis.com \
    dataform.googleapis.com \
    composer.googleapis.com \
    pubsub.googleapis.com \
    secretmanager.googleapis.com \
    logging.googleapis.com \
    cloudfunctions.googleapis.com \
    cloudscheduler.googleapis.com \
    sqladmin.googleapis.com \
    monitoring.googleapis.com \
    --project=$project
done
```

---

## 4. Rittman Analytics Team Access

```bash
# Add Rittman Analytics data-engineers group to dev project (Owner during provisioning)
gcloud projects add-iam-policy-binding core-dynamics-analytics-dev \
  --member="group:rittman-analytics-engineers@rittmananalytics.com" \
  --role="roles/owner"

# Add Rittman Analytics to prod project (Editor — not Owner)
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="group:rittman-analytics-engineers@rittmananalytics.com" \
  --role="roles/editor"
```

---

## 5. Core Dynamics Team Access

```bash
# Data engineering team (Amara Diallo + team) — data-engineers role
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="group:data-engineers@coredynamics.io" \
  --role="projects/core-dynamics-analytics-prod/roles/data_engineers"

# Analysts (James Petit, workstream leads) — analysts role
gcloud projects add-iam-policy-binding core-dynamics-analytics-prod \
  --member="group:analysts@coredynamics.io" \
  --role="projects/core-dynamics-analytics-prod/roles/analysts"
```

---

## 6. Security Notes

- No personal Google accounts granted project-level IAM (service accounts and groups only in prod)
- Rittman Analytics Owner access on dev is time-limited to the engagement; remove at handover
- All service account keys stored in GCP Secret Manager; key rotation scheduled quarterly
- Audit log for IAM changes enabled on both projects
