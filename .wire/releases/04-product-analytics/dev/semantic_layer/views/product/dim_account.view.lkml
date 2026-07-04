view: dim_account {
  sql_table_name: `core-dynamics-analytics-prod.mart_product.dim_account` ;;

  dimension: account_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.account_pk ;;
  }

  dimension: account_name {
    label: "Account Name"
    type: string
    sql: ${TABLE}.account_name ;;
    link: {
      label: "View in Salesforce"
      url: "https://app.salesforce.com/{{ salesforce_account_id._value }}"
    }
  }

  dimension: salesforce_account_id {
    hidden: yes
    type: string
    sql: ${TABLE}.salesforce_account_id ;;
  }

  dimension: segment {
    label: "Account Segment"
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: csm_name {
    label: "CSM"
    type: string
    sql: ${TABLE}.csm_name ;;
  }

  dimension: contracted_user_seats {
    label: "Contracted Seats"
    type: number
    sql: ${TABLE}.contracted_user_seats ;;
  }

  dimension: contract_start_date {
    label: "Contract Start Date"
    type: date
    datatype: date
    sql: ${TABLE}.contract_start_date ;;
  }

  dimension: is_active {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_active ;;
  }

  measure: account_count {
    type: count_distinct
    sql: ${TABLE}.account_pk ;;
    label: "Account Count"
  }
}
