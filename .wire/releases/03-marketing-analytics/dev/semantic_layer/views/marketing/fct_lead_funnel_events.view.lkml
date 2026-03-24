view: fct_lead_funnel_events {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.fct_lead_funnel_events` ;;

  # ─── Primary Key ──────────────────────────────────────────────────────────
  dimension: funnel_event_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.funnel_event_pk ;;
  }

  # ─── Foreign Keys ─────────────────────────────────────────────────────────
  dimension: contact_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.contact_pk ;;
  }

  dimension: account_fk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_fk ;;
  }

  dimension: campaign_id {
    hidden: yes
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  # ─── Funnel Stage Dimensions ──────────────────────────────────────────────
  dimension: stage_name {
    label: "Funnel Stage"
    group_label: "Funnel"
    type: string
    sql: ${TABLE}.stage_name ;;
  }

  dimension: stage_order {
    label: "Stage Order"
    group_label: "Funnel"
    type: number
    sql: ${TABLE}.stage_order ;;
  }

  dimension: is_converted {
    label: "Converted to Next Stage"
    group_label: "Funnel"
    type: yesno
    sql: ${TABLE}.is_converted ;;
  }

  dimension: is_current_stage {
    label: "Is Current Stage"
    group_label: "Funnel"
    type: yesno
    sql: ${TABLE}.is_current_stage ;;
  }

  dimension: days_in_stage {
    label: "Days in Stage"
    group_label: "Funnel"
    type: number
    sql: ${TABLE}.days_in_stage ;;
  }

  # ─── Date Dimensions ──────────────────────────────────────────────────────
  dimension_group: stage_entered {
    label: "Stage Entered"
    group_label: "Dates"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.stage_entered_ts ;;
  }

  dimension_group: stage_exited {
    label: "Stage Exited"
    group_label: "Dates"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.stage_exited_ts ;;
  }

  # ─── Channel ──────────────────────────────────────────────────────────────
  dimension: channel {
    label: "Channel"
    type: string
    sql: ${TABLE}.channel ;;
  }

  # ─── Measures ─────────────────────────────────────────────────────────────
  measure: count_leads {
    label: "Leads"
    group_label: "Funnel Volume"
    type: count_distinct
    sql: case when ${stage_name} = 'lead' then ${contact_pk} end ;;
    value_format_name: decimal_0
    drill_fields: [contact_pk, stage_entered_date, channel]
  }

  measure: count_mqls {
    label: "MQLs"
    group_label: "Funnel Volume"
    type: count_distinct
    sql: case when ${stage_name} = 'mql' then ${contact_pk} end ;;
    value_format_name: decimal_0
    drill_fields: [contact_pk, stage_entered_date, channel]
  }

  measure: count_sals {
    label: "SALs"
    group_label: "Funnel Volume"
    type: count_distinct
    sql: case when ${stage_name} = 'sal' then ${contact_pk} end ;;
    value_format_name: decimal_0
  }

  measure: count_sqls {
    label: "SQLs"
    group_label: "Funnel Volume"
    type: count_distinct
    sql: case when ${stage_name} = 'sql' then ${contact_pk} end ;;
    value_format_name: decimal_0
  }

  measure: count_opportunities {
    label: "Opportunities"
    group_label: "Funnel Volume"
    type: count_distinct
    sql: case when ${stage_name} = 'opportunity' then ${contact_pk} end ;;
    value_format_name: decimal_0
  }

  measure: mql_to_sal_rate {
    label: "MQL → SAL Rate"
    group_label: "Conversion Rates"
    type: number
    sql: ${count_sals} / nullif(${count_mqls}, 0) ;;
    value_format_name: percent_1
  }

  measure: sal_to_sql_rate {
    label: "SAL → SQL Rate"
    group_label: "Conversion Rates"
    type: number
    sql: ${count_sqls} / nullif(${count_sals}, 0) ;;
    value_format_name: percent_1
  }

  measure: sql_to_opportunity_rate {
    label: "SQL → Opportunity Rate"
    group_label: "Conversion Rates"
    type: number
    sql: ${count_opportunities} / nullif(${count_sqls}, 0) ;;
    value_format_name: percent_1
  }

  measure: avg_days_in_stage {
    label: "Avg Days in Stage"
    group_label: "Funnel Velocity"
    type: average
    sql: ${days_in_stage} ;;
    value_format_name: decimal_1
  }
}
