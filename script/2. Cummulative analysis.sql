/*
2. Cumulative Analysis
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
*/
-- Calculate the total sales per month 
-- and the running total of sales over time 
USE gold;

select * from fact_sales;

select
order_year,
total_sales,
sum(total_sales) over(order by order_year) as running_total_sales,
round(avg(avg_price) over(order by order_year),0) as moving_avg_price
from
(
select
year(order_date) as order_year,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date)
) a;