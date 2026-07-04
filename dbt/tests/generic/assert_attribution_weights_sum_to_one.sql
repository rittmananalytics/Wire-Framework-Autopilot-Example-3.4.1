{% test assert_attribution_weights_sum_to_one(model, column_name) %}
-- Custom test: for each opportunity + attribution_model, the sum of touch_weight must equal 1.0 ± 0.001
-- This validates that attribution calculations are internally consistent

select
    opportunity_pk,
    attribution_model,
    round(sum(touch_weight), 3) as weight_sum
from {{ model }}
where is_closed_won = true
group by 1, 2
having abs(round(sum(touch_weight), 3) - 1.0) > 0.001

{% endtest %}
