- dashboard: pb02_account_usage
  title: "PB-02: Account-Level Product Usage"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Account-level drill-through: engagement score, DAU/MAU, feature breadth, licence utilisation, onboarding status."

  filters:
    - name: account_filter
      title: "Account"
      type: field_filter
      default_value: ""
      explore: account_product_usage
      dimension: dim_account.account_name
      required: true

    - name: score_month
      title: "Score Month"
      type: field_filter
      default_value: "this month"
      explore: account_product_usage
      dimension: dim_account_product_score.score_month

  elements:
    - name: account_header
      title: "Account Overview"
      type: looker_single_record
      explore: account_product_usage
      dimensions:
        - dim_account.account_name
        - dim_account.segment
        - dim_account.csm_name
        - dim_account.contracted_user_seats
        - dim_account.contract_start_date

    - name: engagement_score_kpi
      title: "Engagement Score"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_product_engagement_score]

    - name: dau_mau_kpi
      title: "DAU / MAU"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_dau_mau]

    - name: licence_util_kpi
      title: "Licence Utilisation"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_licence_utilisation]
      note_state: collapsed
      note_display: hover
      note_text: "Active users in last 30 days / contracted seats. Null means contracted seats not on file."

    - name: onboarding_kpi
      title: "Onboarding Completion"
      type: single_value
      explore: account_product_usage
      dimensions: [fct_onboarding_funnel.core_steps_completed]
      note_state: collapsed
      note_display: hover
      note_text: "Core onboarding = Steps 1–5. Extended = Steps 6–7."

    - name: score_trend
      title: "Engagement Score Trend"
      type: looker_line
      explore: account_product_usage
      dimensions: [dim_account_product_score.score_month]
      measures: [dim_account_product_score.avg_product_engagement_score]
      sorts:
        - dim_account_product_score.score_month asc

    - name: feature_usage_by_module
      title: "Feature Adoption by Module"
      type: looker_bar
      explore: feature_adoption
      dimensions: [fct_feature_usage.module_name]
      measures: [fct_feature_usage.distinct_features_used]
      sorts:
        - fct_feature_usage.distinct_features_used desc

    - name: top_features_table
      title: "Top 10 Features Used"
      type: looker_grid
      explore: feature_adoption
      dimensions:
        - fct_feature_usage.feature_name
        - fct_feature_usage.feature_group_name
      measures:
        - fct_feature_usage.event_count
      sorts:
        - fct_feature_usage.event_count desc
      limit: 10
