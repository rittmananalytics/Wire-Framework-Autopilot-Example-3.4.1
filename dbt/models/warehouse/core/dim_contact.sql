{{
    config(
        materialized='table',
        cluster_by=['hubspot_lifecycle_stage'],
        tags=['warehouse', 'warehouse_marketing']
    )
}}

with s_contacts as (
    select * from {{ ref('int__contacts__unified') }}
),

final as (
    select
        contact_pk,
        hubspot_contact_id,
        salesforce_contact_id,
        account_fk,

        -- PII-safe: email stored as SHA-256 hash only — no plain-text email
        email_pseudonymised,

        first_name,
        last_name,
        hubspot_lifecycle_stage,
        is_mql,
        mql_date,
        is_sal,
        sal_date,
        is_sql,
        sql_date,

        -- Clearbit firmographic enrichment
        clearbit_company_name,
        clearbit_industry,
        clearbit_employees_range,
        clearbit_country_code,

        -- Match quality metadata
        is_sf_matched,
        match_method,

        created_at,
        current_timestamp() as _loaded_at
    from s_contacts
)

select * from final
