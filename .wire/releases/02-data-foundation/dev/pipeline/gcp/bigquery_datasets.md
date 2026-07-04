# BigQuery Dataset Creation
## Core Dynamics Data Platform Modernisation

**Date**: 2026-03-24

## Create All Datasets

```bash
PROJECT=core-dynamics-analytics-prod
REGION=us-central1  # [To confirm with Amara Diallo — match GCP project region]

# Raw layer datasets (one per source — Fivetran-managed)
for dataset in raw_salesforce raw_hubspot raw_google_ads raw_linkedin_ads raw_meta_ads \
               raw_outreach raw_corefm_db raw_mixpanel raw_segment raw_intercom \
               raw_churnzero raw_zendesk raw_netsuite raw_pagerduty raw_gcp_billing \
               raw_bamboohr; do
  bq --project_id=$PROJECT mk \
    --dataset \
    --location=$REGION \
    --description="Raw landing zone for $dataset (Fivetran-managed)" \
    $PROJECT:$dataset
done

# Transformation layer datasets
bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Dataform staging models (1:1 with source tables)" $PROJECT:staging

bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Dataform intermediate models (cross-source business logic)" $PROJECT:intermediate

# Mart/warehouse layer datasets
bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Marketing analytics warehouse tables" $PROJECT:mart_marketing

bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Product analytics warehouse tables" $PROJECT:mart_product

bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Customer analytics warehouse tables" $PROJECT:mart_customer

bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Operational analytics warehouse tables" $PROJECT:mart_ops

# ML and BI scratch datasets
bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="BigQuery ML model outputs (churn risk scores)" $PROJECT:ml_models

bq --project_id=$PROJECT mk --dataset --location=$REGION \
  --description="Looker PDT scratch dataset" $PROJECT:looker_scratch
```

## Repeat for Dev Project

Replace `core-dynamics-analytics-prod` with `core-dynamics-analytics-dev` and run the same commands.

## Dataset Summary

| Dataset | Layer | Managed By | Access |
|---------|-------|-----------|--------|
| raw_salesforce through raw_bamboohr (16 datasets) | Raw | Fivetran | data-engineers write; analysts no access |
| staging | Staging | Dataform | data-engineers write; analysts read |
| intermediate | Intermediate | Dataform | data-engineers write; analysts read |
| mart_marketing, mart_product, mart_customer, mart_ops | Warehouse | Dataform | data-engineers write; analysts + Looker read |
| ml_models | ML | Dataform + BQML | data-engineers write; Looker read |
| looker_scratch | PDT scratch | Looker | Looker service account only |
