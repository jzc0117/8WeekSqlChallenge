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

-- 4.How many of each type of pizza was delivered?
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
),

orders_cte as (
	select 
  		order_id,
  		customer_id,
  		pizza_id,
  	case when exclusions='null' then Null
  		when exclusions='' then Null
  		else exclusions
  	end as extras_cleaned,
    	case when extras='null' then Null
  		when extras='' then Null
  		else extras
  	end as extras_cleaned,
  	order_time
  	from pizza_runner.customer_orders
)
select 
o.pizza_id,names.pizza_name,
count(cte.order_id)
from cte
join orders_cte as o on o.order_id = cte.order_id
join pizza_runner.pizza_names as names on o.pizza_id=names.pizza_id
where cancellation_cleaned is null
group by o.pizza_id,names.pizza_name
;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
with orders_cte as (
	select 
  		order_id,
  		customer_id,
  		pizza_id,
  	case when exclusions='null' then Null
  		when exclusions='' then Null
  		else exclusions
  	end as extras_cleaned,
    	case when extras='null' then Null
  		when extras='' then Null
  		else extras
  	end as extras_cleaned,
  	order_time
  	from pizza_runner.customer_orders
)
select 
	customer_id,
    sum(case when pizza_id = 1 then 1
    	else 0
   end) as meatlovers,
   sum(case when pizza_id = 2 then 1
   else 0 
   end) as vegetarian
from orders_cte
group by customer_id
order by customer_id
;

-- 6. What was the maximum number of pizzas delivered in a single order?
with cte as(
select 
  order_id, 
  count(*) as no_of_pizzas
from pizza_runner.customer_orders
group by order_id
order by no_of_pizzas desc
)
select * from cte
fetch first 1 rows only
;

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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
runners_orders_cte as (
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
    orders_cte.customer_id,
    sum(case when orders_cte.exclusions_cleaned is not null or orders_cte.extras_cleaned is not null then 1 
        else 0 
        end) as pizza_changes,
    sum(case when orders_cte.exclusions_cleaned is null and orders_cte.extras_cleaned is null then 1 
        else 0 end) as no_changes
from orders_cte
join runners_orders_cte as runners on runners.order_id=orders_cte.order_id
where cancellation_cleaned is null
group by customer_id
;

-- 8. How many pizzas were delivered that had both exclusions and extras?
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
runners_orders_cte as (
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
    orders_cte.customer_id,
    sum(case when orders_cte.exclusions_cleaned is not null and orders_cte.extras_cleaned is not null then 1 
        else 0 
        end) as exclusions_and_extras
from orders_cte
join runners_orders_cte as runners on runners.order_id=orders_cte.order_id
where cancellation_cleaned is null
group by customer_id
