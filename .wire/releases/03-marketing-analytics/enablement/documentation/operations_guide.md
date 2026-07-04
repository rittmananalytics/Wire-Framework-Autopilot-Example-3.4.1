# Operations Guide — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

**Version**: 1.0
**Date**: 2026-03-24
**Author**: Sophie Tanner, Rittman Analytics
**Audience**: Data engineering team, on-call team

---

## 1. Overview

This guide covers day-to-day operations of the Marketing Analytics data pipeline. It assumes the pipeline has been deployed per the deployment runbook and is running on the scheduled cadence.

**Primary on-call contact**: Sophie Tanner (sophie@rittmananalytics.com)
**Escalation**: Kofi Asante, Rittman Analytics
**Client data contact**: Rachel Summers (data questions), Niamh Collins (UTM issues)

---

## 2. Pipeline Schedule

The marketing pipeline runs as part of the main `dataform_run_dag` Cloud Composer DAG. The marketing phases were added in this release as the last two phases.

| Phase | Dataform Tag | Schedule | Expected Duration |
|-------|-------------|----------|------------------|
| staging | `staging` | Daily 2am UTC | ~30 min |
| integration | `integration` | After staging | ~20 min |
| warehouse | `warehouse` | After integration | ~45 min |
| **intermediate_marketing** | `intermediate_marketing` | After warehouse | ~15 min |
| **warehouse_marketing** | `warehouse_marketing` | After intermediate_marketing | ~45 min |

**MA-01 dashboard is refreshed daily by 7am UTC** (all phases complete by ~6:15am UTC on average).
**MA-03 uses a weekly refresh** — full pipeline run on Monday; dashboard data is current as of the previous Friday.

---

## 3. Monitoring

### Cloud Composer / Airflow

**Airflow UI URL**: `https://[cloud-composer-host]/airflow/dags/dataform_run_dag/grid`

Check this URL for:
- Phase completion times
- Task failures (red cells in the grid)
- SLA misses (yellow cells)

### Slack Alerts

Pipeline alerts are sent to `#data-platform-alerts` in the following cases:
- Any Dataform assertion fails → CRITICAL or WARNING depending on severity
- `fct_opportunity_attribution` build takes >2400s → timeout alert
- UTM coverage drops below 60% → WARNING
- Contact match rate drops below 80% → WARNING
- Any data freshness SLA is missed → WARNING

### BigQuery Monitoring

Key tables to check after each run:

```sql
-- Verify all marketing warehouse models have rows
SELECT 'fct_lead_funnel_events' as model, COUNT(*) as rows FROM mart_marketing.fct_lead_funnel_events
UNION ALL SELECT 'fct_campaign_spend', COUNT(*) FROM mart_marketing.fct_campaign_spend
UNION ALL SELECT 'fct_attribution_touches', COUNT(*) FROM mart_marketing.fct_attribution_touches
UNION ALL SELECT 'fct_opportunity_attribution', COUNT(*) FROM mart_marketing.fct_opportunity_attribution
UNION ALL SELECT 'dim_campaign', COUNT(*) FROM mart_marketing.dim_campaign
UNION ALL SELECT 'dim_contact', COUNT(*) FROM mart_marketing.dim_contact;

-- Check attribution model completeness
SELECT attribution_model, COUNT(DISTINCT opportunity_pk) as opps
FROM mart_marketing.fct_opportunity_attribution
GROUP BY 1
ORDER BY 1;
-- Expected: 5 rows with similar opportunity counts
```

---

## 4. Troubleshooting

### 4.1 fct_opportunity_attribution Build Fails

**Symptom**: `warehouse_marketing` phase fails; `fct_opportunity_attribution` shows as errored in Dataform

**Common causes and resolutions**:

| Cause | Symptom | Resolution |
|-------|---------|-----------|
| `int__opportunities__attributed` is empty | 0 rows in intermediate | Check if `int__marketing_touches__all_channels` has rows; re-run integration phase |
| New dbt var added but not in `dbt_project.yml` | `Undefined variable` error | Add the variable with a default value in `dbt_project.yml` |
| Time-decay division by zero | `Division by zero` error | Ensure `time_decay_half_life_days` var is not 0 |
| Attribution weights don't sum to 1.0 | `assert_attribution_weights_sum_to_one` fails | Check if U-shaped weights in dbt vars sum to 1.0 (must be 0.40 + 0.40 + 0.20 = 1.00) |

**Recovery steps**:
1. Identify the failing model in Cloud Logging
2. Fix the root cause in dbt code or vars
3. Re-run: `dbt run --select fct_opportunity_attribution --target prod`
4. Re-run: `dbt test --select fct_opportunity_attribution --target prod`

### 4.2 UTM Coverage Below Alert Threshold

**Symptom**: `assert_utm_coverage_acceptable` assertion fires (coverage < 60%)

**Investigation**:
```sql
-- Check channel breakdown of unattributed touches
SELECT channel, COUNT(*) as touches,
       COUNTIF(utm_source IS NULL) as unattributed,
       ROUND(COUNTIF(utm_source IS NULL) / COUNT(*), 2) as unattributed_rate
FROM mart_marketing.fct_attribution_touches
WHERE touch_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1
ORDER BY 3 DESC;
```

If a previously well-attributed channel (e.g., Google Ads, LinkedIn) suddenly has high unattributed rate:
- Check if the Fivetran connector for that platform ran successfully
- Check if UTM parameters were accidentally removed from the platform

**Contact**: Niamh Collins for UTM enforcement issues

### 4.3 HubSpot-Salesforce Match Rate Drops

**Symptom**: `assert_contact_match_rate_acceptable` assertion fires (match rate < 80%)

**Investigation**:
```sql
-- Check match method distribution
SELECT match_method, COUNT(*) as contacts
FROM intermediate.int__contacts__unified
GROUP BY 1
ORDER BY 2 DESC;
```

A sudden drop in `exact_email` matches while `unmatched` increases may indicate:
- HubSpot Fivetran sync failure (contacts table not updated)
- A batch of new contacts without email addresses in HubSpot
- Salesforce contact email field was cleared in bulk

### 4.4 PII Assertion Fails (CRITICAL)

**Symptom**: `assert_marketing_no_plain_text_email` assertion fails

**Immediate action**:
1. **Do NOT expose the dashboards** to end users until resolved
2. Alert Priya Nair (Data Privacy) and Diane Hooper (Legal) immediately
3. Identify which model contains plain-text emails:
   ```sql
   -- Run on each warehouse model
   SELECT COUNT(*) FROM mart_marketing.dim_contact
   WHERE REGEXP_CONTAINS(email_pseudonymised, r'@');
   ```
4. Identify the dbt model that introduced the plain-text email
5. Fix the `hash_email()` macro call in that model
6. Full rebuild: `dbt run --select tag:warehouse_marketing --full-refresh --target prod`
7. Re-run assertion to confirm 0 violations

### 4.5 Dashboard Not Refreshing

**Symptom**: MA-01 still shows yesterday's data after 7am UTC

**Check**:
1. Cloud Composer: did the DAG run successfully overnight?
2. Was there a scheduling issue (holiday, DST change, Cloud Composer maintenance)?
3. Check `intermediate_marketing` and `warehouse_marketing` phases specifically

**If DAG ran but data is stale**:
```bash
# Trigger a manual DAG run
# In Airflow UI: trigger dataform_run_dag with "Run now"
# OR via CLI:
gcloud composer environments run core-dynamics-composer \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  trigger_dag -- dataform_run_dag
```

### 4.6 LookML Explore Returns No Data

**Symptom**: MA-02 Explore returns 0 results or "No results found"

**Check**:
1. Verify `mart_marketing.fct_opportunity_attribution` has rows:
   ```sql
   SELECT COUNT(*) FROM mart_marketing.fct_opportunity_attribution;
   ```
2. Verify the default filter is not too restrictive (check attribution_model = 'u_shaped' filter)
3. Check Looker connection to BigQuery prod is active (Looker Admin → Connections → core_dynamics_prod)
4. If LookML recently deployed, run Looker Content Validation for errors

---

## 5. Scheduled Maintenance

| Task | Frequency | Steps |
|------|-----------|-------|
| Update `form_asset_mapping.csv` seed | As needed (when new HubSpot forms added) | 1. Niamh Collins provides new form IDs and asset names. 2. Update `dbt/seeds/form_asset_mapping.csv`. 3. Run `dbt seed --select form_asset_mapping --target prod`. 4. Re-run `dbt run --select tag:warehouse_marketing --target prod`. |
| Update `utm_channel_mapping.csv` seed | Quarterly or when new UTM conventions added | Same process as above but for `utm_channel_mapping` |
| Update `meta_campaign_type_mapping.csv` | When Meta campaign naming conventions change | Same process; update regex patterns |
| Adjust attribution window or weights | As requested by Rachel Summers | Update dbt vars in `dbt/dbt_project.yml`; full rebuild of `fct_opportunity_attribution` |

---

## 6. Capacity and Performance

| Model | Approximate Row Count | Build Time | Partitioned? |
|-------|----------------------|------------|--------------|
| fct_opportunity_attribution | ~2M rows (5 models × touches) | 40–60s | Yes (opportunity_created_date) |
| fct_attribution_touches | ~500K rows | 20–30s | Yes (touch_date) |
| fct_lead_funnel_events | ~200K rows | 10–15s | Yes (event_date) |
| fct_campaign_spend | ~50K rows | 5–10s | Yes (spend_date) |
| dim_contact | ~40K rows | 10–15s | No |
| dim_campaign | ~5K rows | 5s | No |

If `fct_opportunity_attribution` build time exceeds 120s consistently, consider:
- Reviewing the clustering key (currently `attribution_model, opportunity_created_date`)
- Checking if the number of touches per opportunity has grown significantly
- Partitioning by `attribution_model` instead of date

---

## 7. Data Retention

The marketing warehouse models do not have a retention policy configured — they are snapshots of current state. Historical opportunity data is retained as long as the source systems retain it.

If BigQuery storage costs increase significantly, consider:
- Applying a partition expiration to `fct_attribution_touches` (e.g., 3 years)
- Reducing the attribution window in future releases (requires Rachel Summers sign-off)

---

## 8. Change Management

Any change to the following requires client sign-off (Rachel Summers) before deployment:
- Attribution window (`marketing_attribution_window_days` dbt var)
- U-shaped model weights (`u_shaped_*` dbt vars)
- Time-decay half-life (`time_decay_half_life_days` dbt var)
- Which funnel event is the "lead conversion touch" (currently SAL)

For all other changes, follow the standard deployment process in `deploy/deployment_runbook.md`.

Changes should be logged in Jira WAEP project. For urgent data quality fixes, tag the issue as `P0` and notify Rachel Summers in `#data-platform-alerts`.
