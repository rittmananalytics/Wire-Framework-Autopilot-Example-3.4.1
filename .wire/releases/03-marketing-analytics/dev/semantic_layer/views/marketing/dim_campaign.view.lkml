view: dim_campaign {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.dim_campaign` ;;

  dimension: campaign_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.campaign_pk ;;
  }

  dimension: campaign_name {
    label: "Campaign Name"
    type: string
    sql: ${TABLE}.campaign_name ;;
    link: {
      label: "Explore in MA-02"
      url: "/explore/marketing/marketing_attribution?fields=fct_opportunity_attribution.attributed_revenue,fct_opportunity_attribution.channel&f[dim_campaign.campaign_name]={{ value | encode_uri }}"
    }
  }

  dimension: channel {
    label: "Channel"
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension: campaign_type {
    label: "Campaign Type"
    type: string
    sql: ${TABLE}.campaign_type ;;
  }

  dimension: target_segment {
    label: "Target Segment"
    type: string
    sql: ${TABLE}.target_segment ;;
  }

  dimension: source_system {
    label: "Source System"
    type: string
    sql: ${TABLE}.source_system ;;
  }

  dimension: is_active {
    label: "Is Active"
    type: yesno
    sql: ${TABLE}.is_active ;;
  }

  dimension: total_budget_usd {
    label: "Total Budget"
    type: number
    sql: ${TABLE}.total_budget_usd ;;
    value_format_name: usd_0
  }

  dimension_group: start {
    label: "Campaign Start"
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.start_date ;;
  }

  dimension_group: end {
    label: "Campaign End"
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.end_date ;;
  }

  measure: count_campaigns {
    label: "Campaigns"
    type: count_distinct
    sql: ${campaign_pk} ;;
    value_format_name: decimal_0
  }

  measure: total_budget {
    label: "Total Budget"
    type: sum
    sql: ${TABLE}.total_budget_usd ;;
    value_format_name: usd_0
  }
}
