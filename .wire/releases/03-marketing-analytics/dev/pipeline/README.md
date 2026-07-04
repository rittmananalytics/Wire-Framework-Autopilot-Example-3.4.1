# Pipeline Configuration
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Date**: 2026-03-24

## Overview

The marketing analytics pipeline does **not** introduce new Fivetran connectors or ingestion infrastructure. It extends the existing Dataform repository with new intermediate and warehouse model tags targeting the `mart_marketing` BigQuery dataset.

All source data is already landing via the 02-data-foundation pipeline.

## Changes to Existing Infrastructure

### 1. Dataform Repository Extension

Add new workflow invocation tags to `core-dynamics-dataform`:

| Tag | Models | Dataset |
|-----|--------|---------|
| `intermediate_marketing` | All `int__*` models for marketing | intermediate |
| `warehouse_marketing` | All `fct_*` and `dim_*` in mart_marketing | mart_marketing |

### 2. Cloud Composer DAG Extension

Update `dataform_run_dag.py` to include the two new marketing tags as phases downstream of the existing staging phase.

See `dataform_run_dag_marketing_extension.py` for the updated DAG configuration.

### 3. BigQuery Dataset

The `mart_marketing` dataset was created in 02-data-foundation (`bigquery_datasets.md`). No additional dataset provisioning required.

## Files in This Directory

| File | Description |
|------|-------------|
| `dataform_workflow_config.md` | Dataform tag configuration and workflow invocation spec |
| `dataform_run_dag_marketing_extension.py` | Updated Cloud Composer DAG with marketing phases |
| `dataform_tags.md` | Complete tag reference for all marketing models |
