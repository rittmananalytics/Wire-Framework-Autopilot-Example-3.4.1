view: fct_attribution_touches {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.fct_attribution_touches` ;;

  dimension: touch_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.touch_pk ;;
  }

  dimension: contact_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.contact_pk ;;
  }

  dimension: campaign_fk {
    hidden: yes
    type: string
    sql: ${TABLE}.campaign_fk ;;
  }

  dimension: touch_type {
    label: "Touch Type"
    type: string
    sql: ${TABLE}.touch_type ;;
  }

  dimension: channel {
    label: "Channel"
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension: source_system {
    label: "Source System"
    type: string
    sql: ${TABLE}.source_system ;;
  }

  dimension: asset_category {
    label: "Asset Category"
    type: string
    sql: ${TABLE}.asset_category ;;
  }

  dimension: is_attributed {
    label: "Has UTM Attribution"
    type: yesno
    sql: ${TABLE}.is_attributed ;;
  }

  dimension_group: touch {
    label: "Touch Date"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.touch_ts ;;
  }

  measure: count_touches {
    label: "Total Touches"
    type: count_distinct
    sql: ${touch_pk} ;;
    value_format_name: decimal_0
  }

  measure: count_attributed_touches {
    label: "Attributed Touches"
    type: count_distinct
    sql: case when ${is_attributed} then ${touch_pk} end ;;
    value_format_name: decimal_0
  }

  measure: utm_coverage_rate {
    label: "UTM Coverage Rate"
    type: number
    sql: ${count_attributed_touches} / nullif(${count_touches}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of touches with UTM parameters. Target ≥ 70%. ~30% gap documented."
  }

  measure: count_form_submissions {
    label: "Form Submissions"
    type: count_distinct
    sql: case when ${touch_type} = 'form_submit' then ${touch_pk} end ;;
    value_format_name: decimal_0
  }
}
