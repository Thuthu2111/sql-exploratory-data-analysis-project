/*
1.Change Over Time Analysis
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: EXTRACT(), YEAR(), MONTH()
    - Aggregate Functions: SUM(), COUNT()
*/
USE gold;

select * from fact_sales;

select 
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount) total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_qty
from fact_sales
where order_date is not null
group by year(order_date), month(order_date)
order by year(order_date), month(order_date);

select 
extract(year_month from order_date) as order_month, 
sum(sales_amount) total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_qty
from fact_sales
where order_date is not null
group by extract(year_month from order_date)
order by extract(year_month from order_date);
