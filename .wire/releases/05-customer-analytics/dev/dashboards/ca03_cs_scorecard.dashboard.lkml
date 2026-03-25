- dashboard: ca03_cs_scorecard
  title: "CA-03 CS Leadership Scorecard"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "NRR/GRR trending, churn analysis, renewal at-risk pipeline — financial metrics restricted to Finance + Leadership"

  filters:
    - name: period
      title: "Period"
      type: date_filter
      default_value: "12 months"
      allow_multiple_values: false
      required: false

    - name: segment
      title: "Segment"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: cs_leadership
      field: dim_account.segment

    - name: region
      title: "Region"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: cs_leadership
      field: fct_nrr_grr.region

  elements:
    # KPI: Trailing 12M NRR
    - title: "NRR (Trailing 12M)"
      name: kpi_nrr
      explore: cs_leadership
      type: single_value
      fields: [fct_nrr_grr.avg_nrr_trailing_12m]
      custom_color: "#2ECC71"
      row: 0
      col: 0
      width: 4
      height: 3

    # KPI: Trailing 12M GRR
    - title: "GRR (Trailing 12M)"
      name: kpi_grr
      explore: cs_leadership
      type: single_value
      fields: [fct_nrr_grr.avg_grr_trailing_12m]
      row: 0
      col: 4
      width: 4
      height: 3

    # KPI: Net ARR Movement
    - title: "Net ARR Movement"
      name: kpi_net_arr
      explore: cs_leadership
      type: single_value
      fields: [fct_nrr_grr.net_arr_movement]
      row: 0
      col: 8
      width: 4
      height: 3

    # KPI: Total Churned ARR YTD
    - title: "Churned ARR (YTD)"
      name: kpi_churned_arr
      explore: cs_leadership
      type: single_value
      fields: [fct_churn_events.total_arr_churned]
      custom_color: "#E74C3C"
      row: 0
      col: 12
      width: 4
      height: 3

    # KPI: Expansion ARR YTD
    - title: "Expansion ARR (YTD)"
      name: kpi_expansion_arr
      explore: cs_leadership
      type: single_value
      fields: [fct_nrr_grr.total_expansion_arr]
      custom_color: "#1ABC9C"
      row: 0
      col: 16
      width: 4
      height: 3

    # NRR/GRR Trend (line chart)
    - title: "NRR / GRR Trend"
      name: nrr_grr_trend
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
          color: "#1ABC9C"
        - reference_type: line
          line_value: "100"
          label: "Baseline"
          color: "#7F8C8D"
      row: 3
      col: 0
      width: 12
      height: 8

    # ARR Bridge (waterfall)
    - title: "ARR Bridge (Trailing 12 Months)"
      name: arr_bridge
      explore: cs_leadership
      type: looker_column
      fields: [fct_nrr_grr.total_expansion_arr, fct_nrr_grr.total_contraction_arr, fct_nrr_grr.total_churn_arr, fct_nrr_grr.net_arr_movement]
      row: 3
      col: 12
      width: 12
      height: 8

    # Churn by Reason (bar chart)
    - title: "Churned ARR by Reason Category"
      name: churn_by_reason
      explore: cs_leadership
      type: looker_bar
      fields: [fct_churn_events.reason_category, fct_churn_events.total_arr_churned, fct_churn_events.count_churn_events]
      sorts: [fct_churn_events.total_arr_churned desc]
      limit: 10
      row: 11
      col: 0
      width: 12
      height: 7

    # Churn by Cohort (months since contract start)
    - title: "Churn Rate by Account Cohort"
      name: churn_by_cohort
      explore: cs_leadership
      type: looker_bar
      fields: [fct_churn_events.count_churn_events, dim_account.segment]
      pivots: [dim_account.segment]
      row: 11
      col: 12
      width: 12
      height: 7

    # At-Risk Renewal Table
    - title: "Renewal Pipeline at Risk (Next 90 Days)"
      name: at_risk_renewals
      explore: cs_leadership
      type: table
      fields:
        - dim_account.account_name
        - fct_renewal_pipeline.total_arr_usd
        - dim_account_health.health_score
        - dim_account_health.churn_risk_band
        - fct_renewal_pipeline.renewal_date
        - fct_renewal_pipeline.csm_owner
      filters:
        dim_account_health.is_at_risk: "Yes"
        fct_renewal_pipeline.renewal_bucket: "0-30,31-60,61-90"
      sorts: [fct_renewal_pipeline.renewal_date asc]
      limit: 25
      row: 18
      col: 0
      width: 24
      height: 8

    # CSM Performance (non-financial)
    - title: "CSM Health Outcomes"
      name: csm_performance
      explore: cs_leadership
      type: table
      fields:
        - fct_csm_book_of_business.csm_owner
        - fct_csm_book_of_business.count_accounts
        - fct_csm_book_of_business.avg_health_score
        - fct_csm_book_of_business.count_at_risk
        - fct_csm_book_of_business.count_expansion_signals
      sorts: [fct_csm_book_of_business.avg_health_score desc]
      row: 26
      col: 0
      width: 24
      height: 7
