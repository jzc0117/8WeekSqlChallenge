-- 1. What are the standard ingredients for each pizza?
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

-- 2. What was the most commonly added extra?
-- Assumption: Count of extras in customer_orders table
with orders_cte as (
	select 
  		order_id,
  		customer_id,
  		pizza_id,
  	case when exclusions='null' then Null
  		when exclusions='' then Null
  		else exclusions
  	end as exclusions_cleaned,
    	case when extras='null' then Null
  		when extras='' then Null
  		else extras
  	end as extras_cleaned,
  	order_time
  	from pizza_runner.customer_orders
),
orders_cleaned as (
select
  order_id,
  customer_id,
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(extras_cleaned, '[,\s]+')::INTEGER AS extras_split
FROM orders_cte
)

select 
t.topping_id,
t.topping_name,
count(extras_split) as count_extras
from pizza_runner.pizza_toppings as t
left join orders_cleaned as o on t.topping_id = o.extras_split 
group by t.topping_id, t.topping_name
order by t.topping_id

-- 3. What was the most common exclusion?
with orders_cte as (
	select 
  		order_id,
  		customer_id,
  		pizza_id,
  	case when exclusions='null' then Null
  		when exclusions='' then Null
  		else exclusions
  	end as exclusions_cleaned,
    	case when extras='null' then Null
  		when extras='' then Null
  		else extras
  	end as extras_cleaned,
  	order_time
  	from pizza_runner.customer_orders
),
orders_cleaned as (
select
  order_id,
  customer_id,
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(exclusions_cleaned, '[,\s]+')::INTEGER AS exclusions_split
FROM orders_cte
)

select 
t.topping_id,
t.topping_name,
count(exclusions_split) as  count_exclusions
from pizza_runner.pizza_toppings as t
left join orders_cleaned as o on t.topping_id = o.exclusions_split 
group by t.topping_id, t.topping_name
order by t.topping_id







