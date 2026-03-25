view: fct_nrr_grr {
  sql_table_name: `core-dynamics-analytics-prod.mart_customer.fct_nrr_grr` ;;

  dimension: nrr_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.nrr_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension_group: month {
    type: time
    timeframes: [month, quarter, year]
    datatype: date
    sql: ${TABLE}.month_start ;;
    label: "Month"
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

  # ── All financial dimensions restricted to finance_viewers + leadership ──
  dimension: nrr {
    type: number
    sql: ${TABLE}.nrr ;;
    label: "NRR %"
    description: "Net Revenue Retention for the month: (Beginning ARR + Expansion - Contraction - Churn) / Beginning ARR × 100"
    value_format_name: decimal_1
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: grr {
    type: number
    sql: ${TABLE}.grr ;;
    label: "GRR %"
    description: "Gross Revenue Retention for the month: (Beginning ARR - Contraction - Churn) / Beginning ARR × 100"
    value_format_name: decimal_1
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: beginning_arr {
    type: number
    sql: ${TABLE}.beginning_arr ;;
    label: "Beginning ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: expansion_arr {
    type: number
    sql: ${TABLE}.expansion_arr ;;
    label: "Expansion ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: contraction_arr {
    type: number
    sql: ${TABLE}.contraction_arr ;;
    label: "Contraction ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: churn_arr {
    type: number
    sql: ${TABLE}.churn_arr ;;
    label: "Churned ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  dimension: ending_arr {
    type: number
    sql: ${TABLE}.ending_arr ;;
    label: "Ending ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  # ── Aggregate Measures (finance-restricted) ───────────────────
  measure: avg_nrr_trailing_12m {
    type: average
    sql: ${nrr} ;;
    label: "Avg NRR (Trailing 12M)"
    value_format_name: decimal_1
    required_access_grants: [finance_viewers, leadership]
  }

  measure: avg_grr_trailing_12m {
    type: average
    sql: ${grr} ;;
    label: "Avg GRR (Trailing 12M)"
    value_format_name: decimal_1
    required_access_grants: [finance_viewers, leadership]
  }

  measure: total_expansion_arr {
    type: sum
    sql: ${expansion_arr} ;;
    label: "Total Expansion ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: total_churn_arr {
    type: sum
    sql: ${churn_arr} ;;
    label: "Total Churned ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: total_contraction_arr {
    type: sum
    sql: ${contraction_arr} ;;
    label: "Total Contraction ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }

  measure: net_arr_movement {
    type: number
    sql: ${total_expansion_arr} - ${total_churn_arr} - ${total_contraction_arr} ;;
    label: "Net ARR Movement"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }
}
