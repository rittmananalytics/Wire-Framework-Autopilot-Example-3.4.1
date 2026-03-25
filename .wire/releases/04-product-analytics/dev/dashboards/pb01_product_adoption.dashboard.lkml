- dashboard: pb01_product_adoption
  title: "PB-01: Product Adoption Overview"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Feature adoption heatmap across all accounts. Default: Feature Group level; drill to Feature. Filter by module, segment."

  filters:
    - name: date_range
      title: "Date Range"
      type: date_filter
      default_value: "30 days"
      explore: feature_adoption
      dimension: fct_feature_usage.event_date

    - name: module
      title: "Module"
      type: field_filter
      default_value: ""
      explore: feature_adoption
      dimension: fct_feature_usage.module_name

    - name: segment
      title: "Account Segment"
      type: field_filter
      default_value: ""
      explore: feature_adoption
      dimension: dim_account.segment

  elements:
    - name: active_accounts_kpi
      title: "Active Accounts"
      type: single_value
      explore: feature_adoption
      measures: [dim_account.account_count]
      filters:
        fct_feature_usage.event_date: "30 days"
      comparison_type: change
      comparison_reverse_colors: false

    - name: avg_feature_breadth_kpi
      title: "Avg Feature Breadth"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_product_engagement_score]
      note_state: collapsed
      note_display: hover
      note_text: "Average number of distinct features used per account in the last 30 days"

    - name: avg_dau_mau_kpi
      title: "Avg DAU/MAU"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_dau_mau]
      note_state: collapsed
      note_display: hover
      note_text: "Average ratio of daily active users to monthly active users across all accounts"

    - name: avg_engagement_score_kpi
      title: "Avg Engagement Score"
      type: single_value
      explore: account_product_usage
      measures: [dim_account_product_score.avg_product_engagement_score]
      comparison_type: change

    - name: feature_adoption_heatmap
      title: "Feature Adoption Heatmap (by Feature Group)"
      type: looker_grid
      explore: feature_adoption
      dimensions:
        - fct_feature_usage.feature_group_name
        - dim_account.account_name
      measures:
        - fct_feature_usage.event_count
      pivot:
        - dim_account.account_name
      sorts:
        - fct_feature_usage.feature_group_name asc
      limit: 50
      column_limit: 50

    - name: module_adoption_table
      title: "Module Adoption Summary"
      type: looker_grid
      explore: feature_adoption
      dimensions:
        - fct_feature_usage.module_name
      measures:
        - fct_feature_usage.feature_adoption_rate
        - fct_feature_usage.distinct_accounts_using_feature
      sorts:
        - fct_feature_usage.feature_adoption_rate desc

    - name: underutilised_features
      title: "Top 10 Underutilised Features"
      type: looker_grid
      explore: feature_adoption
      dimensions:
        - fct_feature_usage.feature_name
        - fct_feature_usage.feature_group_name
      measures:
        - fct_feature_usage.feature_adoption_rate
        - fct_feature_usage.distinct_accounts_using_feature
      sorts:
        - fct_feature_usage.feature_adoption_rate asc
      limit: 10
