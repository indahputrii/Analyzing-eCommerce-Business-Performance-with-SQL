-- Create customer dataset
CREATE TABLE IF NOT EXISTS public.customers_dataset
(
    customer_id character varying,
    customer_unique_id character varying,
    customer_zip_code_prefix numeric,
    customer_city character varying,
    customer_state character varying);

-- Create geolocation dataset
CREATE TABLE IF NOT EXISTS public.geolocation_dataset
(
    geolocation_zip_code_prefix character varying,
    geolocation_lat double precision,
    geolocation_lng double precision,
    geolocation_city character varying,
    geolocation_state character varying);

-- Create order_item dataset
CREATE TABLE IF NOT EXISTS public.order_items_dataset
(
    order_id character varying,
    order_item_id numeric,
    product_id character varying,
    seller_id character varying,
    shipping_limit_date timestamp with time zone,
    price double precision,
    freight_value double precision);

-- Crate order_payments dataset
CREATE TABLE IF NOT EXISTS public.order_payments_dataset
(
    order_idorder_id character varying,
    payment_sequential numeric,
    payment_type character varying,
    payment_installments numeric,
    payment_value double precision);

-- Create order_reviews dataset
CREATE TABLE IF NOT EXISTS public.order_reviews_dataset
(
    review_id character varying,
    order_id character varying,
    review_score numeric,
    review_comment_title character varying,
    review_comment_message character varying,
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone);

-- Create product dataset
CREATE TABLE IF NOT EXISTS public.product_dataset
(
    "number" numeric,
    product_id character varying,
    product_category_name character varying,
    product_name_lenght double precision,
    product_description_lenght double precision,
    product_photos_qty double precision,
    product_weight_g double precision,
    product_length_cm double precision,
    product_height_cm double precision,
    product_width_cm double precision);

-- create seller dataset
CREATE TABLE IF NOT EXISTS public.sellers_dataset
(
    seller_id character varying,
    seller_zip_code_prefix numeric,
    seller_city character varying,
    seller_state character varying);

-- Create orders dataset
CREATE TABLE IF NOT EXISTS public.orders_dataset
(
    order_id character varying,
    customer_id character varying,
    order_status character varying,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone);

-- check product_id pada product_dataset dan order_items_dataset
select * from product_dataset where product_id in(
select product_id from (select product_id, count(*)
					   from product_dataset
					   group by product_id
					   having count(*) > 1) as foo);
					    
select * from order_items_dataset where product_id in (
select product_id from (select product_id, count(*)
						from order_items_dataset
						group by product_id
						having count(*) > 1) as foo);

-- hubungan kolom product_id antara product_dataset dengan order_items_dataset 
-- adalah one to many. tidak ada duplikat pada product_dataset

-- hubungan seller_id dalam seller_dataset drngan order_items_dataset
select * from sellers_dataset where seller_id in(
select seller_id from (select seller_id, count(*)
					 from sellers_dataset
					 group by seller_id
					 having count(*) > 1) as foo);

select * from order_items_dataset where seller_id in(
select seller_id from (select seller_id, count(*)
					  from order_items_dataset
					  group by seller_id
					  having count(*) > 1) as foo);

-- hubungan seller_id pada sellers_dataset dengan order_items_dataset
-- adalah one to many. tidak ada duplikat pada sellers_dataset

-- hubungan order_id pada payments_dataset dengan orders_dataset 
select * from payments_dataset where order_id in (
select order_id from(select order_id, count(*) 
					 from payments_dataset
					 group by order_id
					 having count(*) > 1) as foo);

select * from orders_dataset where order_id in(
select order_id from(select order_id, count(*)
					from orders_dataset
					group by order_id
					having count(*) > 1) as foo);
					
-- hubungan seller_id pada payments_dataset dengan orders_dataset
-- adalah one to many. tidak ada duplikat order_id pada orders_dataset

-- hubungan order_id pada orders_dataset dengan reviews_dataset
select * from reviews_dataset where order_id in (
select order_id from(select order_id, count(*)
					from reviews_dataset
					group by order_id
					having count(*) > 1) as foo);
					
-- hubungan order_id pada orders_dataset dengan reviews_dataset
-- adalah one to many

-- hubungan order_id pada orders_dataset dengan order_items_dataset
select * from order_items_dataset where order_id in (
select order_id from(select order_id, count(*)
					from order_items_dataset
					group by order_id
					having count(*) > 1) as foo);

-- hubungan order_id pada orders_dataset dengan order_items_dataset
-- adalah one to many

-- hubungan geolocation_code pada geolocations_dataset dengan sellers_dataset
select * from geolocation_dataset where geolocation_zip_code_prefix in (
select geolocation_zip_code_prefix from(select geolocation_zip_code_prefix, count(*)
						   from geolocation_dataset
						   group by geolocation_zip_code_prefix
						   having count(*) > 1) as foo);

select * from sellers_dataset where seller_zip_code_prefix in (
select seller_zip_code_prefix from(select seller_zip_code_prefix, count(*)
						   from sellers_dataset
						   group by seller_zip_code_prefix
						   having count(*) > 1) as foo);
						   
-- hubungan geolocation_code pada geolocations_dataset dengan sellers_dataset
-- adalah many to many. geolocation_code pada geolocations_dataset tidak unique

-- hubungan geolocation_code pada geolocations_dataset dengan customers_dataset
select * from customers_dataset where customer_zip_code_prefix in (
select customer_zip_code_prefix from(select customer_zip_code_prefix, count(*)
						   from customers_dataset
						   group by customer_zip_code_prefix
						   having count(*) > 1) as foo);

-- hubungan geolocation_code pada geolocations_dataset dengan customers_dataset
-- adalah many to many

-- hubungan customer_id pada customers_dataset dengan order_dataset
select * from customers_dataset where customer_id in (
select customer_id from(select customer_id, count(*)
						   from customers_dataset
						   group by customer_id
						   having count(*) > 1) as foo);

select * from orders_dataset where customer_id in (
select customer_id from(select customer_id, count(*)
						   from orders_dataset
						   group by customer_id
						   having count(*) > 1) as foo);

-- hubungan customer_id pada customers_dataset dengan order_dataset
-- adalah one to one. customer_id pada customers_dataset unique

-- SETTING PRIMARY KEY
alter table product_dataset add constraint pk_products primary key (product_id);
alter table customers_dataset add constraint pk_cust primary key (customer_id);
alter table geolocation_dataset add constraint pk_geo primary key (geolocation_zip_code_prefix);
alter table orders_dataset add constraint pk_orders primary key (order_id);
alter table sellers_dataset add constraint pk_seller primary key (seller_id);

-- SETTING FOREIGN KEY
alter table customers_dataset add foreign key (customer_zip_code_prefix) references geolocation_dataset;
alter table orders_dataset add foreign key (customer_id) references customers_dataset;
alter table order_items_dataset add foreign key (order_id) references orders_dataset;
alter table order_items_dataset add foreign key (seller_id) references sellers_dataset;
alter table order_items_dataset add foreign key (product_id) references product_dataset;
alter table sellers_dataset add foreign key (seller_zip_code_prefix) references geolocation_dataset;
alter table payments_dataset add foreign key (order_id) references orders_dataset;
alter table reviews_dataset add foreign key (order_id) references orders_dataset; 

ALTER TABLE geolocation_dataset
ALTER COLUMN geolocation_zip_code_prefix type character varying;



