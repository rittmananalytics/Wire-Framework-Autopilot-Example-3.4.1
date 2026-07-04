- dashboard: ca01_customer_health
  title: "CA-01 Customer Health Command Centre"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Portfolio-level account health overview — health distribution, at-risk ARR, churn trend, and renewal pipeline"

  filters:
    - name: segment
      title: "Segment"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: customer_health
      field: dim_account.segment

    - name: csm_owner
      title: "CSM Owner"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: customer_health
      field: fct_csm_book_of_business.csm_owner

    - name: region
      title: "Region"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: customer_health
      field: dim_account.region

    - name: score_date
      title: "Score Date"
      type: date_filter
      default_value: "7 days"
      allow_multiple_values: false
      required: false

  elements:
    # KPI: Healthy Accounts
    - title: "Healthy + Excellent Accounts"
      name: kpi_healthy
      explore: customer_health
      type: single_value
      fields: [dim_account_health.count_healthy]
      custom_color_enabled: true
      custom_color: "#27AE60"
      row: 0
      col: 0
      width: 4
      height: 3

    # KPI: Needs Attention
    - title: "Needs Attention"
      name: kpi_needs_attention
      explore: customer_health
      type: single_value
      fields: [dim_account_health.count_accounts]
      filters:
        dim_account_health.health_band: "Needs Attention"
      custom_color: "#F39C12"
      row: 0
      col: 4
      width: 4
      height: 3

    # KPI: At Risk
    - title: "At-Risk Accounts"
      name: kpi_at_risk
      explore: customer_health
      type: single_value
      fields: [dim_account_health.count_at_risk]
      custom_color: "#E74C3C"
      row: 0
      col: 8
      width: 4
      height: 3

    # KPI: At-Risk ARR
    - title: "At-Risk ARR"
      name: kpi_arr_at_risk
      explore: customer_health
      type: single_value
      fields: [fct_renewal_pipeline.arr_at_risk_usd]
      custom_color: "#E74C3C"
      row: 0
      col: 12
      width: 4
      height: 3

    # KPI: Avg Churn Probability
    - title: "Avg Churn Probability"
      name: kpi_churn_prob
      explore: customer_health
      type: single_value
      fields: [dim_account_health.avg_churn_probability]
      row: 0
      col: 16
      width: 4
      height: 3

    # Health Score Distribution (stacked bar, 12 months)
    - title: "Health Score Distribution (12 Months)"
      name: health_distribution
      explore: customer_health
      type: looker_bar
      fields: [dim_account_health.score_month, dim_account_health.count_accounts, dim_account_health.health_band]
      pivots: [dim_account_health.health_band]
      stacking: normal
      series_colors:
        At Risk: "#E74C3C"
        Needs Attention: "#F39C12"
        Healthy: "#2ECC71"
        Excellent: "#1ABC9C"
      row: 3
      col: 0
      width: 12
      height: 8

    # Renewal Pipeline (grouped bar)
    - title: "Renewal Pipeline by Window"
      name: renewal_pipeline
      explore: customer_health
      type: looker_bar
      fields: [fct_renewal_pipeline.renewal_bucket, fct_renewal_pipeline.total_arr_usd, fct_renewal_pipeline.count_renewals]
      sorts: [fct_renewal_pipeline.renewal_bucket_sort]
      series_colors:
        total_arr_usd: "#3498DB"
      row: 3
      col: 12
      width: 12
      height: 8

    # Churn Trend (NRR/GRR line)
    - title: "NRR / GRR Trend (12 Months)"
      name: churn_trend
      explore: cs_leadership
      type: looker_line
      fields: [fct_nrr_grr.month_month, fct_nrr_grr.avg_nrr_trailing_12m, fct_nrr_grr.avg_grr_trailing_12m]
      sorts: [fct_nrr_grr.month_month]
      series_labels:
        fct_nrr_grr.avg_nrr_trailing_12m: "NRR %"
        fct_nrr_grr.avg_grr_trailing_12m: "GRR %"
      reference_lines:
        - reference_type: line
          line_value: "115"
          label: "NRR Target"
          label_position: right
          color: "#1ABC9C"
      row: 11
      col: 0
      width: 12
      height: 7

    # Expansion Signals
    - title: "Expansion Opportunities"
      name: expansion_signals
      explore: customer_health
      type: looker_bar
      fields: [fct_expansion_signals.signal_type, dim_account_health.count_accounts]
      row: 11
      col: 12
      width: 12
      height: 7

    # At-Risk Account Table
    - title: "At-Risk Accounts"
      name: at_risk_table
      explore: customer_health
      type: table
      fields:
        - dim_account.account_name
        - fct_renewal_pipeline.total_arr_usd
        - dim_account_health.health_score
        - dim_account_health.churn_risk_band
        - fct_renewal_pipeline.days_to_renewal
        - fct_csm_book_of_business.csm_owner
      filters:
        dim_account_health.is_at_risk: "Yes"
      sorts: [fct_renewal_pipeline.days_to_renewal asc]
      limit: 25
      column_order: [dim_account.account_name, fct_renewal_pipeline.total_arr_usd, dim_account_health.health_score, dim_account_health.churn_risk_band, fct_renewal_pipeline.days_to_renewal, fct_csm_book_of_business.csm_owner]
      row: 18
      col: 0
      width: 24
      height: 8
