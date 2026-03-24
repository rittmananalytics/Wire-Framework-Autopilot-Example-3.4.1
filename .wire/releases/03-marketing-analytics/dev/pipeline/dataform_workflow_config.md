# Dataform Workflow Configuration
## Release: 03-marketing-analytics

**Repository**: core-dynamics-dataform
**Project**: core-dynamics-analytics-prod
**Location**: us-central1

---

## 1. New Tags

All marketing analytics Dataform models must be tagged appropriately in their `config {}` blocks. The two new tags introduced by this release are:

| Tag | Purpose | Models |
|-----|---------|--------|
| `intermediate_marketing` | Marketing analytics intermediate layer | int__contacts__unified, int__marketing_touches__all_channels, int__campaign_spend__normalised, int__opportunities__attributed, int__funnel_events__staged |
| `warehouse_marketing` | Marketing analytics warehouse layer | fct_lead_funnel_events, fct_campaign_spend, fct_attribution_touches, fct_opportunity_attribution, dim_campaign, dim_contact |

---

## 2. Dataform Config Block Examples

```javascript
// Example: int__contacts__unified
config {
  type: "view",
  schema: "intermediate",
  tags: ["intermediate", "intermediate_marketing"],
  description: "Unified contact master across HubSpot and Salesforce with fuzzy match and Clearbit enrichment"
}

// Example: fct_opportunity_attribution
config {
  type: "table",
  schema: "mart_marketing",
  tags: ["warehouse", "warehouse_marketing", "attribution"],
  description: "Opportunity revenue attributed across 5 models per touch in 180-day window",
  bigquery: {
    partitionBy: "DATE(opportunity_created_date)",
    clusterBy: ["attribution_model", "channel"]
  }
}

// Example: fct_lead_funnel_events (incremental)
config {
  type: "incremental",
  schema: "mart_marketing",
  tags: ["warehouse", "warehouse_marketing"],
  description: "Lead funnel stage transitions with timestamps",
  bigquery: {
    partitionBy: "stage_entered_date",
    clusterBy: ["stage_name", "channel"]
  },
  uniqueKey: ["funnel_event_pk"]
}

// Example: dim_campaign (full refresh)
config {
  type: "table",
  schema: "mart_marketing",
  tags: ["warehouse", "warehouse_marketing"],
  description: "Campaign dimension unified across all platforms"
}
```

---

## 3. Workflow Invocation — Marketing Phases

Run intermediate_marketing after staging completes, warehouse_marketing after intermediate completes:

```bash
# Phase 4a: Intermediate marketing models
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=intermediate_marketing

# Phase 4b: Warehouse marketing models
gcloud dataform workflow-invocations create \
  --repository=core-dynamics-dataform \
  --location=us-central1 \
  --project=core-dynamics-analytics-prod \
  --included-tags=warehouse_marketing
```

---

## 4. Dependency Order

```
staging (02-data-foundation, already running)
    └── intermediate_marketing (new — Phase 4a)
            ├── int__contacts__unified
            ├── int__marketing_touches__all_channels
            ├── int__campaign_spend__normalised
            ├── int__funnel_events__staged
            └── int__opportunities__attributed
                    └── warehouse_marketing (new — Phase 4b)
                            ├── dim_contact
                            ├── dim_campaign
                            ├── fct_lead_funnel_events
                            ├── fct_campaign_spend
                            ├── fct_attribution_touches
                            └── fct_opportunity_attribution
```

---

## 5. BigQuery Partitioning and Clustering

| Model | Partition By | Cluster By | Rationale |
|-------|-------------|-----------|-----------|
| fct_lead_funnel_events | stage_entered_date | stage_name, channel | Date range queries common in funnel analysis |
| fct_campaign_spend | spend_date | platform, campaign_fk | Daily spend queries always date-filtered |
| fct_attribution_touches | touch_date | channel, touch_type | Time-window queries for attribution |
| fct_opportunity_attribution | opportunity_created_date | attribution_model, channel | Model + channel grouping is primary query pattern |
| dim_campaign | (none — small table) | channel | Small reference table; full scan acceptable |
| dim_contact | (none — small-medium table) | hubspot_lifecycle_stage | Contact lookups by lifecycle stage |

---

## 6. Variables Configuration

Add to `dataform.json` (project-level):

```json
{
  "vars": {
    "marketing_attribution_window_days": "180",
    "u_shaped_first_touch_weight": "0.40",
    "u_shaped_lead_conversion_weight": "0.40",
    "u_shaped_middle_weight": "0.20",
    "time_decay_half_life_days": "30",
    "marketing_project": "core-dynamics-analytics-prod"
  }
}
```

These variables are referenced in `fct_opportunity_attribution.sqlx` to allow business-configurable weight adjustments without model code changes.

---

## 7. Assertions (Data Quality Checks)

Marketing-specific assertions to add alongside warehouse models:

```javascript
// assert_attribution_weights_sum_to_one.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "warehouse_marketing", "attribution"]
}

SELECT
  opportunity_pk,
  attribution_model,
  ROUND(SUM(touch_weight), 3) as weight_sum
FROM ${ref("fct_opportunity_attribution")}
WHERE is_closed_won = TRUE
GROUP BY 1, 2
HAVING ABS(weight_sum - 1.0) > 0.001
```

```javascript
// assert_no_unaccounted_attribution.sqlx
config {
  type: "assertion",
  tags: ["data_quality", "warehouse_marketing", "attribution"]
}

SELECT
  opportunity_pk,
  attribution_model,
  ROUND(SUM(attributed_revenue_usd), 2) as total_attributed,
  ROUND(MAX(opportunity_arr_usd), 2) as opportunity_arr
FROM ${ref("fct_opportunity_attribution")}
WHERE is_closed_won = TRUE
GROUP BY 1, 2
HAVING ABS(total_attributed - opportunity_arr) > 0.01
```
