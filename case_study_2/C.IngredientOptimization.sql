-- What are the standard ingredients for each pizza?
-- Assuming this means what are the standard names of ingredients for each pizza

with cte as (SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes as recipes
  -- this cte from https://github.com/katiehuangx
)

select 
	cte.pizza_id, 
    cte.topping_id,
    toppings.topping_name
from cte
join pizza_runner.pizza_toppings as toppings on cte.topping_id = toppings.topping_id
order by cte.pizza_id, cte.topping_id
