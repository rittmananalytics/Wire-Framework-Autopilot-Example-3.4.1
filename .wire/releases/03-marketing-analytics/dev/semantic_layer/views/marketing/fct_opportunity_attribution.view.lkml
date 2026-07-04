view: fct_opportunity_attribution {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.fct_opportunity_attribution` ;;

  dimension: attribution_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.attribution_pk ;;
  }

  dimension: opportunity_pk {
    hidden: yes
    type: string
    sql: ${TABLE}.opportunity_pk ;;
  }

  dimension: touch_pk {
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

  # ─── Attribution Model ────────────────────────────────────────────────────
  dimension: attribution_model {
    label: "Attribution Model"
    type: string
    sql: ${TABLE}.attribution_model ;;
    html: |
      {% if value == "u_shaped" %}
        <span style="font-weight: bold; color: #0078D4;">{{ value }}</span>
      {% else %}
        {{ value }}
      {% endif %} ;;
  }

  # ─── Touch Details ────────────────────────────────────────────────────────
  dimension: channel {
    label: "Channel"
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension: touch_rank {
    label: "Touch Rank in Journey"
    type: number
    sql: ${TABLE}.touch_rank ;;
  }

  dimension: days_before_opportunity {
    label: "Days Before Opportunity"
    type: number
    sql: ${TABLE}.days_before_opportunity ;;
  }

  dimension: touch_weight {
    label: "Touch Weight"
    type: number
    sql: ${TABLE}.touch_weight ;;
    value_format_name: percent_1
  }

  # ─── Attribution Flags ────────────────────────────────────────────────────
  dimension: is_marketing_sourced {
    label: "Marketing Sourced"
    group_label: "Attribution Flags"
    type: yesno
    sql: ${TABLE}.is_marketing_sourced ;;
  }

  dimension: is_marketing_influenced {
    label: "Marketing Influenced"
    group_label: "Attribution Flags"
    type: yesno
    sql: ${TABLE}.is_marketing_influenced ;;
  }

  dimension: is_closed_won {
    label: "Closed Won"
    type: yesno
    sql: ${TABLE}.is_closed_won ;;
  }

  # ─── Opportunity Dates ────────────────────────────────────────────────────
  dimension_group: opportunity_created {
    label: "Opportunity Created"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.opportunity_created_date ;;
  }

  dimension_group: opportunity_close {
    label: "Opportunity Close"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.opportunity_close_date ;;
  }

  # ─── Revenue Measures ─────────────────────────────────────────────────────
  measure: attributed_revenue {
    label: "Attributed Revenue"
    group_label: "Attribution"
    type: sum
    sql: ${TABLE}.attributed_revenue_usd ;;
    value_format_name: usd_0
    filters: [is_closed_won: "yes"]
    drill_fields: [attribution_model, channel, attributed_revenue]
  }

  measure: attributed_pipeline {
    label: "Attributed Pipeline"
    group_label: "Attribution"
    type: sum
    sql: ${TABLE}.attributed_pipeline_usd ;;
    value_format_name: usd_0
    drill_fields: [attribution_model, channel, attributed_pipeline]
  }

  measure: marketing_sourced_revenue {
    label: "Marketing-Sourced Revenue"
    group_label: "Sourced vs Influenced"
    type: sum
    sql: case when ${is_marketing_sourced} then ${TABLE}.attributed_revenue_usd end ;;
    value_format_name: usd_0
    filters: [is_closed_won: "yes"]
  }

  measure: marketing_influenced_revenue {
    label: "Marketing-Influenced Revenue"
    group_label: "Sourced vs Influenced"
    type: sum
    sql: case when ${is_marketing_influenced} then ${TABLE}.attributed_revenue_usd end ;;
    value_format_name: usd_0
    filters: [is_closed_won: "yes"]
  }

  measure: count_attributed_opportunities {
    label: "Attributed Opportunities"
    type: count_distinct
    sql: ${opportunity_pk} ;;
    filters: [is_closed_won: "yes"]
    value_format_name: decimal_0
  }

  measure: opportunity_arr {
    label: "Total Opportunity ARR"
    type: sum
    sql: ${TABLE}.opportunity_arr_usd / nullif(5, 0) ;;  -- divide by 5 models to avoid overcounting
    value_format_name: usd_0
    description: "Total ARR divided by number of attribution models to avoid double-counting"
  }
}
