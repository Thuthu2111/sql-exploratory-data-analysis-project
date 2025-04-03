/*
3. Performance Analysis
- Purpose: Analyze the yearly performance of products by comparing each product's sale to both its avg & previous year's sale.
- Output expected: year, product_name, current sales, avg sales, diff vs avg sales, previous sales, diff vs previous sales
- SQL Functions Used: JOIN, SUM, AVG() over(), LAG () over, CASE WHEN
*/
-- join 2 tables fact_sales & dim_products on product key
-- current_sales: sum(sales) group by year, product name
-- avg_sales: avg(current_sales) over(product name)
-- pre_sales: lag(current_sales) over()
-- calculate difference between current_sales vs (avg_sales & pre_sales)
-- classify difference 

USE gold;

select *
from fact_sales;

select *
from dim_products;

with a as
(select year(order_date) as order_year,
product_name,
sum(sales_amount) as current_sales
from fact_sales s
join dim_products p
on s.product_key=p.product_key
group by year(order_date), product_name
order by product_name)
select order_year,
product_name,
current_sales,
round(avg(current_sales) over(partition by product_name),0) as avg_sales,
current_sales- round(avg(current_sales) over(partition by product_name),0) as diff_avg,
case
	when current_sales- round(avg(current_sales) over(partition by product_name),0)<0 then 'Below Avg'
    when current_sales- round(avg(current_sales) over(partition by product_name),0)>0 then 'Above Avg'
    else 'Avg'
end as change_avg,
lag(current_sales) over(partition by product_name) as pre_sales,
current_sales-lag(current_sales) over(partition by product_name) as diff_pre,
case
	when current_sales-lag(current_sales) over(partition by product_name)<0 then 'Decrease'
    when current_sales-lag(current_sales) over(partition by product_name)>0 then 'Increase'
    else 'No Change'
end as change_pre
from a
order by product_name;

