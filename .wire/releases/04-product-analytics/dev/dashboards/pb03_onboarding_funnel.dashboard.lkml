- dashboard: pb03_onboarding_funnel
  title: "PB-03: Onboarding Funnel Analysis"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Onboarding progress across all accounts. Stalled account alerts for CSM intervention. Filter by CSM to see book of business."

  filters:
    - name: csm_filter
      title: "CSM"
      type: field_filter
      default_value: ""
      explore: onboarding_funnel
      dimension: fct_onboarding_funnel.csm_name

    - name: signup_date
      title: "Contract Start Date"
      type: date_filter
      default_value: "90 days"
      explore: onboarding_funnel
      dimension: dim_account.contract_start_date

    - name: segment_filter
      title: "Account Segment"
      type: field_filter
      default_value: ""
      explore: onboarding_funnel
      dimension: fct_onboarding_funnel.segment

  elements:
    - name: accounts_in_onboarding
      title: "Accounts in Onboarding"
      type: single_value
      explore: onboarding_funnel
      measures: [fct_onboarding_funnel.stalled_account_count]
      note_state: collapsed
      note_display: hover
      note_text: "Accounts with at least one incomplete core onboarding step"

    - name: fully_onboarded
      title: "Fully Onboarded (Core)"
      type: single_value
      explore: onboarding_funnel
      dimensions: []
      measures: [fct_onboarding_funnel.accounts_completing_step]
      filters:
        fct_onboarding_funnel.step_id: "onboarding_configure_report"
        fct_onboarding_funnel.is_complete: "Yes"

    - name: stalled_accounts_kpi
      title: "Stalled Accounts"
      type: single_value
      explore: onboarding_funnel
      measures: [fct_onboarding_funnel.stalled_account_count]

    - name: avg_days_core_complete
      title: "Avg Days to Core Complete"
      type: single_value
      explore: onboarding_funnel
      measures: [fct_onboarding_funnel.avg_days_to_complete]
      filters:
        fct_onboarding_funnel.step_id: "onboarding_configure_report"
        fct_onboarding_funnel.is_core_step: "Yes"

    - name: onboarding_funnel_chart
      title: "Onboarding Funnel (% Completion by Step)"
      type: looker_bar
      explore: onboarding_funnel
      dimensions: [fct_onboarding_funnel.step_name]
      measures: [fct_onboarding_funnel.step_completion_rate]
      sorts:
        - fct_onboarding_funnel.step_order asc
      y_axes:
        - label: "Completion Rate"
          value_format_name: percent_0
      note_state: collapsed
      note_display: hover
      note_text: "Step 4 (Create Work Order) is the most predictive step for long-term retention"

    - name: stalled_accounts_table
      title: "Stalled Accounts — CSM Action Required"
      type: looker_grid
      explore: onboarding_funnel
      dimensions:
        - fct_onboarding_funnel.account_name
        - fct_onboarding_funnel.segment
        - fct_onboarding_funnel.csm_name
        - fct_onboarding_funnel.step_name
      measures:
        - fct_onboarding_funnel.avg_days_to_complete
      filters:
        fct_onboarding_funnel.is_stalled: "Yes"
      sorts:
        - fct_onboarding_funnel.avg_days_to_complete desc
      limit: 25
      column_order:
        - fct_onboarding_funnel.account_name
        - fct_onboarding_funnel.segment
        - fct_onboarding_funnel.csm_name
        - fct_onboarding_funnel.step_name
        - fct_onboarding_funnel.avg_days_to_complete

    - name: completion_time_distribution
      title: "Step Completion Time Distribution (Median)"
      type: looker_bar
      explore: onboarding_funnel
      dimensions: [fct_onboarding_funnel.step_name]
      measures: [fct_onboarding_funnel.avg_days_to_complete]
      sorts:
        - fct_onboarding_funnel.step_order asc
