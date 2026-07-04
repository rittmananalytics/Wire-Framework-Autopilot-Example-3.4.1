- dashboard: ma01_demand_gen_performance
  title: "MA-01: Demand Generation Performance"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Weekly operational dashboard for Monday marketing standup. Shows leads, MQLs, SALs, SQLs, spend, and funnel conversion for the last 7 days with period-over-period comparison."
  refresh: 1 day
  filters:
    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "7 days"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: demand_generation
      field: fct_lead_funnel_events.stage_entered_date

    - name: channel_filter
      title: "Channel"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      explore: demand_generation
      field: fct_lead_funnel_events.channel

  elements:

  # ─── KPI Tiles Row ────────────────────────────────────────────────────────
  - title: "Leads (Last 7 Days)"
    name: kpi_leads
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_lead_funnel_events.count_leads]
    filters:
      fct_lead_funnel_events.stage_name: "lead"
    comparison_type: change
    comparison_reverse_colors: false
    show_comparison: true
    row: 0
    col: 0
    width: 4
    height: 3

  - title: "MQLs (Last 7 Days)"
    name: kpi_mqls
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_lead_funnel_events.count_mqls]
    comparison_type: change
    show_comparison: true
    row: 0
    col: 4
    width: 4
    height: 3

  - title: "SALs (Last 7 Days)"
    name: kpi_sals
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_lead_funnel_events.count_sals]
    comparison_type: change
    show_comparison: true
    row: 0
    col: 8
    width: 4
    height: 3

  - title: "SQLs (Last 7 Days)"
    name: kpi_sqls
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_lead_funnel_events.count_sqls]
    comparison_type: change
    show_comparison: true
    row: 0
    col: 12
    width: 4
    height: 3

  - title: "Total Spend (Last 7 Days)"
    name: kpi_spend
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_campaign_spend.total_spend]
    comparison_type: change
    show_comparison: true
    row: 0
    col: 16
    width: 4
    height: 3

  # ─── Funnel Volume — Last 13 Weeks ────────────────────────────────────────
  - title: "Funnel Volume — Last 13 Weeks"
    name: funnel_volume_13w
    model: marketing
    explore: demand_generation
    type: looker_column
    fields:
      - fct_lead_funnel_events.stage_entered_week
      - fct_lead_funnel_events.stage_name
      - fct_lead_funnel_events.count_leads
    pivots: [fct_lead_funnel_events.stage_name]
    filters:
      fct_lead_funnel_events.stage_name: "lead,mql,sal,sql,opportunity"
    sorts: [fct_lead_funnel_events.stage_entered_week asc]
    limit: 13
    dynamic_fields:
      - category: filter
        filter_field: fct_lead_funnel_events.stage_entered_week
        filter_value: "13 weeks ago for 13 weeks"
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: right
    row: 3
    col: 0
    width: 14
    height: 8

  # ─── Funnel Conversion Rates ──────────────────────────────────────────────
  - title: "Funnel Conversion Rates"
    name: funnel_conversion
    model: marketing
    explore: demand_generation
    type: looker_bar
    fields:
      - fct_lead_funnel_events.mql_to_sal_rate
      - fct_lead_funnel_events.sal_to_sql_rate
      - fct_lead_funnel_events.sql_to_opportunity_rate
    row: 3
    col: 14
    width: 10
    height: 4

  # ─── Spend by Channel ─────────────────────────────────────────────────────
  - title: "Spend by Channel — This Month vs Last"
    name: spend_by_channel
    model: marketing
    explore: demand_generation
    type: looker_column
    fields:
      - dim_campaign.channel
      - fct_campaign_spend.total_spend
      - fct_campaign_spend.spend_month
    pivots: [fct_campaign_spend.spend_month]
    sorts: [fct_campaign_spend.total_spend desc]
    limit: 10
    row: 7
    col: 14
    width: 10
    height: 4

  # ─── Top 10 Campaigns by Pipeline ─────────────────────────────────────────
  - title: "Top 10 Campaigns by Pipeline Generated"
    name: top_campaigns
    model: marketing
    explore: marketing_attribution
    type: looker_grid
    fields:
      - dim_campaign.campaign_name
      - dim_campaign.channel
      - fct_campaign_spend.total_spend
      - fct_opportunity_attribution.attributed_pipeline
      - fct_opportunity_attribution.attributed_revenue
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    sorts: [fct_opportunity_attribution.attributed_pipeline desc]
    limit: 10
    subtotals: []
    show_totals: true
    show_row_numbers: true
    row: 11
    col: 0
    width: 24
    height: 7

  # ─── Cost per MQL/SQL by Channel ─────────────────────────────────────────
  - title: "Cost per MQL and SQL by Channel"
    name: cost_per_mql_sql
    model: marketing
    explore: demand_generation
    type: looker_grid
    fields:
      - dim_campaign.channel
      - fct_campaign_spend.total_spend
      - fct_lead_funnel_events.count_mqls
      - fct_lead_funnel_events.count_sqls
    sorts: [fct_campaign_spend.total_spend desc]
    limit: 10
    dynamic_fields:
      - category: table_calculation
        label: "Cost per MQL"
        expression: "${fct_campaign_spend.total_spend} / nullif(${fct_lead_funnel_events.count_mqls}, 0)"
        value_format_name: usd_0
      - category: table_calculation
        label: "Cost per SQL"
        expression: "${fct_campaign_spend.total_spend} / nullif(${fct_lead_funnel_events.count_sqls}, 0)"
        value_format_name: usd_0
    row: 18
    col: 0
    width: 16
    height: 5

  # ─── Data Coverage Tile ────────────────────────────────────────────────────
  - title: "⚠ UTM Attribution Coverage"
    name: utm_coverage
    model: marketing
    explore: demand_generation
    type: single_value
    fields: [fct_attribution_touches.utm_coverage_rate]
    color_application:
      collection_id: "b43731d5-dc87-4a8e-b807-635bef3948e7"
      palette_id: "tomato-to-green"
    row: 18
    col: 16
    width: 8
    height: 5
    note_state: collapsed
    note_display: hover
    note_text: "~30% of touches lack UTM parameters and cannot be attributed to a campaign. These are tagged 'unattributed' channel and retained in all calculations. Improving UTM tagging will improve attribution accuracy."
