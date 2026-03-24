connection: "core_dynamics_bigquery"

label: "Core Dynamics Marketing Analytics"

# Include all marketing views
include: "/views/marketing/*.view.lkml"

# ─────────────────────────────────────────────────────────────────────────────
# Explore: Demand Generation Performance (MA-01 source)
# ─────────────────────────────────────────────────────────────────────────────
explore: demand_generation {
  label: "Demand Generation Performance"
  description: "Funnel volume, conversion rates, and spend efficiency — powers MA-01 dashboard"
  group_label: "Marketing Analytics"

  join: dim_contact {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_lead_funnel_events.contact_pk} = ${dim_contact.contact_pk} ;;
  }

  join: fct_campaign_spend {
    type: left_outer
    relationship: many_to_many
    sql_on: ${fct_lead_funnel_events.campaign_id} = ${fct_campaign_spend.campaign_fk} ;;
  }

  join: dim_campaign {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_campaign_spend.campaign_fk} = ${dim_campaign.campaign_pk} ;;
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Explore: Multi-Touch Attribution (MA-02 source — self-service)
# ─────────────────────────────────────────────────────────────────────────────
explore: marketing_attribution {
  label: "Multi-Touch Attribution Analysis"
  description: "Revenue attribution under 5 models — self-service explore for MA-02 dashboard. Filter by attribution_model to switch models (u_shaped is default)."
  group_label: "Marketing Analytics"

  # Primary fact: attribution credits per opportunity per touch per model
  from: fct_opportunity_attribution

  join: fct_attribution_touches {
    type: left_outer
    relationship: many_to_one
    sql_on: ${marketing_attribution.touch_pk} = ${fct_attribution_touches.touch_pk} ;;
  }

  join: dim_contact {
    type: left_outer
    relationship: many_to_one
    sql_on: ${marketing_attribution.contact_pk} = ${dim_contact.contact_pk} ;;
  }

  join: dim_campaign {
    type: left_outer
    relationship: many_to_one
    sql_on: ${marketing_attribution.campaign_fk} = ${dim_campaign.campaign_pk} ;;
  }

  join: fct_campaign_spend {
    type: left_outer
    relationship: many_to_many
    sql_on: ${marketing_attribution.campaign_fk} = ${fct_campaign_spend.campaign_fk} ;;
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Explore: Pipeline Contribution (MA-03 source)
# ─────────────────────────────────────────────────────────────────────────────
explore: pipeline_contribution {
  label: "Pipeline Contribution Report"
  description: "Marketing-sourced vs. sales-sourced pipeline, CAC trend, and marketing ROI — powers MA-03 executive dashboard"
  group_label: "Marketing Analytics"

  from: fct_opportunity_attribution

  join: dim_contact {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pipeline_contribution.contact_pk} = ${dim_contact.contact_pk} ;;
  }

  join: dim_campaign {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pipeline_contribution.campaign_fk} = ${dim_campaign.campaign_pk} ;;
  }

  join: fct_campaign_spend {
    type: left_outer
    relationship: many_to_many
    sql_on: ${pipeline_contribution.campaign_fk} = ${fct_campaign_spend.campaign_fk} ;;
  }
}
