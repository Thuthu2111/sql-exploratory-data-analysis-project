/*
4. Part-to-Whole Analysis
- Purpose: which categories contribute the most to overall sales.
- Output expected: category, total sales, % to total sales
- SQL Functions Used: JOIN, SUM, SUM() OVER()
*/
-- join 2 tables fact_sales & dim_products on product key
-- total sales by category: sum(sales) group by cat
-- overall sales: sum(total sales) over()
-- percentage= total sales/overall sales*100

use gold;

select * from dim_products;

select * from fact_sales;

select category,
sum(sales_amount) as total_sales,
concat(round(sum(sales_amount)/(sum(sum(sales_amount)) over())*100,2),'%') as percentage_of_total
from fact_sales s 
left join dim_products p 
on s.product_key=p.product_key
group by category;