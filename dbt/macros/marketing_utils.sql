{% macro hash_email(email_field) %}
    -- Hash an email field to SHA-256 for PII pseudonymisation
    -- Lowercases and trims before hashing to ensure consistency
    to_hex(sha256(lower(trim({{ email_field }}))))
{% endmacro %}


{% macro extract_domain(email_field) %}
    -- Extract the domain portion from an email address for fuzzy matching
    -- Returns the part after the @ symbol
    lower(regexp_extract({{ email_field }}, r'@(.+)$'))
{% endmacro %}


{% macro majority_stage(stage_column, partition_column) %}
    -- Calculate the majority (mode) of Salesforce opportunity stages
    -- Used for the "majority_pipeline_stage" column in MA-01 dashboard
    -- Returns the most frequently occurring stage for each partition group
    first_value({{ stage_column }}) over (
        partition by {{ partition_column }}
        order by count({{ stage_column }}) over (
            partition by {{ partition_column }}, {{ stage_column }}
        ) desc
    )
{% endmacro %}
