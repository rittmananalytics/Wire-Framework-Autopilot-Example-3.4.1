{% test assert_score_in_range(model, column_name, min_value=0, max_value=100) %}

select {{ column_name }}, count(*) as violations
from {{ model }}
where {{ column_name }} < {{ min_value }}
   or {{ column_name }} > {{ max_value }}
group by 1
having count(*) > 0

{% endtest %}
