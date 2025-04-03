/*
7. Product Report
- Purpose: Create Product report consolidating key product metrics and behaviors.
- Output expected:
+ Gathers essential fields such as product name, category, subcategory, and cost.
+ Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
+ Aggregates product-level metrics:
       -- total orders
       -- total sales
       -- total quantity sold
       -- total customers (unique)
       -- lifespan (in months)
+ Calculates valuable KPIs:
       -- recency (months since last sale)
       -- average order revenue (AOR)
       -- average monthly revenue
- SQL Functions Used: JOIN, CONCAT, TIMESTAMPDIFF, SUM, COUNT, MAX, CREATE VIEW
*/
-- Join 2 tables dim_products & fact_sales on product_key
-- Create base table with core values from 2 tables 
-- Create agg table: total orders, sales, qty, customers, Lifespan
-- Classify revenue
-- Calculate recency, avg order value, avg monthly revenue
-- Create view 

use gold;
select * from dim_products;
select * from fact_sales;

/*-------------------------------------------------
-- Create Report: gold.report_products
--------------------------------------------------*/
CREATE VIEW gold.report_products AS
/*-------------------------------------------------
1. Base table: query get core columns from 2 tables Products & Sales
--------------------------------------------------*/
with base1 as (
select 
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	s.order_number,
	s.customer_key,
	s.sales_amount,
	s.quantity,
	s.order_date
from dim_products p
left join fact_sales s
on s.product_key=p.product_key
where order_date is not null),

/*-------------------------------------------------
2. Agg table: aggregation of values at product level (total orders, sales, qty, customers, Lifespan)
--------------------------------------------------*/
agg_product as (
select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	timestampdiff(month, min(order_date), max(order_date)) AS lifespan,
	max(order_date) as last_sale_date,	
	count(distinct order_number) as total_orders,
	count(distinct customer_key) as total_customer,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity
from base1
group by		
	product_key,
	product_name,
	category,
	subcategory,
	cost)

 /*-------------------------------------------------
3. Classification: revenue
--------------------------------------------------*/
select 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
    lifespan,
	timestampdiff(month, last_sale_date,curdate()) AS recency_in_months,
    case
		when total_sales > 50000 then 'High-Performer'
		when total_sales >= 10000 then 'Mid-Range'
		else 'Low-Performer'
	end as product_segment,
	total_orders,
	total_customer,
	total_sales,
	total_quantity,

/*-------------------------------------------------
3. Calculation: 
- recency = today - last order
- avg order value = total sales/total orders
- avg monthly revenue = total sales/life span
--------------------------------------------------*/
	round(total_sales/total_orders,0) as avg_order_value,
	round(total_sales/lifespan,0) as avg_monthly_revenue
from agg_product; 

select * from report_products;