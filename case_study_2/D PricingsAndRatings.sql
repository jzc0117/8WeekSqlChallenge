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
 
