-- Create Schemas & Insert data
CREATE SCHEMA gold;
USE gold;

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number varchar(50) ,
	product_name varchar(50) ,
	category_id varchar(50) ,
	category varchar(50) ,
	subcategory varchar(50) ,
	maintenance varchar(50) ,
	cost int,
	product_line varchar(50),
	start_date date 
);

CREATE TABLE gold.fact_sales(
	order_number varchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);

LOAD DATA INFILE 'C:\gold.dim_customers.csv'
INTO TABLE gold.dim_customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select count(*) from gold.dim_customers;

select * from dim_customers
limit 0, 200000;

LOAD DATA INFILE 'C:\gold.dim_products.csv'
INTO TABLE gold.dim_products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select count(*) from dim_products;

LOAD DATA INFILE 'C:\gold.fact_sales_.csv'
INTO TABLE gold.fact_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from fact_sales;



