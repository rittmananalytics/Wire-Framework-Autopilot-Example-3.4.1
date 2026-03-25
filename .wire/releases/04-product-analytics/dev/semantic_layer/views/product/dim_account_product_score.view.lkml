view: dim_account_product_score {
  sql_table_name: `core-dynamics-analytics-prod.mart_product.dim_account_product_score` ;;

  dimension: score_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.score_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension_group: score {
    type: time
    timeframes: [month, quarter, year]
    datatype: date
    sql: ${TABLE}.score_month ;;
    label: "Score"
  }

  dimension: product_engagement_score {
    label: "Product Engagement Score"
    description: "Composite 0–100 score from 7 weighted signals"
    type: number
    sql: ${TABLE}.product_engagement_score ;;
  }

  dimension: score_band {
    label: "Score Band"
    type: string
    sql:
      case
        when ${TABLE}.product_engagement_score >= 80 then 'Excellent'
        when ${TABLE}.product_engagement_score >= 60 then 'Healthy'
        when ${TABLE}.product_engagement_score >= 40 then 'Needs Attention'
        else 'At Risk'
      end ;;
  }

  dimension: dau_mau_ratio {
    group_label: "Score Components"
    label: "DAU/MAU Ratio"
    type: number
    sql: ${TABLE}.dau_mau_ratio ;;
    value_format_name: decimal_2
  }

  dimension: active_users_30d {
    group_label: "Score Components"
    label: "Active Users (30d)"
    type: number
    sql: ${TABLE}.active_users_30d ;;
  }

  dimension: distinct_features_used {
    group_label: "Score Components"
    label: "Distinct Features Used"
    type: number
    sql: ${TABLE}.distinct_features_used ;;
  }

  dimension: core_activation_score {
    group_label: "Score Components"
    label: "Core Activation Score"
    type: number
    sql: ${TABLE}.core_activation_score ;;
    value_format_name: percent_1
  }

  dimension: work_order_within_30_days {
    group_label: "Score Components"
    label: "Work Order Within 30 Days"
    description: "Critical retention signal: first work order created within 30 days of contract start"
    type: yesno
    sql: ${TABLE}.work_order_within_30_days ;;
  }

  dimension: licence_utilisation_pct {
    group_label: "Score Components"
    label: "Licence Utilisation %"
    description: "Active users / contracted seats. NULL if contracted seats not on file."
    type: number
    sql: ${TABLE}.licence_utilisation_pct ;;
    value_format_name: percent_1
  }

  dimension: onboarding_completion_pct {
    group_label: "Score Components"
    label: "Onboarding Completion %"
    type: number
    sql: ${TABLE}.onboarding_completion_pct ;;
    value_format_name: percent_1
  }

  dimension: core_steps_completed {
    group_label: "Score Components"
    label: "Core Steps Completed"
    type: number
    sql: ${TABLE}.core_steps_completed ;;
  }

  dimension: nps_score_last_response {
    group_label: "Score Components"
    label: "NPS Score (Last Response)"
    type: number
    sql: ${TABLE}.nps_score_last_response ;;
  }

  dimension: is_at_risk {
    label: "Is At Risk"
    type: yesno
    sql: ${TABLE}.is_at_risk ;;
  }

  measure: avg_product_engagement_score {
    type: average
    sql: ${TABLE}.product_engagement_score ;;
    label: "Avg Engagement Score"
    value_format_name: decimal_0
  }

  measure: at_risk_account_count {
    type: count_distinct
    sql: case when ${TABLE}.is_at_risk then ${TABLE}.account_pk end ;;
    label: "At-Risk Accounts"
  }

  measure: avg_dau_mau {
    type: average
    sql: ${TABLE}.dau_mau_ratio ;;
    label: "Avg DAU/MAU"
    value_format_name: decimal_2
  }

  measure: avg_licence_utilisation {
    type: average
    sql: ${TABLE}.licence_utilisation_pct ;;
    label: "Avg Licence Utilisation"
    value_format_name: percent_1
  }
}
