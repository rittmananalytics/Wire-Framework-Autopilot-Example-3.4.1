-- dim_account
-- Account dimension: one row per account. SCD Type 1 (current state only).
-- Shared by product analytics (this release) and customer analytics (Release 05).
-- account_pk = SHA-256(salesforce_account_id) for cross-release consistency.

{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_product']
    )
}}

with s_salesforce_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_salesforce_contracts as (
    select * from {{ ref('stg_salesforce__contracts') }}
),

s_salesforce_users as (
    select * from {{ ref('stg_salesforce__users') }}  -- for CSM lookup
),

-- Contract data: earliest contract per account
account_contracts as (
    select
        account_id,
        min(start_date)                             as contract_start_date,
        max(user_seats__c)                          as contracted_user_seats
    from s_salesforce_contracts
    where status = 'Activated'
    group by 1
),

-- CSM lookup from Salesforce CSM__c field (custom lookup)
account_csm as (
    select
        a.account_id,
        u.name as csm_name,
        u.email as csm_email
    from s_salesforce_accounts as a
    left join s_salesforce_users as u
        on a.csm__c = u.user_id
),

-- Account segment classification:
-- Strategic takes precedence (manually designated by CRO via Salesforce field)
-- Otherwise: Enterprise (ACV ≥ 150K or employees ≥ 1000), Mid-Market (50K–149K or 200–999), SMB (< 50K)
accounts_with_segment as (
    select
        a.account_id,
        to_hex(sha256(cast(a.account_id as bytes)))                         as account_pk,
        a.account_name,
        case
            when a.segment__c = 'Strategic'                                 then 'Strategic'
            when a.annual_contract_value_usd >= 150000
              or a.number_of_employees >= 1000                              then 'Enterprise'
            when a.annual_contract_value_usd >= 50000
              or a.number_of_employees >= 200                               then 'Mid-Market'
            else                                                                 'SMB'
        end                                                                 as segment,
        a.annual_contract_value_usd                                         as arr_usd,
        a.number_of_employees,
        a.created_date                                                      as account_created_date,
        a.is_active
    from s_salesforce_accounts as a
),

final as (
    select
        aws.account_pk,
        aws.account_id                                                      as salesforce_account_id,
        aws.account_name,
        aws.segment,
        coalesce(csm.csm_name, 'Unassigned')                                as csm_name,
        csm.csm_email,
        coalesce(ac.contracted_user_seats, null)                            as contracted_user_seats,
        ac.contract_start_date,
        aws.arr_usd,
        aws.number_of_employees,
        aws.account_created_date,
        aws.is_active
    from accounts_with_segment as aws
    left join account_contracts as ac
        on aws.account_id = ac.account_id
    left join account_csm as csm
        on aws.account_id = csm.account_id
)

select * from final
