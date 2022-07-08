SELECT * FROM orders_dataset
SELECT * FROM customers_dataset
SELECT * FROM order_items_dataset
SELECT * FROM sellers_dataset

-- 1. MONTHLY ACTIVE USER (MAU) PER YEAR 
-- 1a. active customer per month per year 
SELECT year_, 
SUM(total_customer) as total_active_customer,
round(AVG(total_customer), 2) AS avg_active_customer
FROM (
SELECT date_part('year', od.order_purchase_timestamp) as year_,
	date_part('month', od.order_purchase_timestamp) as month_,
	COUNT(DISTINCT cd.customer_unique_id) as total_customer
	FROM orders_dataset od
	INNER JOIN customers_dataset cd ON od.customer_id = cd.customer_id
	GROUP BY 1, 2
) tc
GROUP BY 1

-- 1b. active seller per month per year
SELECT year_, 
SUM(total_seller) as total_active_customer,
round(AVG(total_seller), 2) AS avg_active_customer
FROM (
SELECT date_part('year', shipping_limit_date) as year_,
	date_part('month', shipping_limit_date) as month_,
	COUNT(DISTINCT seller_id) as total_seller
	FROM order_items_dataset
	GROUP BY 1, 2
) ts
GROUP BY 1

-- 2. TOTAL NEW CUSTOMER PER YEAR
SELECT date_part('year', newest) AS year_, new_customer
FROM
(SELECT date_part('year', od.order_purchase_timestamp) AS year_,
 		MIN(order_purchase_timestamp) as newest,
 		COUNT(DISTINCT cd.customer_unique_id) AS new_customer
FROM orders_dataset AS od
JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
WHERE order_status = 'delivered'
GROUP BY 1) NCY
GROUP BY 1,2;

-- 3. TOTAL CUSTOMER REPEAT ORDER PER YEAR 
SELECT year_, count(total_repeat) as total_repeat_order 
FROM (
SELECT date_part('year', od.order_purchase_timestamp) AS year_,
	cd.customer_unique_id, 
	COUNT(od.order_id) AS total_repeat
	FROM orders_dataset od
	JOIN customers_dataset cd ON od.customer_id = cd.customer_id
	GROUP BY 1, 2
	HAVING COUNT(od.order_id) > 1
) tpo
GROUP BY 1

-- 4. AVERAGE FREQUENCY ORDER PER YEAR
SELECT year_, round(AVG(total_order), 2) as freq_year
FROM (
	SELECT date_part('year',  od.order_purchase_timestamp) AS year_,
	cd.customer_unique_id,
	COUNT(DISTINCT od.order_id) AS total_order
	FROM orders_dataset od
	JOIN customers_dataset cd ON od.customer_id = cd.customer_id
	GROUP BY 1, 2
) fq
GROUP BY 1

