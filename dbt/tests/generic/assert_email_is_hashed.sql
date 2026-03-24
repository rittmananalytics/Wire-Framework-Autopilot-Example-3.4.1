{% test assert_email_is_hashed(model, column_name) %}
-- Custom test: validates that the email pseudonymised column contains only SHA-256 hashes
-- A valid SHA-256 hash is exactly 64 lowercase hexadecimal characters
-- This test fails if any value looks like a plain-text email (contains @) or is not 64 chars

select
    count(*) as violations
from {{ model }}
where {{ column_name }} is not null
    and (
        regexp_contains({{ column_name }}, r'@')  -- plain-text email detected
        or length({{ column_name }}) != 64         -- not a SHA-256 hash length
        or not regexp_contains({{ column_name }}, r'^[0-9a-f]{64}$')  -- not hex chars
    )
having count(*) > 0

{% endtest %}
