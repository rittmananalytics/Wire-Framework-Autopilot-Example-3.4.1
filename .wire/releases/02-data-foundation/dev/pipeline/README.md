# Pipeline Configuration
## Release: 02-data-foundation
## Core Dynamics Data Platform Modernisation

This directory contains pipeline configuration artifacts for the Core Dynamics data foundation.

## Structure

```
dev/pipeline/
├── README.md                          # This file
├── fivetran/
│   ├── connector_inventory.md         # All connector configurations and credentials guide
│   └── connector_specs/               # Per-connector specification files
├── cloud_functions/
│   ├── churnzero_sync/                # ChurnZero incremental sync Cloud Function
│   └── clearbit_enrichment/           # Clearbit webhook enrichment Cloud Function
├── gcp/
│   ├── iam_config.md                  # IAM roles and service account configuration
│   ├── bigquery_datasets.md           # BigQuery dataset creation commands
│   └── secret_manager_guide.md        # Secret Manager setup guide
└── dataform/
    ├── dataform_settings.json         # Dataform project configuration
    └── staging_models/                # Staging model SQL files (see /dataform/ in repo root)
```

## Deployment Order

1. GCP project provisioning (iam_config.md)
2. BigQuery datasets (bigquery_datasets.md)
3. Fivetran connectors (connector_inventory.md)
4. Cloud Functions (cloud_functions/)
5. Dataform repository and staging models
6. Cloud Composer DAGs
