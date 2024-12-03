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
;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with cte as (
  select 
    customer_id, 
    plan_id,
    lead(plan_id) over(order by customer_id) lead_plan_id,
    start_date
  from foodie_fi.subscriptions
  order by customer_id
)

select
count(case when plan_id =0 and lead_plan_id = 4 then 1 
     else NULL
     end
     ) as trial_churn,     
 round(
 	(count(
      case when plan_id =0 and lead_plan_id = 4 then 1 
	  else NULL
      end
    )/sum(count(*)) over()) 
   		* 100, 0) as trial_churn_percentage
from cte
;

-- 6. What is the number and percentage of customer plans after their initial free trial?
with cte as (
  select 
    customer_id, 
    plan_id,
    lead(plan_id) over(order by customer_id) lead_plan_id,
    start_date
  from foodie_fi.subscriptions
  order by customer_id
),

count_cte as (
  select
    count(case when plan_id =0 and lead_plan_id = 4 then 1 
         else NULL
         end
         ) as trial_churn,
    count(case when plan_id =0 and lead_plan_id = 1 then 1 
         else NULL
         end
         ) as trial_basic_monthly,  
    count(case when plan_id =0 and lead_plan_id = 2 then 1 
         else NULL
         end
         ) as trial_pro_monthly,  
    count(case when plan_id =0 and lead_plan_id = 3 then 1 
         else NULL
         end
         ) as trial_pro_annual,
 	count(*) as total_customers
  from cte
)
select 
  trial_basic_monthly,
  round( (cast(trial_basic_monthly as numeric)/cast(total_customers as numeric)) * 100 , 2) as "trial_basic_monthly_%",
  trial_pro_monthly,
    round( (cast(trial_pro_monthly as numeric)/cast(total_customers as numeric)) * 100 , 2) as "trial_pro_monthly_%",
  trial_pro_annual,
    round( (cast(trial_pro_annual as numeric)/cast(total_customers as numeric)) * 100 , 2) as "pro_annual_%",
  trial_churn,
    round( (cast(trial_churn as numeric)/cast(total_customers as numeric)) * 100 , 2) as "trial_churn_%",
    total_customers
from count_cte
