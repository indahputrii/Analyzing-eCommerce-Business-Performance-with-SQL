select * from customers_dataset 
select * from order_items_dataset
select * from orders_dataset
select * from payments_dataset
select * from product_dataset

-- 1. REVENUE PER YEAR 
CREATE TABLE total_revenue_per_year AS
SELECT date_part('year', od.order_purchase_timestamp) as year,
    SUM(revenue_per_order) AS total_revenue
FROM (
    SELECT 
		order_id, 
		SUM(price+freight_value) AS revenue_per_order
	FROM order_items_dataset
	GROUP BY 1
    ) rev
JOIN orders_dataset od
ON rev.order_id = od.order_id
WHERE od.order_status = 'delivered'
GROUP BY 1;


-- 2. TOTAL CANCEL ORDER PER YEAR 
CREATE TABLE total_cancel_per_year AS 
SELECT date_part('year', order_purchase_timestamp) as year,
COUNT(order_status) as cancelled_order 
FROM orders_dataset 
WHERE order_status = 'canceled'
GROUP BY 1;

-- 3. TOP CATEGORY WITH BIGGEST REVENUE PER YEAR
CREATE TABLE top_product_category_by_revenue_per_year AS 
SELECT 
	YEAR, 
	product_category_name, 
	revenue 
FROM (
SELECT 
	date_part('year', o.order_purchase_timestamp) AS year,
	p.product_category_name,
	SUM(oi.price + oi.freight_value) AS revenue,
	RANK() OVER(PARTITION BY 
date_part('year', o.order_purchase_timestamp) 
 ORDER BY 
SUM(oi.price + oi.freight_value) DESC) AS rk
FROM order_items_dataset oi
JOIN orders_dataset o ON o.order_id = oi.order_id
JOIN product_dataset p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
GROUP BY 1,2) sq
WHERE rk = 1


-- 4. TOP CATEGORY WITH LARGEST AMOUNT OF CANCELED
create table most_canceled_product_category_per_year as 
SELECT 
	year, 
	product_category_name, 
	num_canceled 
FROM (
SELECT 
	date_part('year', o.order_purchase_timestamp) AS year,
	p.product_category_name,
	COUNT(1) as num_canceled,
	RANK() OVER(PARTITION BY 
date_part('year', o.order_purchase_timestamp) 
			 ORDER BY COUNT(1) DESC) AS rk
FROM order_items_dataset oi
JOIN orders_dataset o ON o.order_id = oi.order_id
JOIN product_dataset p ON p.product_id = oi.product_id
WHERE o.order_status = 'canceled'
GROUP BY 1,2) sq
WHERE rk = 1
