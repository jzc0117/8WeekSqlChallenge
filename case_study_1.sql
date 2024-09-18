/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- 1
select 
	customer_id,
    sum(price)
from dannys_diner.sales
join dannys_diner.menu on dannys_diner.sales.product_id = dannys_diner.menu.product_id
group by 1
order by 1
;

-- 2
select 
	customer_id,
    count (distinct order_date)
from dannys_diner.sales
group by 1
;

-- 3
with order_rank as(
    select 
	dannys_diner.sales.customer_id as customer,
        dannys_diner.sales.order_date as date,
        dannys_diner.menu.product_name as product_name,
        dense_rank() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date) as ranking
    from dannys_diner.sales
    join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
)
select distinct customer, date, product_name
from order_rank
where ranking = 1
;

-- 4
select 
    count(dannys_diner.sales.order_date) as number_of_sales,
    dannys_diner.menu.product_name as product_name
from dannys_diner.sales
join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
group by 2
order by 1 desc
limit 1
;

-- 5
with product_popularity as (
    select 
	dannys_diner.sales.customer_id as customer_id,
	dannys_diner.menu.product_name as product_name,
	rank() over(partition by dannys_diner.sales.customer_id order by count(dannys_diner.sales.order_date) desc) as ranking
    from dannys_diner.sales
    join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
    group by 1,2
    order by 1,3 
)

select
    customer_id,
    product_name
from product_popularity
where ranking = 1
;

--6
with subq as (
select 
    dannys_diner.members.customer_id as customer_id,
    dannys_diner.members.join_date as join_date,
    dannys_diner.sales.order_date as order_date,
    dannys_diner.menu.product_name as product_name,
    row_number() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date) as rn
from dannys_diner.members
join dannys_diner.sales on dannys_diner.members.customer_id = dannys_diner.sales.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
where dannys_diner.sales.order_date > dannys_diner.members.join_date 
order by 1, 3 
)

select 
    customer_id,
    join_date,
    order_date,
    product_name
from subq
where rn = 1
;

-- 7
with subq as (
select 
	dannys_diner.members.customer_id as customer_id,
    dannys_diner.members.join_date as join_date,
    dannys_diner.sales.order_date as order_date,
    -- dannys_diner.sales.product_id,
    dannys_diner.menu.product_name as product_name,
    row_number() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date desc) as rn
from dannys_diner.members
join dannys_diner.sales on dannys_diner.members.customer_id = dannys_diner.sales.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
where dannys_diner.sales.order_date < dannys_diner.members.join_date 

order by 1, 3 
)

select 
  customer_id,
  join_date,
  order_date,
  product_name
from subq
where rn = 1
;

-- 8
select 
    dannys_diner.members.customer_id as customer_id,
    count(dannys_diner.menu.product_name) as total_items,
    sum(dannys_diner.menu.price)
from dannys_diner.members
join dannys_diner.sales on dannys_diner.members.customer_id = dannys_diner.sales.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
where dannys_diner.sales.order_date < dannys_diner.members.join_date 
group by 1
order by 1

-- 9
with points_table as(
select 
    dannys_diner.sales.customer_id as customer_id,
	dannys_diner.sales.order_date,
    dannys_diner.menu.product_name,
    dannys_diner.menu.price,
    -- if(dannys_diner.menu.product_name = "sushi", dannys_diner.menu.price*2,dannys_diner.menu.price)  as points
    case when dannys_diner.menu.product_name='sushi' then 200 else (dannys_diner.menu.price*10) end as points
from dannys_diner.sales
join dannys_diner.menu on dannys_diner.menu.product_id = dannys_diner.sales.product_id 
-- group by 1
order by 1,2
)

select
	customer_id,
	sum(points)
from points_table
group by 1
;

--10
with dates_cte as (
	select 
  		customer_id,
  		join_date,
  		join_date + 7 as end_date
	from dannys_diner.members  	
)

select 
	dates_cte.customer_id,
	sum (case
		when dannys_diner.sales.product_id=1 then dannys_diner.menu.price * 20
        when dannys_diner.sales.order_date < dates_cte.end_date then dannys_diner.menu.price * 20
         else dannys_diner.menu.price * 10
         end) as points
from dannys_diner.sales 
join dates_cte on dannys_diner.sales.customer_id = dates_cte.customer_id
join dannys_diner.menu on dannys_diner.sales.product_id = dannys_diner.menu.product_id
where dannys_diner.sales.order_date >= dates_cte.join_date
and dannys_diner.sales.order_date <= '01-31-2021'
group by 1
order by 1
;


