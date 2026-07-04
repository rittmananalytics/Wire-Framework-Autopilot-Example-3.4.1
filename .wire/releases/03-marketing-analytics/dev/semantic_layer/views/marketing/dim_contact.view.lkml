view: dim_contact {
  sql_table_name: `core-dynamics-analytics-prod.mart_marketing.dim_contact` ;;

  dimension: contact_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.contact_pk ;;
  }

  dimension: account_fk {
    hidden: yes
    type: string
    sql: ${TABLE}.account_fk ;;
  }

  # NOTE: email_pseudonymised is intentionally NOT exposed in Looker
  # It is a SHA-256 hash and has no analytical value as a display dimension.
  # PII policy: no plain-text email in any Looker view.

  dimension: hubspot_lifecycle_stage {
    label: "Lifecycle Stage"
    type: string
    sql: ${TABLE}.hubspot_lifecycle_stage ;;
  }

  dimension: is_mql {
    label: "Is MQL"
    group_label: "Lifecycle Flags"
    type: yesno
    sql: ${TABLE}.is_mql ;;
  }

  dimension: is_sal {
    label: "Is SAL"
    group_label: "Lifecycle Flags"
    type: yesno
    sql: ${TABLE}.is_sal ;;
  }

  dimension: is_sql {
    label: "Is SQL"
    group_label: "Lifecycle Flags"
    type: yesno
    sql: ${TABLE}.is_sql ;;
  }

  dimension: clearbit_industry {
    label: "Industry"
    group_label: "Firmographics"
    type: string
    sql: ${TABLE}.clearbit_industry ;;
  }

  dimension: clearbit_employees_range {
    label: "Company Size"
    group_label: "Firmographics"
    type: string
    sql: ${TABLE}.clearbit_employees_range ;;
  }

  dimension: clearbit_country_code {
    label: "Country"
    group_label: "Firmographics"
    type: string
    sql: ${TABLE}.clearbit_country_code ;;
    map_layer_name: countries
  }

  dimension: segment {
    label: "Segment"
    group_label: "Firmographics"
    type: string
    sql: case
      when ${TABLE}.clearbit_employees_range in ('1001-5000', '5001-10000', '10001+') then 'Enterprise'
      when ${TABLE}.clearbit_employees_range in ('201-500', '501-1000') then 'Mid-Market'
      when ${TABLE}.clearbit_employees_range in ('1-10', '11-50', '51-200') then 'SMB'
      else 'Unknown'
    end ;;
  }

  dimension: is_sf_matched {
    label: "Matched to Salesforce"
    type: yesno
    sql: ${TABLE}.is_sf_matched ;;
  }

  dimension: match_method {
    label: "Match Method"
    type: string
    sql: ${TABLE}.match_method ;;
  }

  dimension_group: mql {
    label: "MQL Date"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.mql_date ;;
  }

  dimension_group: sal {
    label: "SAL Date"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.sal_date ;;
  }

  dimension_group: created {
    label: "Contact Created"
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  measure: count_contacts {
    label: "Contacts"
    type: count_distinct
    sql: ${contact_pk} ;;
    value_format_name: decimal_0
  }

  measure: count_mqls {
    label: "MQLs"
    type: count_distinct
    sql: case when ${is_mql} then ${contact_pk} end ;;
    value_format_name: decimal_0
  }

  measure: sf_match_rate {
    label: "Salesforce Match Rate"
    type: number
    sql: countif(${is_sf_matched}) / nullif(${count_contacts}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of contacts successfully matched to Salesforce. Target ≥ 88%."
  }
}
