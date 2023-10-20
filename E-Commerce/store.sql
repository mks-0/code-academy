CREATE TABLE IF NOT EXISTS customer (
"id" varchar PRIMARY KEY,
"first_name" varchar(128),
"last_name" varchar(128),
"segment" varchar(128)
);

CREATE TABLE IF NOT EXISTS address (
"id" integer PRIMARY KEY,
"country" varchar(128),
"region" varchar(128),
"state" varchar(128),
"city" varchar(128),
"postal_code" integer
);

CREATE TABLE IF NOT EXISTS resident (
"customer_id" varchar(16),
"address_id" integer,
PRIMARY KEY ("customer_id", "address_id"),
FOREIGN KEY ("customer_id") REFERENCES "customer" ("id"),
FOREIGN KEY ("address_id") REFERENCES "address" ("id")
);

CREATE TABLE IF NOT EXISTS product (
"id" varchar(16) PRIMARY KEY,
"name" text,
"cost" float,
"sell_price" float,
"category" varchar(128),
"sub_category" varchar(128)
);

CREATE TABLE IF NOT EXISTS shipment (
"id" varchar(64) PRIMARY KEY,
"ship_mode" varchar(64),
"address_id" integer,
"ship_date" date,
FOREIGN KEY ("address_id") REFERENCES "address" ("id")
);

CREATE TABLE  IF NOT EXISTS orders (
"id" varchar(32) PRIMARY KEY,
"order_date" date,
"customer_id" varchar(16),
"shipment_id" varchar(64),
FOREIGN KEY ("shipment_id") REFERENCES "shipment" ("id"),
FOREIGN KEY ("customer_id") REFERENCES "customer" ("id")
);


CREATE TABLE IF NOT EXISTS orderitems (
"product_id" varchar(16),
"order_id" varchar(32),
"discount" float,
"quantity" integer,
PRIMARY KEY ("product_id", "order_id"),
FOREIGN KEY ("product_id") REFERENCES "product" ("id"),
FOREIGN KEY ("order_id") REFERENCES "orders" ("id")
);

 -- 1. What is the category generating the maximum sales revenue?
        -- What about the profit in this category?
        -- Are they making a loss in any categories?

SELECT p.category, SUM(p.sell_price *(1 - oi.discount) * oi.quantity)::numeric(30,2) as sales
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
JOIN Orders o ON o.id = oi.order_id
GROUP BY p.category
ORDER BY sales DESC
LIMIT 1;

SELECT p.category, 
SUM(p.sell_price *(1 - oi.discount) * oi.quantity - oi.quantity * p.cost)::numeric(30,2) as profit
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
JOIN Orders o ON o.id = oi.order_id
GROUP BY p.category
ORDER BY sales DESC
LIMIT 1;

SELECT *
FROM(
SELECT p.name, p.category,
SUM(p.sell_price *(1 - oi.discount) * oi.quantity - oi.quantity * p.cost)::numeric(30,2) as profit
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
JOIN Orders o ON o.id = oi.order_id
GROUP BY p.name, p.category)
WHERE profit < 0
ORDER BY profit

 --2. What are 5 states generating the maximum and minimum sales revenue?
 
CREATE TEMPORARY TABLE StateRevenue AS
SELECT a.state, 
SUM(p.sell_price *(1 - oi.discount) * oi.quantity)::numeric(30,2) as sales
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
JOIN Orders o ON o.id = oi.order_id
JOIN Shipment s ON s.id = o.shipment_id
JOIN Address a ON a.id = s.address_id
GROUP BY a.state
ORDER BY sales;

--Maximum
SELECT state
FROM StateRevenue
ORDER BY sales DESC
LIMIT 5;

--Minimum
SELECT state
FROM StateRevenue
ORDER BY sales
LIMIT 5;

 -- 3. What are the 3 products in each product segment with the highest sales?
        -- Are they the 3 most profitable products as well?

SELECT *
FROM(
SELECT DISTINCT st.id, st.name, st.sales, st.profit, c.segment,
DENSE_RANK () OVER (PARTITION BY segment ORDER BY sales DESC) AS s_rank, 
RANK () OVER (PARTITION BY segment ORDER BY profit DESC) AS p_rank
FROM(
SELECT p.id, p.name,
SUM(p.sell_price *(1 - oi.discount) * oi.quantity)::numeric(30,2) as sales,
SUM(p.sell_price *(1 - oi.discount) * oi.quantity - oi.quantity * p.cost)::numeric(30,2) as profit
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
GROUP BY p.id, p.name) as st
JOIN OrderItems oi ON st.id = oi.product_id
JOIN Orders o ON o.id = oi.order_id
JOIN Customer c ON c.id= o.customer_id)
WHERE s_rank <= 3
ORDER BY segment, s_rank

-- 4. What are the 3 best-seller products in each product segment? (Quantity-wise)
SELECT *
FROM(
SELECT qt.id, qt.name, p.segment, qt.total_quantity,
RANK () OVER (PARTITION BY segment ORDER BY total_quantity DESC) AS q_rank
FROM(
SELECT p.id, p.name,
SUM(oi.quantity) as total_quantity
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
GROUP BY p.id, p.name) as qt
JOIN Product p ON p.id = qt.id)
WHERE q_rank <= 3

-- 5. What are the top 3 worst-selling products in every category? (Quantity-wise)

SELECT *
FROM(
SELECT qt.id, qt.name, p.category, qt.total_quantity,
RANK () OVER (PARTITION BY category ORDER BY total_quantity ASC) AS q_rank
FROM(
SELECT p.id, p.name,
SUM(oi.quantity) as total_quantity
FROM Product p
JOIN OrderItems oi ON p.id = oi.product_id
GROUP BY p.id, p.name) as qt
JOIN Product p ON p.id = qt.id)
WHERE q_rank <= 3

-- 6. How many unique customers per month are there for the year 2016. 
SELECT yt.month, COUNT(DISTINCT yt.id)
FROM (
(SELECT c.id, EXTRACT(YEAR FROM o.order_date) as year, EXTRACT(MONTH FROM o.order_date) as month
FROM Customer c
JOIN Orders o ON c.id = o.customer_id)) yt
GROUP BY yt.month, yt.year
HAVING yt.year = 2016