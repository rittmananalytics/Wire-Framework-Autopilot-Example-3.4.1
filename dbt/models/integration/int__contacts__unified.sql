{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_marketing']
    )
}}

with s_hubspot_contacts as (
    select * from {{ source('staging', 'stg_hubspot__contacts') }}
),

s_salesforce_contacts as (
    select * from {{ source('staging', 'stg_salesforce__contacts') }}
),

s_salesforce_accounts as (
    select * from {{ source('staging', 'stg_salesforce__accounts') }}
),

s_clearbit as (
    select * from {{ source('raw_hubspot', 'clearbit_enrichment') }}
),

-- Primary join: exact email hash match
hubspot_sf_exact_match as (
    select
        h.contact_pk as hubspot_contact_pk,
        h.email_hash,
        h.company_domain,
        sf.contact_pk as salesforce_contact_pk,
        sf.account_fk,
        'exact_email' as match_method
    from s_hubspot_contacts h
    inner join s_salesforce_contacts sf
        on h.email_hash = sf.email_hash
),

-- Fallback join: company domain (only where exactly one SF contact per domain)
domain_match_candidates as (
    select
        h.contact_pk as hubspot_contact_pk,
        h.email_hash,
        h.company_domain,
        sf.contact_pk as salesforce_contact_pk,
        sf.account_fk,
        'company_domain' as match_method,
        count(sf.contact_pk) over (partition by h.company_domain) as sf_contacts_per_domain
    from s_hubspot_contacts h
    left join hubspot_sf_exact_match matched
        on h.contact_pk = matched.hubspot_contact_pk
    inner join s_salesforce_contacts sf
        on h.company_domain = sf.company_domain
    where matched.hubspot_contact_pk is null  -- not already matched
),

domain_match as (
    select
        hubspot_contact_pk,
        email_hash,
        company_domain,
        salesforce_contact_pk,
        account_fk,
        match_method
    from domain_match_candidates
    where sf_contacts_per_domain = 1  -- only unambiguous domain matches
),

-- Union all matches
all_matches as (
    select * from hubspot_sf_exact_match
    union all
    select * from domain_match
),

final as (
    select
        -- primary key
        h.contact_pk,

        -- source identifiers
        h.contact_pk as hubspot_contact_id,
        m.salesforce_contact_pk as salesforce_contact_id,
        m.account_fk,

        -- PII-safe identifier (SHA-256 hash)
        h.email_hash as email_pseudonymised,
        h.company_domain,

        -- name fields (from HubSpot preferred)
        h.first_name,
        h.last_name,

        -- lifecycle stage
        h.hubspot_lifecycle_stage,
        h.is_mql,
        h.mql_date,
        h.is_sal,
        h.sal_date,
        h.is_sql,
        h.sql_date,

        -- clearbit enrichment
        cb.company_name as clearbit_company_name,
        cb.industry as clearbit_industry,
        cb.employees_range as clearbit_employees_range,
        cb.country_code as clearbit_country_code,

        -- match metadata
        coalesce(m.match_method, 'unmatched') as match_method,
        case when m.salesforce_contact_pk is not null then true else false end as is_sf_matched,

        -- timestamps
        h.created_at

    from s_hubspot_contacts h
    left join all_matches m
        on h.contact_pk = m.hubspot_contact_pk
    left join s_clearbit cb
        on h.contact_pk = cb.hubspot_contact_id
)

select * from final
