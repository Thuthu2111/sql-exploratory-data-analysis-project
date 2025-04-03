/*
5.1 Data Segmentation: Product by cost range
- Purpose: segment products into cost ranges and count no of products fall into each segment
- Output expected: cost range, no product
- SQL Functions Used: JOIN, CASE WHEN, COUNT
*/
-- Classify cost of product by Case when: product, cost, cost_range
-- Count no of product in each cost_ range
use gold;

select * from dim_products;

with b as (
select product_name,
cost,
case
	when cost<100 then 'Below 100'
    when cost between 100 and 500 then '100-500'
    when cost between 500 and 1000 then '500-1000'
    else 'Above 1000'
end as cost_range
from dim_products)

select cost_range,
count(product_name) as no_product
from b
group by cost_range
order by no_product desc;

/* 5.2. Data Segmentation: Customers by lifespan & spending
- Purpose: Group customers into 3 segments based on their spending behavior and count no of customes in each group:
+ VIP: cust >=12 months of history and spending> 5,000
+ Regular: cust >=12 months of history , spending <=5,000
+ New: cust with lifespan <12 months
Lifespan= month of history = time of last order - time of 1st order
- Output expected: customer_type, no of customer
- SQL Functions Used: JOIN, SUM, MIN, MAX, CASE WHEN, COUNT
*/
-- Join 2 tables Customers & Sales on customer_key
-- Calculate spending of each customer: sum(sales) group by customer_key
-- Calculate life span= max order date - min order date, group by customer key
-- Classify customers group based on life span & spending
-- Count no of customers in each customer group

select * from dim_customers;

select * from fact_sales;

with c as (
select c.customer_key,
sum(sales_amount) as total_Sales,
min(order_date) as first_order,
max(order_date) as last_order,
coalesce(timestampdiff(month, min(order_date), max(order_date)), 0) AS lifespan
from fact_sales s
left join dim_customers c
on s.customer_key=c.customer_key
group by c.customer_key)

select customer_segment,
count(customer_key) as no_customer
from (
	select customer_key,
	case
		when lifespan>=12 and total_sales>5000 then 'VIP'
		when lifespan>=12 and total_sales<=5000 then 'Regular'
		else 'New'
	end as customer_segment
	from c
) as d
group by customer_segment;
