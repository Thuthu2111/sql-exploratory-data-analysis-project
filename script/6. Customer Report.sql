/*
6. Customer Report
- Purpose: Create Customer report consolidating key customer metrics and behaviors. 
- Output expected: 
+ Gathers essential fields such as names, ages, and transaction details.
+ Segments customers into categories (VIP, Regular, New) and age groups.
+ Aggregates customer-level metrics:
	   -- total orders
	   -- total sales
	   -- total quantity purchased
	   -- total products
	   -- lifespan (in months)
+ Calculates valuable KPIs:
	    -- recency (months since last order)
		-- average order value
		-- average monthly spend
- SQL Functions Used: JOIN, CONCAT, TIMESTAMPDIFF, SUM, COUNT, MAX, CASE WHEN, CREATE VIEW
*/
-- Join 2 tables dim_customers & fact_sales on customer_key
-- Create base table: customer key, first & last name, birthdate, sales_amount, qty, order_number, product_key, order_date. Concat for customer_name. Calculate age by timestampdiff between today and birthdate
-- Create agg table: total orders, sales, qty, product, Lifespan= max order date - min order date
-- Classify age group & customer_segment
-- Calculate recency, avg order value, avg monthly spending
-- Create view 
use gold;
select * from dim_customers;
select * from fact_sales;

/*-------------------------------------------------
-- Create Report
--------------------------------------------------*/
create view gold.report_customers as
/*-------------------------------------------------
1. Base table: query get core columns from 2 tables
--------------------------------------------------*/
with base as (
select 
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	concat(first_name, ' ', last_name) as customer_name,
	timestampdiff(year,birthdate,curdate()) as age
from fact_sales s 
left join dim_customers c 
on s.customer_key=c.customer_key
where order_date is not null
),
/*-------------------------------------------------
2. Agg table: aggregation of values at customer level
--------------------------------------------------*/
agg as (
select 
	customer_key,
	customer_name,
	age,
	sum(sales_amount) as total_sales,
	count(distinct order_number) as total_orders,
	sum(quantity) as total_qty,
	count(distinct product_key) as total_product,
	timestampdiff(month, min(order_date), max(order_date)) AS lifespan,
    max(order_date) as last_order
from base
group by 
	customer_key, 
	customer_name,
	age)
/*-------------------------------------------------
3. Classification: age group and customer segment
--------------------------------------------------*/
select 
	customer_key,
	customer_name,
	age,
	case
		when age <20 then 'Under 20'
		when age between 20 and 29 then '20-29'
		when age between 30 and 39 then '30-39'
		when age between 40 and 49 then '40-49'
		else '50 and above'
	end as age_group,
	total_sales,
	case
		when lifespan >=12 and total_sales>5000 then 'VIP'
		when lifespan>=12 and total_sales<=5000 then 'Regular'
		else 'New'
	end as customer_segment,
	total_orders,
	total_qty,
	total_product,
	lifespan,
/*-------------------------------------------------
3. Calculation: 
- recency = today - last order
- avg order value = total sales/total orders
- avg monthly spend = total sales/life span
--------------------------------------------------*/
	timestampdiff(month,last_order,curdate()) AS recency,
	round(total_sales/total_orders,0) as avg_order_value,
	round(total_sales/lifespan,0) as avg_monthly_spend
from agg;

select * from report_customers;