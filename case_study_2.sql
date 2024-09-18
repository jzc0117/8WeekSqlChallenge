-- A. Pizza Metrics
--1. How many pizzas were ordered?
select count(*) from pizza_runner.customer_orders
;


-- 2. How many unique customer orders were made?
with cte as (
  select distinct  
    customer_id, 
    pizza_id,extras 
  from pizza_runner.customer_orders
  order by customer_id
)
select customer_id, count(pizza_id) from cte
group  by customer_id
;
  
-- 3. How many successful orders were delivered by each runner?
with cte as (
select
  order_id,
  runner_id,
  pickup_time, 
  distance, 
  duration,
  case when cancellation = 'Restaurant Cancellation' then 'Restaurant Cancellation'
  		when cancellation='Customer Cancellation' then 'Customer Cancellation'
  		else Null
  end as cancellation_cleaned
from pizza_runner.runner_orders
)
select runner_id, count(order_id) from cte
where cancellation_cleaned is Null 
group by runner_id
;
