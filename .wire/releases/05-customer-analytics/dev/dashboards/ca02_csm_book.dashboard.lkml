- dashboard: ca02_csm_book
  title: "CA-02 CSM Book of Business"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Per-CSM account view with health scores, churn risk, action items — filtered by CSM via row-level security"

  filters:
    - name: health_band
      title: "Health Band"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: csm_book_of_business
      field: fct_csm_book_of_business.health_band

    - name: churn_risk
      title: "Churn Risk"
      type: field_filter
      default_value: ''
      allow_multiple_values: true
      required: false
      explore: csm_book_of_business
      field: fct_csm_book_of_business.churn_risk_band

    - name: renewal_window
      title: "Renewal Window"
      type: field_filter
      default_value: ''
      allow_multiple_values: false
      required: false
      explore: csm_book_of_business
      field: fct_csm_book_of_business.days_to_renewal

  elements:
    # KPI: My Accounts
    - title: "My Accounts"
      name: kpi_my_accounts
      explore: csm_book_of_business
      type: single_value
      fields: [fct_csm_book_of_business.count_accounts]
      row: 0
      col: 0
      width: 4
      height: 3

    # KPI: At-Risk Accounts
    - title: "At-Risk Accounts"
      name: kpi_at_risk
      explore: csm_book_of_business
      type: single_value
      fields: [fct_csm_book_of_business.count_at_risk]
      custom_color: "#E74C3C"
      row: 0
      col: 4
      width: 4
      height: 3

    # KPI: Renewals < 90 Days
    - title: "Renewals < 90 Days"
      name: kpi_renewals_90
      explore: csm_book_of_business
      type: single_value
      fields: [fct_csm_book_of_business.count_renewals_90d]
      custom_color: "#F39C12"
      row: 0
      col: 8
      width: 4
      height: 3

    # KPI: Open Actions
    - title: "Total Open Actions"
      name: kpi_actions
      explore: csm_book_of_business
      type: single_value
      fields: [fct_csm_book_of_business.total_open_actions]
      row: 0
      col: 12
      width: 4
      height: 3

    # KPI: Expansion Signals
    - title: "Expansion Opportunities"
      name: kpi_expansion
      explore: csm_book_of_business
      type: single_value
      fields: [fct_csm_book_of_business.count_expansion_signals]
      custom_color: "#1ABC9C"
      row: 0
      col: 16
      width: 4
      height: 3

    # Health Scatter (health score vs renewal urgency)
    - title: "Account Health vs Renewal Urgency"
      name: health_scatter
      explore: csm_book_of_business
      type: looker_scatter
      fields:
        - fct_csm_book_of_business.health_score
        - fct_csm_book_of_business.days_to_renewal
        - fct_csm_book_of_business.account_name
        - fct_csm_book_of_business.health_band
        - fct_csm_book_of_business.churn_risk_band
      limit: 500
      row: 3
      col: 0
      width: 24
      height: 8

    # Account List Table
    - title: "Account List"
      name: account_list
      explore: csm_book_of_business
      type: table
      fields:
        - fct_csm_book_of_business.account_name
        - fct_csm_book_of_business.arr_usd
        - fct_csm_book_of_business.health_score
        - fct_csm_book_of_business.health_score_7d_change
        - fct_csm_book_of_business.churn_risk_band
        - fct_csm_book_of_business.days_to_renewal
        - fct_csm_book_of_business.days_since_qbr
        - fct_csm_book_of_business.total_open_actions
      sorts: [fct_csm_book_of_business.health_score asc]
      limit: 100
      row: 11
      col: 0
      width: 24
      height: 10

    # Stalled Onboarding
    - title: "Accounts with Stalled Onboarding"
      name: stalled_onboarding
      explore: csm_book_of_business
      type: table
      fields:
        - fct_csm_book_of_business.account_name
        - fct_csm_book_of_business.overdue_onboarding_steps
        - fct_csm_book_of_business.health_score
        - fct_csm_book_of_business.churn_risk_band
        - fct_csm_book_of_business.days_to_renewal
      filters:
        fct_csm_book_of_business.overdue_onboarding_steps: ">0"
      sorts: [fct_csm_book_of_business.overdue_onboarding_steps desc]
      limit: 20
      row: 21
      col: 0
      width: 24
      height: 7
