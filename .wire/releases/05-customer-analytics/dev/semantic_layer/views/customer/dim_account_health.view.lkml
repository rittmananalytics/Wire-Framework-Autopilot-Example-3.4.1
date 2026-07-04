view: dim_account_health {
  sql_table_name: `core-dynamics-analytics-prod.mart_customer.dim_account_health` ;;

  # ── Primary Key ──────────────────────────────────────────────
  dimension: account_health_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.account_health_pk ;;
  }

  # ── Foreign Keys ─────────────────────────────────────────────
  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  # ── Date Dimensions ──────────────────────────────────────────
  dimension_group: score {
    type: time
    timeframes: [date, week, month, quarter, year]
    datatype: date
    sql: ${TABLE}.score_date ;;
    label: "Score"
  }

  # ── Health Score Dimensions ───────────────────────────────────
  dimension: health_score {
    type: number
    sql: ${TABLE}.health_score ;;
    label: "Health Score"
    description: "Composite health score 0–100 (product 30%, support 20%, financial 25%, relationship 15%, NPS 10%)"
    value_format_name: decimal_0
  }

  dimension: health_band {
    type: string
    sql: ${TABLE}.health_band ;;
    label: "Health Band"
    description: "At Risk (<40), Needs Attention (40–59), Healthy (60–79), Excellent (≥80)"
    order_by_field: health_band_sort
  }

  dimension: health_band_sort {
    hidden: yes
    type: number
    sql: case ${TABLE}.health_band
           when 'At Risk'          then 1
           when 'Needs Attention'  then 2
           when 'Healthy'          then 3
           when 'Excellent'        then 4
           else 0
         end ;;
  }

  dimension: is_at_risk {
    type: yesno
    sql: ${TABLE}.is_at_risk ;;
    label: "Is At Risk"
    description: "TRUE if health score < 40"
  }

  dimension: score_trend_7d {
    type: string
    sql: ${TABLE}.score_trend_7d ;;
    label: "Score Trend (7 Day)"
    description: "improving / declining / stable relative to 7 days ago"
  }

  dimension: score_change_7d {
    type: number
    sql: ${TABLE}.score_change_7d ;;
    label: "Score Change (7 Day)"
    value_format_name: decimal_1
  }

  # ── Signal Components ─────────────────────────────────────────
  dimension: product_component {
    type: number
    sql: ${TABLE}.product_component ;;
    label: "Product Signal"
    description: "Normalised product engagement signal (0–1)"
    value_format_name: decimal_2
  }

  dimension: support_component {
    type: number
    sql: ${TABLE}.support_component ;;
    label: "Support Signal"
    description: "Normalised support health signal (0–1)"
    value_format_name: decimal_2
  }

  dimension: financial_component {
    type: number
    sql: ${TABLE}.financial_component ;;
    label: "Financial Signal"
    description: "Normalised financial health signal (0–1)"
    value_format_name: decimal_2
  }

  dimension: relationship_component {
    type: number
    sql: ${TABLE}.relationship_component ;;
    label: "Relationship Signal"
    description: "Normalised relationship health signal (0–1)"
    value_format_name: decimal_2
  }

  dimension: nps_component {
    type: number
    sql: ${TABLE}.nps_component ;;
    label: "NPS Signal"
    description: "Normalised NPS signal (0–1)"
    value_format_name: decimal_2
  }

  # ── Churn Risk (from BQML) ────────────────────────────────────
  dimension: churn_probability {
    type: number
    sql: ${TABLE}.churn_probability ;;
    label: "Churn Probability"
    description: "Predicted 12-month churn probability from BigQuery ML logistic regression (0–1)"
    value_format_name: percent_1
  }

  dimension: churn_risk_band {
    type: string
    sql: ${TABLE}.churn_risk_band ;;
    label: "Churn Risk Band"
    description: "Low (<20%), Medium (20–40%), High (40–65%), Critical (≥65%)"
    order_by_field: churn_risk_band_sort
  }

  dimension: churn_risk_band_sort {
    hidden: yes
    type: number
    sql: case ${TABLE}.churn_risk_band
           when 'Low'      then 1
           when 'Medium'   then 2
           when 'High'     then 3
           when 'Critical' then 4
           else 0
         end ;;
  }

  # ── Measures ──────────────────────────────────────────────────
  measure: count_accounts {
    type: count_distinct
    sql: ${account_pk} ;;
    label: "Accounts"
  }

  measure: count_at_risk {
    type: count_distinct
    sql: ${account_pk} ;;
    filters: [is_at_risk: "Yes"]
    label: "At-Risk Accounts"
  }

  measure: count_healthy {
    type: count_distinct
    sql: ${account_pk} ;;
    filters: [health_band: "Healthy,Excellent"]
    label: "Healthy Accounts"
  }

  measure: avg_health_score {
    type: average
    sql: ${health_score} ;;
    label: "Avg Health Score"
    value_format_name: decimal_1
  }

  measure: avg_churn_probability {
    type: average
    sql: ${churn_probability} ;;
    label: "Avg Churn Probability"
    value_format_name: percent_1
  }
}
