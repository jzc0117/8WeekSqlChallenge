--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- - how much money has Pizza Runner made so far if there are no delivery fees?
with cte as (
select 
	c.order_id,
    c.customer_id,
    c.pizza_id,
    c.exclusions,
    c.extras,
    c.order_time,
    case when c.pizza_id=1 then 12
    else 10
    end as cost,
    case when cancellation = 'Restaurant Cancellation' then 'Restaurant Cancellation'
  		when cancellation='Customer Cancellation' then 'Customer Cancellation'
  		else Null
  end as cancellation_cleaned
from pizza_runner.customer_orders as c
left join pizza_runner.runner_orders as r on r.order_id=c.order_id
  )
 select 
 sum(cost)
 from cte
 where cancellation_cleaned is null
 ;

-- 2. What if there was an additional $1 charge for any pizza extras?
-- 	Add cheese is $1 extra

with cte as (
select 
	c.order_id,
    c.customer_id,
    c.pizza_id,
    c.exclusions,
    c.extras,
    c.order_time,
    case when c.pizza_id=1 then 12
    else 10
    end as cost,
    length(replace(replace(replace(extras, ' ', ''), ',', ''), 'null', '')) as extras_price,
    case when cancellation = 'Restaurant Cancellation' then 'Restaurant Cancellation'
  		when cancellation='Customer Cancellation' then 'Customer Cancellation'
  		else Null
  end as cancellation_cleaned
from pizza_runner.customer_orders as c
left join pizza_runner.runner_orders as r on r.order_id=c.order_id
  )
 select 
 sum(cost)+sum(extras_price)  as total_sum
 from cte
 where cancellation_cleaned is null
 ;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 
-- 	paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
with cte as (
select 
	c.order_id,
    c.pizza_id,
    c.exclusions,
    c.extras,
    c.order_time,
    case when c.pizza_id=1 then 12
    else 10
    end as cost,
    case when cancellation = 'Restaurant Cancellation' then 'Restaurant Cancellation'
  		when cancellation='Customer Cancellation' then 'Customer Cancellation'
  		else Null
  end as cancellation_cleaned,
  distance,
  NULLIF(regexp_replace(r.distance, '[^\d.]','','g'), '')::numeric*0.3 as runner_salary
from pizza_runner.customer_orders as c
left join pizza_runner.runner_orders as r on r.order_id=c.order_id
  )
 select 
 sum(cost) - sum(runner_salary) as revenue
 from cte
 where cancellation_cleaned is null
 ;

