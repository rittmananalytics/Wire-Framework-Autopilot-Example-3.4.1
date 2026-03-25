# Customer Analytics LookML Model
# Release: 05-customer-analytics
# Core Dynamics Data Platform Modernisation
#
# Explores:
#   customer_health        → CA-01 Customer Health Command Centre
#   csm_book_of_business   → CA-02 CSM Book of Business (RLS applied)
#   cs_leadership          → CA-03 CS Leadership Scorecard (financial metrics restricted)

connection: "core_dynamics_bigquery"

include: "/views/customer/*.view.lkml"

# ─────────────────────────────────────────────────────────────────
# EXPLORE: customer_health
# Used by CA-01 — portfolio-level health overview
# ─────────────────────────────────────────────────────────────────
explore: customer_health {
  label: "Customer Health"
  description: "Account health scores, churn risk, and renewal pipeline — portfolio view"

  join: dim_account {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_account_health.account_pk} = ${dim_account.account_pk} ;;
  }

  join: fct_renewal_pipeline {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_account_health.account_pk} = ${fct_renewal_pipeline.account_pk} ;;
  }

  join: fct_expansion_signals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_account_health.account_pk} = ${fct_expansion_signals.account_pk}
        and ${fct_expansion_signals.is_active} ;;
  }
}

# ─────────────────────────────────────────────────────────────────
# EXPLORE: csm_book_of_business
# Used by CA-02 — CSM book with RLS
#
# RLS: Looker user attribute 'csm_owner' filters fct_csm_book_of_business.csm_owner
# Leadership users (is_leadership=true) bypass the filter
# ─────────────────────────────────────────────────────────────────
explore: csm_book_of_business {
  label: "CSM Book of Business"
  description: "Per-CSM account view — filtered by csm_owner user attribute (RLS)"

  sql_always_where:
    {% if _user_attributes['is_leadership'] == 'true' %}
      1=1
    {% else %}
      ${fct_csm_book_of_business.csm_owner} = '{{ _user_attributes["csm_owner"] }}'
    {% endif %} ;;

  join: dim_account_health {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_csm_book_of_business.account_pk} = ${dim_account_health.account_pk}
        and ${dim_account_health.score_date} = current_date() - 1 ;;
  }

  join: fct_expansion_signals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fct_csm_book_of_business.account_pk} = ${fct_expansion_signals.account_pk}
        and ${fct_expansion_signals.is_active} ;;
  }
}

# ─────────────────────────────────────────────────────────────────
# EXPLORE: cs_leadership
# Used by CA-03 — CS leadership scorecard with NRR/GRR
#
# Financial measures (ARR, NRR, GRR) restricted to finance_viewers + leadership
# ─────────────────────────────────────────────────────────────────
explore: cs_leadership {
  label: "CS Leadership Scorecard"
  description: "NRR/GRR, churn trend, renewal pipeline — financial metrics restricted to leadership"

  join: dim_account {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fct_nrr_grr.account_pk} = ${dim_account.account_pk} ;;
  }

  join: fct_churn_events {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fct_nrr_grr.account_pk} = ${fct_churn_events.account_pk} ;;
  }

  join: fct_renewal_pipeline {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fct_nrr_grr.account_pk} = ${fct_renewal_pipeline.account_pk} ;;
  }

  join: dim_account_health {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fct_nrr_grr.account_pk} = ${dim_account_health.account_pk} ;;
  }
}
