view: fct_feature_usage {
  sql_table_name: `core-dynamics-analytics-prod.mart_product.fct_feature_usage` ;;

  dimension: event_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.event_pk ;;
  }

  # user_pk deliberately not exposed — PII pseudonymised; not actionable in Looker
  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension: module_id {
    group_label: "Feature Taxonomy"
    label: "Module ID"
    type: string
    sql: ${TABLE}.module_id ;;
  }

  dimension: module_name {
    group_label: "Feature Taxonomy"
    label: "Module"
    type: string
    sql: ${TABLE}.module_name ;;
  }

  dimension: feature_group_id {
    group_label: "Feature Taxonomy"
    label: "Feature Group ID"
    hidden: yes
    type: string
    sql: ${TABLE}.feature_group_id ;;
  }

  dimension: feature_group_name {
    group_label: "Feature Taxonomy"
    label: "Feature Group"
    type: string
    sql: ${TABLE}.feature_group_name ;;
  }

  dimension: feature_id {
    group_label: "Feature Taxonomy"
    label: "Feature ID"
    type: string
    sql: ${TABLE}.feature_id ;;
  }

  dimension: feature_name {
    group_label: "Feature Taxonomy"
    label: "Feature"
    type: string
    sql: ${TABLE}.feature_name ;;
  }

  dimension: event_name {
    label: "Raw Event Name"
    group_label: "Event Detail"
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: source_system {
    group_label: "Event Detail"
    label: "Source"
    type: string
    sql: ${TABLE}.source_system ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, month, quarter, year]
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  measure: event_count {
    type: count
    label: "Event Count"
    drill_fields: [feature_name, feature_group_name, module_name]
  }

  measure: distinct_accounts_using_feature {
    type: count_distinct
    sql: ${TABLE}.account_pk ;;
    label: "Accounts Using Feature"
  }

  measure: distinct_features_used {
    type: count_distinct
    sql: ${TABLE}.feature_id ;;
    label: "Distinct Features Used"
  }

  measure: feature_adoption_rate {
    type: number
    sql: ${distinct_accounts_using_feature} / nullif((select count(*) from `core-dynamics-analytics-prod.mart_product.dim_account` where is_active), 0) ;;
    label: "Feature Adoption Rate"
    value_format_name: percent_1
  }
}
