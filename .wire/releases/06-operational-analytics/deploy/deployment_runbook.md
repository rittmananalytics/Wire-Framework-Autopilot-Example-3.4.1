# Deployment Runbook — Operational Analytics
## Release: 06-operational-analytics

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Dependencies**: Releases 02 and 05 deployed; PagerDuty + GCP Billing Fivetran connectors active

---

## Pre-Deployment Checklist

- [ ] PagerDuty Fivetran connector active and syncing (Greg Ellison)
- [ ] GCP Billing export to BigQuery configured (Greg Ellison)
- [ ] `stg_pagerduty__incidents` populated with at least 30 days of data
- [ ] `stg_gcp__billing_export` populated with at least 1 billing month
- [ ] `mart_operations` BigQuery dataset created
- [ ] `dbt test --select tag:warehouse_operations` 100% pass in dev

---

## Deployment Steps

### Step 1: Create BigQuery Dataset

```bash
bq mk --location=us-central1 --dataset core-dynamics-analytics-prod:mart_operations
```

### Step 2: Run dbt Models

```bash
cd dbt
dbt run --select tag:warehouse_operations --target prod
dbt test --select tag:warehouse_operations --target prod

# Verify row counts
bq query --project_id=core-dynamics-analytics-prod \
  "SELECT 'fct_support_tickets' as model, COUNT(*) FROM mart_operations.fct_support_tickets
   UNION ALL SELECT 'fct_incident_response', COUNT(*) FROM mart_operations.fct_incident_response
   UNION ALL SELECT 'fct_infra_cost_by_customer', COUNT(*) FROM mart_operations.fct_infra_cost_by_customer
   UNION ALL SELECT 'fct_support_capacity', COUNT(*) FROM mart_operations.fct_support_capacity"
```

### Step 3: Run Data Quality Assertions

```bash
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=data_quality_operations
```

### Step 4: Deploy LookML

```bash
cp .wire/releases/06-operational-analytics/dev/semantic_layer/views/operations/*.lkml \
   [LOOKER_GITHUB_REPO]/views/operations/
cp .wire/releases/06-operational-analytics/dev/semantic_layer/operations.model.lkml \
   [LOOKER_GITHUB_REPO]/operations.model.lkml
cd [LOOKER_GITHUB_REPO]
git add views/operations/ operations.model.lkml
git commit -m "06-operational-analytics: add operations views and explores"
git push origin main
```

### Step 5: Configure Dashboard Access

- **DO-01** Support Operations: Support manager, Tara Obinna
- **DO-02** Incident Response: Engineering lead, Greg Ellison
- **DO-03** Infrastructure Cost: David Park, Tara Obinna (finance_viewers + leadership only for ARR/cost)

---

## Post-Deployment Checklist

- [ ] All 4 operational models have rows in `mart_operations`
- [ ] DQ assertions passing (no critical failures)
- [ ] DO-01 loads and shows ticket trend data
- [ ] DO-02 shows incident MTTR and correlation with ticket spikes
- [ ] DO-03 shows per-account infrastructure cost (visible to finance_viewers only)
- [ ] Slack alert sent: "Operational Analytics (06) deployed"

---

## Rollback

```bash
bq rm -f core-dynamics-analytics-prod:mart_operations.fct_support_tickets
bq rm -f core-dynamics-analytics-prod:mart_operations.fct_incident_response
bq rm -f core-dynamics-analytics-prod:mart_operations.fct_infra_cost_by_customer
bq rm -f core-dynamics-analytics-prod:mart_operations.fct_support_capacity

cd [LOOKER_GITHUB_REPO]
git revert HEAD~1
git push origin main
```
