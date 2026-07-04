view: fct_campaign_spend {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.fct_campaign_spend` ;;

  dimension: spend_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.spend_pk ;;
  }

  dimension: campaign_fk {
    hidden: yes
    type: string
    sql: ${TABLE}.campaign_fk ;;
  }

  dimension_group: spend {
    label: "Spend Date"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.spend_date ;;
  }

  dimension: platform {
    label: "Ad Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: campaign_name {
    label: "Campaign Name"
    type: string
    sql: ${TABLE}.campaign_name ;;
  }

  dimension: ad_group_name {
    label: "Ad Group / Ad Set"
    type: string
    sql: ${TABLE}.ad_group_name ;;
  }

  # ─── Measures ─────────────────────────────────────────────────────────────
  measure: total_spend {
    label: "Total Spend"
    type: sum
    sql: ${TABLE}.spend_usd ;;
    value_format_name: usd_0
    drill_fields: [spend_date, platform, campaign_name, total_spend]
  }

  measure: total_impressions {
    label: "Impressions"
    type: sum
    sql: ${TABLE}.impressions ;;
    value_format_name: decimal_0
  }

  measure: total_clicks {
    label: "Clicks"
    type: sum
    sql: ${TABLE}.clicks ;;
    value_format_name: decimal_0
  }

  measure: avg_ctr {
    label: "CTR"
    type: number
    sql: ${total_clicks} / nullif(${total_impressions}, 0) ;;
    value_format_name: percent_2
  }

  measure: avg_cpc {
    label: "CPC"
    type: number
    sql: ${total_spend} / nullif(${total_clicks}, 0) ;;
    value_format_name: usd
  }
}
