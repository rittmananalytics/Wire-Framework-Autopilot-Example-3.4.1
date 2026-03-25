{% test assert_user_id_is_hashed(model, column_name) %}

select count(*) as violations
from {{ model }}
where {{ column_name }} is not null
  and (
    length({{ column_name }}) != 64
    or not regexp_contains({{ column_name }}, r'^[0-9a-f]{64}$')
  )
having count(*) > 0

{% endtest %}
