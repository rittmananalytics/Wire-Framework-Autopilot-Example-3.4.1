view: fct_renewal_pipeline {
  sql_table_name: `core-dynamics-analytics-prod.mart_customer.fct_renewal_pipeline` ;;

  dimension: opportunity_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.opportunity_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
    label: "Account"
  }

  dimension: csm_owner {
    type: string
    sql: ${TABLE}.csm_owner ;;
    label: "CSM Owner"
  }

  dimension: segment {
    type: string
    sql: ${TABLE}.segment ;;
    label: "Segment"
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
    label: "Region"
  }

  dimension_group: renewal {
    type: time
    timeframes: [date, week, month, quarter]
    datatype: date
    sql: ${TABLE}.renewal_date ;;
    label: "Renewal"
  }

  dimension: renewal_stage {
    type: string
    sql: ${TABLE}.renewal_stage ;;
    label: "Renewal Stage"
  }

  dimension: days_to_renewal {
    type: number
    sql: ${TABLE}.days_to_renewal ;;
    label: "Days to Renewal"
  }

  dimension: renewal_bucket {
    type: string
    sql: ${TABLE}.renewal_bucket ;;
    label: "Renewal Window"
    order_by_field: renewal_bucket_sort
  }

  dimension: renewal_bucket_sort {
    hidden: yes
    type: number
    sql: case ${TABLE}.renewal_bucket
           when '0-30'   then 1
           when '31-60'  then 2
           when '61-90'  then 3
           when '91-180' then 4
           else 5
         end ;;
  }

  dimension: health_score {
    type: number
    sql: ${TABLE}.health_score ;;
    label: "Health Score at Renewal"
    value_format_name: decimal_0
  }

  dimension: health_band {
    type: string
    sql: ${TABLE}.health_band ;;
    label: "Health Band"
  }

  dimension: churn_risk_band {
    type: string
    sql: ${TABLE}.churn_risk_band ;;
    label: "Churn Risk Band"
  }

  dimension: churn_probability {
    type: number
    sql: ${TABLE}.churn_probability ;;
    label: "Churn Probability"
    value_format_name: percent_1
  }

  dimension: is_at_risk {
    type: yesno
    sql: ${TABLE}.is_at_risk ;;
    label: "Is At Risk"
  }

  # ── Financial Measures (finance_viewers + leadership only) ────
  measure: total_arr_usd {
    type: sum
    sql: ${TABLE}.arr_usd ;;
    label: "Total ARR (Renewal Pipeline)"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: weighted_arr_usd {
    type: sum
    sql: ${TABLE}.weighted_arr_usd ;;
    label: "Weighted ARR (Probability-Adjusted)"
    description: "ARR × (1 - Churn Probability)"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: arr_at_risk_usd {
    type: sum
    sql: ${TABLE}.arr_at_risk_usd ;;
    label: "ARR at Risk"
    description: "ARR × Churn Probability"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: count_renewals {
    type: count_distinct
    sql: ${opportunity_pk} ;;
    label: "Renewals"
  }

  measure: count_at_risk_renewals {
    type: count_distinct
    sql: ${opportunity_pk} ;;
    filters: [is_at_risk: "Yes"]
    label: "At-Risk Renewals"
  }
}
