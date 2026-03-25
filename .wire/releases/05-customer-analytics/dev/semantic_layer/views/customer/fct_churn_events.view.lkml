view: fct_churn_events {
  sql_table_name: `core-dynamics-analytics-prod.mart_customer.fct_churn_events` ;;

  dimension: churn_event_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.churn_event_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, month, quarter, year]
    datatype: date
    sql: ${TABLE}.event_date ;;
    label: "Churn Event"
  }

  dimension: churn_type {
    type: string
    sql: ${TABLE}.churn_type ;;
    label: "Churn Type"
    description: "full_churn, contraction, or non_renewal"
  }

  dimension: reason_category {
    type: string
    sql: ${TABLE}.reason_category ;;
    label: "Churn Reason Category"
  }

  dimension: reason_detail {
    type: string
    sql: ${TABLE}.reason_detail ;;
    label: "Churn Reason Detail"
  }

  dimension: csm_owner {
    type: string
    sql: ${TABLE}.csm_owner ;;
    label: "CSM at Churn"
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}.source_system ;;
    label: "Data Source"
  }

  # ARR impacted (finance-restricted)
  dimension: arr_impacted {
    type: number
    sql: ${TABLE}.arr_impacted ;;
    label: "ARR Impacted"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: count_churn_events {
    type: count_distinct
    sql: ${churn_event_pk} ;;
    label: "Churn Events"
  }

  measure: total_arr_churned {
    type: sum
    sql: ${arr_impacted} ;;
    label: "Total ARR Churned"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: count_full_churns {
    type: count_distinct
    sql: ${churn_event_pk} ;;
    filters: [churn_type: "full_churn"]
    label: "Full Churn Events"
  }
}
