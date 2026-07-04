view: fct_csm_book_of_business {
  sql_table_name: `core-dynamics-analytics-prod.mart_customer.fct_csm_book_of_business` ;;

  dimension: account_csm_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.account_csm_pk ;;
  }

  dimension: account_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  # ── RLS Field — used in explore sql_always_where ──────────────
  dimension: csm_owner {
    type: string
    sql: ${TABLE}.csm_owner ;;
    label: "CSM Owner"
    description: "Used for row-level security — each CSM sees only their accounts"
  }

  dimension_group: snapshot {
    type: time
    timeframes: [date]
    datatype: date
    sql: ${TABLE}.snapshot_date ;;
    label: "Snapshot"
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
    label: "Account"
    link: {
      label: "View in CA-01"
      url: "/dashboards/customer_health?Account={{ value | encode_uri }}"
    }
  }

  dimension: segment {
    type: string
    sql: ${TABLE}.segment ;;
    label: "Segment"
  }

  dimension: health_score {
    type: number
    sql: ${TABLE}.health_score ;;
    label: "Health Score"
    value_format_name: decimal_0
  }

  dimension: health_band {
    type: string
    sql: ${TABLE}.health_band ;;
    label: "Health Band"
  }

  dimension: health_score_7d_change {
    type: number
    sql: ${TABLE}.health_score_7d_change ;;
    label: "Health Change (7 Day)"
    value_format_name: decimal_1
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

  dimension_group: renewal {
    type: time
    timeframes: [date, month]
    datatype: date
    sql: ${TABLE}.renewal_date ;;
    label: "Renewal"
  }

  dimension: days_to_renewal {
    type: number
    sql: ${TABLE}.days_to_renewal ;;
    label: "Days to Renewal"
  }

  dimension: open_support_tickets {
    type: number
    sql: ${TABLE}.open_support_tickets ;;
    label: "Open Support Tickets"
  }

  dimension: overdue_onboarding_steps {
    type: number
    sql: ${TABLE}.overdue_onboarding_steps ;;
    label: "Overdue Onboarding Steps"
  }

  dimension: nps_score_latest {
    type: number
    sql: ${TABLE}.nps_score_latest ;;
    label: "Latest NPS Score"
    value_format_name: decimal_0
  }

  dimension: expansion_signal_active {
    type: yesno
    sql: ${TABLE}.expansion_signal_active ;;
    label: "Expansion Signal"
  }

  dimension_group: last_qbr {
    type: time
    timeframes: [date, month]
    datatype: date
    sql: ${TABLE}.last_qbr_date ;;
    label: "Last QBR"
  }

  dimension: days_since_qbr {
    type: number
    sql: ${TABLE}.days_since_qbr ;;
    label: "Days Since Last QBR"
  }

  # ── ARR (finance-restricted) ──────────────────────────────────
  dimension: arr_usd {
    type: number
    sql: ${TABLE}.arr_usd ;;
    label: "ARR (USD)"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
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

  measure: count_renewals_90d {
    type: count_distinct
    sql: ${account_pk} ;;
    filters: [days_to_renewal: "<=90"]
    label: "Renewals <90 Days"
  }

  measure: count_expansion_signals {
    type: count_distinct
    sql: ${account_pk} ;;
    filters: [expansion_signal_active: "Yes"]
    label: "Accounts with Expansion Signal"
  }

  measure: total_open_actions {
    type: sum
    sql: ${open_support_tickets} + ${overdue_onboarding_steps} ;;
    label: "Total Open Actions"
  }

  measure: avg_health_score {
    type: average
    sql: ${health_score} ;;
    label: "Avg Health Score"
    value_format_name: decimal_1
  }

  measure: total_arr_usd {
    type: sum
    sql: ${TABLE}.arr_usd ;;
    label: "Total ARR"
    value_format_name: usd_0
    required_access_grants: [finance_viewers, leadership]
  }
}
