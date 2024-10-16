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
  select distinct
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
;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Based on the query below, there is a positive relationship between the number of pizzas and the time it takes to prepare the order.  

with cte as (
  select 
      orders.order_id as order_id,
      runner_orders.runner_id as runner_id,
      orders.order_time as order_time,
  	  orders.pizza_id as pizza_id,
      pg_typeof(orders.order_time),
      case when runner_orders.pickup_time='null' then null 
          else cast(runner_orders.pickup_time as timestamp)  
          end as pickup_timestamp
  from pizza_runner.runner_orders as runner_orders
  join pizza_runner.customer_orders as orders on runner_orders.order_id = orders.order_id
)

select 
	order_id,
	count(pizza_id),
	extract(minutes from (pickup_timestamp - order_time))
    
from cte
where pickup_timestamp is not null
group by 1,3
order by order_id
;

-- What was the average distance travelled for each customer?
with distance_cte as (
  select distinct
      runner_orders.order_id, 
  	  orders.customer_id,
      runner_orders.runner_id,
      runner_orders.pickup_time,
      NULLIF(regexp_replace(runner_orders.distance, '[^\d.]','','g'), '')::numeric AS distance_cleaned
	from pizza_runner.runner_orders as runner_orders
  	join pizza_runner.customer_orders as orders on runner_orders.order_id = orders.order_id
	where distance is not null and distance !='null'
  	order by runner_orders.order_id
  )
 
 select 
	customer_id,
	avg(distance_cleaned)
 from distance_cte
 group by customer_id
;

-- What was the difference between the longest and shortest delivery times for all orders?
with duration_cte as (
  select
      runner_orders.order_id, 
  	  orders.customer_id,
      runner_orders.runner_id,
      runner_orders.pickup_time,
      NULLIF(regexp_replace(runner_orders.duration, '\D','','g'), '')::numeric AS duration_cleaned
	from pizza_runner.runner_orders as runner_orders
  	join pizza_runner.customer_orders as orders on runner_orders.order_id = orders.order_id
	where distance is not null and distance !='null'
  	order by runner_orders.order_id
  )
select 
	max(duration_cleaned),
    min(duration_cleaned),
	(max(duration_cleaned)-min(duration_cleaned)) as difference
from duration_cte
;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
select 
	order_id,
    runner_id,
    NULLIF(regexp_replace(runner_orders.distance, '[^\d.]','','g'), '')::numeric as distance,
    NULLIF(regexp_replace(runner_orders.duration, '\D','','g'), '')::numeric as duration,
    (NULLIF(regexp_replace(runner_orders.distance, '[^\d.]','','g'), '')::numeric/
    NULLIF(regexp_replace(runner_orders.duration, '\D','','g'), '')::numeric) as speed_km_per_min
from pizza_runner.runner_orders
;

-- What is the successful delivery percentage for each runner?
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
select 
	runner_id,
   	count(case when cancellation_cleaned is null then 1
    else null
    end) as num_delivered,
     count(*),
    (count(case when cancellation_cleaned is null then 1
    else null
    end)::decimal/
    count(*)::decimal)*100 as percentage
from cte
group by runner_id
order by runner_id
