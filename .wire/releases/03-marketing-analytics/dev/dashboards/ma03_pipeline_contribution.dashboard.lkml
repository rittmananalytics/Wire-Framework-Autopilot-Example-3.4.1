- dashboard: ma03_pipeline_contribution
  title: "MA-03: Pipeline Contribution Report"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Monthly executive dashboard for board prep. Marketing-sourced vs. sales-sourced pipeline, CAC trend, marketing ROI. Audience: CEO, CRO, VP Marketing."
  refresh: 1 week
  filters:
    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "12 months"
      explore: pipeline_contribution
      field: fct_opportunity_attribution.opportunity_close_date

  elements:

  # ─── KPI Row ──────────────────────────────────────────────────────────────
  - title: "Marketing-Sourced Pipeline"
    name: kpi_sourced_pipeline
    model: marketing
    explore: pipeline_contribution
    type: single_value
    fields: [fct_opportunity_attribution.marketing_sourced_revenue]
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    comparison_type: progress_percentage
    comparison_label: "of total pipeline"
    row: 0
    col: 0
    width: 8
    height: 3

  - title: "Marketing-Influenced Pipeline"
    name: kpi_influenced_pipeline
    model: marketing
    explore: pipeline_contribution
    type: single_value
    fields: [fct_opportunity_attribution.marketing_influenced_revenue]
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    row: 0
    col: 8
    width: 8
    height: 3

  - title: "Marketing ROI (Pipeline / Spend)"
    name: kpi_roi
    model: marketing
    explore: pipeline_contribution
    type: single_value
    dynamic_fields:
      - category: table_calculation
        label: "Pipeline ROI"
        expression: "${fct_opportunity_attribution.attributed_pipeline} / nullif(${fct_campaign_spend.total_spend}, 0)"
        value_format: "0.0\"×\""
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    row: 0
    col: 16
    width: 8
    height: 3

  # ─── Sourced vs Sales-Sourced Pipeline by Month ───────────────────────────
  - title: "Marketing-Sourced vs. Sales-Sourced Pipeline"
    name: sourced_vs_sales_pipeline
    model: marketing
    explore: pipeline_contribution
    type: looker_column
    fields:
      - fct_opportunity_attribution.opportunity_created_month
      - fct_opportunity_attribution.is_marketing_sourced
      - fct_opportunity_attribution.attributed_pipeline
    pivots: [fct_opportunity_attribution.is_marketing_sourced]
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    stacking: normal
    sorts: [fct_opportunity_attribution.opportunity_created_month asc]
    row: 3
    col: 0
    width: 14
    height: 8

  # ─── CAC by Quarter ────────────────────────────────────────────────────────
  - title: "Customer Acquisition Cost by Quarter"
    name: cac_by_quarter
    model: marketing
    explore: pipeline_contribution
    type: looker_column
    fields:
      - fct_campaign_spend.spend_quarter
      - fct_campaign_spend.total_spend
    sorts: [fct_campaign_spend.spend_quarter asc]
    dynamic_fields:
      - category: table_calculation
        label: "CAC"
        description: "Total spend / new customers acquired this quarter"
        expression: "${fct_campaign_spend.total_spend} / nullif(${fct_opportunity_attribution.count_attributed_opportunities}, 0)"
        value_format_name: usd_0
    row: 3
    col: 14
    width: 10
    height: 4

  # ─── Marketing ROI by Quarter ─────────────────────────────────────────────
  - title: "Marketing ROI by Quarter (Pipeline / Spend)"
    name: roi_by_quarter
    model: marketing
    explore: pipeline_contribution
    type: looker_line
    fields:
      - fct_campaign_spend.spend_quarter
    dynamic_fields:
      - category: table_calculation
        label: "Pipeline ROI"
        expression: "${fct_opportunity_attribution.attributed_pipeline} / nullif(${fct_campaign_spend.total_spend}, 0)"
        value_format: "0.0\"×\""
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
    sorts: [fct_campaign_spend.spend_quarter asc]
    row: 7
    col: 14
    width: 10
    height: 4

  # ─── Marketing-Influenced Revenue Table ──────────────────────────────────
  - title: "Marketing-Influenced Revenue by Quarter"
    name: influenced_revenue_table
    model: marketing
    explore: pipeline_contribution
    type: looker_grid
    fields:
      - fct_opportunity_attribution.opportunity_close_quarter
      - fct_opportunity_attribution.opportunity_arr
      - fct_opportunity_attribution.marketing_influenced_revenue
    filters:
      fct_opportunity_attribution.attribution_model: "u_shaped"
      fct_opportunity_attribution.is_closed_won: "yes"
    sorts: [fct_opportunity_attribution.opportunity_close_quarter desc]
    limit: 8
    dynamic_fields:
      - category: table_calculation
        label: "Influence Rate"
        expression: "${fct_opportunity_attribution.marketing_influenced_revenue} / nullif(${fct_opportunity_attribution.opportunity_arr}, 0)"
        value_format_name: percent_1
    row: 11
    col: 0
    width: 16
    height: 6

  # ─── LTV:CAC Placeholder ──────────────────────────────────────────────────
  - title: "LTV:CAC Ratio"
    name: ltv_cac_placeholder
    model: marketing
    explore: pipeline_contribution
    type: single_value
    fields: [fct_campaign_spend.total_spend]
    dynamic_fields:
      - category: table_calculation
        label: "Current Quarter CAC"
        expression: "${fct_campaign_spend.total_spend} / nullif(${fct_opportunity_attribution.count_attributed_opportunities}, 0)"
        value_format_name: usd_0
    note_state: expanded
    note_display: below
    note_text: "LTV data available in Customer Analytics release (Release 05, Q3 2026). LTV:CAC ratio will be calculated when available."
    row: 11
    col: 16
    width: 8
    height: 6
