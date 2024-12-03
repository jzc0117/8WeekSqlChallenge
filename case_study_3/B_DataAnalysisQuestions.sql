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
 
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT 
	plan.plan_name,
	count(customer_id)
FROM foodie_fi.subscriptions s
join foodie_fi.plans as plan on s.plan_id = plan.plan_id 
where start_date >= '2021-01-01' 
group by 1
;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select 
	round(((select count(*) from foodie_fi.subscriptions where plan_id = 4)/sum(count(*)) over())*100, 1) as churned_percentage,
	count(*) as total_customers
from foodie_fi.subscriptions
