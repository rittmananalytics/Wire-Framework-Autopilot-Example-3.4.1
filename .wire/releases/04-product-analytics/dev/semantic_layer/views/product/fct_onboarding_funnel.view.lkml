view: fct_onboarding_funnel {
  sql_table_name: `core-dynamics-analytics-prod.mart_product.fct_onboarding_funnel` ;;

  dimension: onboarding_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.onboarding_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension: account_name {
    label: "Account Name"
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: csm_name {
    label: "CSM"
    type: string
    sql: ${TABLE}.csm_name ;;
  }

  dimension: segment {
    label: "Segment"
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: step_id {
    hidden: yes
    type: string
    sql: ${TABLE}.step_id ;;
  }

  dimension: step_name {
    label: "Onboarding Step"
    type: string
    sql: ${TABLE}.step_name ;;
  }

  dimension: step_order {
    label: "Step Order"
    type: number
    sql: ${TABLE}.step_order ;;
  }

  dimension: is_core_step {
    label: "Is Core Step"
    type: yesno
    sql: ${TABLE}.is_core_step ;;
  }

  dimension: is_complete {
    label: "Step Complete"
    type: yesno
    sql: ${TABLE}.is_complete ;;
  }

  dimension: days_since_signup {
    label: "Days to Complete (since signup)"
    type: number
    sql: ${TABLE}.days_since_signup ;;
  }

  dimension: is_stalled {
    label: "Is Stalled"
    description: "TRUE if step not complete and account has been live > 14 days (configurable)"
    type: yesno
    sql: ${TABLE}.is_stalled ;;
  }

  dimension_group: completed {
    type: time
    timeframes: [date, week, month]
    datatype: timestamp
    sql: ${TABLE}.completed_at ;;
    label: "Completed"
  }

  measure: accounts_completing_step {
    type: count_distinct
    sql: case when ${is_complete} then ${account_pk} end ;;
    label: "Accounts Completing Step"
  }

  measure: step_completion_rate {
    type: number
    sql: ${accounts_completing_step} / nullif(count(distinct ${account_pk}), 0) ;;
    label: "Step Completion Rate"
    value_format_name: percent_1
  }

  measure: stalled_account_count {
    type: count_distinct
    sql: case when ${is_stalled} then ${account_pk} end ;;
    label: "Stalled Accounts"
  }

  measure: avg_days_to_complete {
    type: average
    sql: ${days_since_signup} ;;
    label: "Avg Days to Complete"
    filters: [is_complete: "Yes"]
    value_format_name: decimal_1
  }
}
