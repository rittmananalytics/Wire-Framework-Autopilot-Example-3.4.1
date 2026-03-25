connection: "core_dynamics_prod"

include: "/views/product/*.view.lkml"

# Explore 1: Feature Adoption (PB-01)
explore: feature_adoption {
  label: "Feature Adoption"
  description: "Product feature usage events with 3-level taxonomy. Use for PB-01 heatmap and module-level adoption analysis."

  join: dim_account {
    type: left_outer
    sql_on: ${fct_feature_usage.account_pk} = ${dim_account.account_pk} ;;
    relationship: many_to_one
  }
}

# Explore 2: Account Product Usage (PB-02)
explore: account_product_usage {
  label: "Account Product Usage"
  description: "Account-level product engagement: scores, DAU/MAU, feature breadth, onboarding status. Use for PB-02 account drill-through."
  from: dim_account

  join: dim_account_product_score {
    type: left_outer
    sql_on: ${dim_account.account_pk} = ${dim_account_product_score.account_pk} ;;
    relationship: one_to_many
  }

  join: fct_onboarding_funnel {
    type: left_outer
    sql_on: ${dim_account.account_pk} = ${fct_onboarding_funnel.account_pk} ;;
    relationship: one_to_many
  }
}

# Explore 3: Onboarding Funnel (PB-03)
explore: onboarding_funnel {
  label: "Onboarding Funnel"
  description: "Onboarding step completion per account with stalled flags. Use for PB-03 CSM intervention dashboard."

  join: dim_account {
    type: left_outer
    sql_on: ${fct_onboarding_funnel.account_pk} = ${dim_account.account_pk} ;;
    relationship: many_to_one
  }
}
