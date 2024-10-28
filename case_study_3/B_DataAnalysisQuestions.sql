-- 1. How many customers has Foodie-Fi ever had?
select 
 count(distinct customer_id)
from foodie_fi.subscriptions
order by 1
;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

with cte as (
select 
customer_id,
plan_id,
start_date,
extract('MONTH' from start_date) as start_month
from foodie_fi.subscriptions
where plan_id = 0
 )
 
 select 
 start_month,
 count(*)
 from cte
 group by start_month
 ;
 
