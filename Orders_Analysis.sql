-- Data Analysis

SELECT * FROM public.orders

-- Find top 10 highest revenue generating products
select product_id, sum(sale_price) as sales 
from public.orders
group by product_id
order by sales desc

-- Find top 5 highest selling products in each region
with cte as (
	select region, product_id, sum(sale_price) as sales
	from public.orders
	group by region, product_id
)
select * from (
select *, row_number() over(partition by region order by sales desc) as row_num
from cte) A
where row_num<=5

-- Find month over month growth comparison for 2022 and 2023 sales
with cte as (
select extract(year from order_date) as order_year, 
extract(month from order_date) as order_month, 
sum(sale_price) as sales
from public.orders
group by order_year, order_month
-- order by order_year, order_month
)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

-- For each Category which month has the highest sales
with cte as (
select category, extract(month from order_date) as order_year_month
, sum(sale_price) as sales
from public.orders
group by category, order_year_month
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as row_num
from cte
) a
where row_num=1

-- Which sub category had highest growth by profit in 2023 vs 2022
with cte as (
select sub_category, extract(year from order_date) as order_year,
	sum(sale_price) as sales
	from public.orders
	group by sub_category, order_year
)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select * ,
(sales_2022-sales_2023)*100/sales_2022 as percent_sales
from cte2
order by percent_sales
-- 
