-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select 
	date_trunc('week', registration_date) + interval '4 day' as week,
	count(runner_id) as runner_count
from pizza_runner.runners
group by 1 
order by 1
;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with cte as (
  select 
      orders.order_id as order_id,
      runner_orders.runner_id as runner_id,
      orders.order_time as order_time,
      pg_typeof(orders.order_time),
      case when runner_orders.pickup_time='null' then null 
          else cast(runner_orders.pickup_time as timestamp)  
          end as pickup_timestamp
  from pizza_runner.runner_orders as runner_orders
  join pizza_runner.customer_orders as orders on runner_orders.order_id = orders.order_id
)

select
	runner_id,
	avg(extract(minutes from (pickup_timestamp - order_time)))
from cte
group by runner_id
order by runner_id
