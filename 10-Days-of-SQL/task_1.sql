-- 1.1 Select the names of all the products in the store.
SELECT name
FROM Products;

-- 1.2 Select the names and the prices of all the products in the store.
SELECT name, price
FROM Products;

-- 1.3 Select the name of the products with a price less than or equal to $200.
SELECT name
FROM Products
WHERE price <= 200;

-- 1.4 Select all the products with a price between $60 and $120.
SELECT *
FROM Products
WHERE price BETWEEN 60 AND 120;

-- 1.5 Select the name and price in cents (i.e., the price must be multiplied by 100).
SELECT name, price * 100 AS Cents
FROM Products;

-- 1.6 Compute the average price of all the products.
SELECT ROUND(AVG(price), 2) AS average_price
FROM Products;

-- 1.7 Compute the average price of all products with manufacturer code equal to 2.
SELECT ROUND(AVG(price), 2) AS average_price
FROM Products
WHERE manufacturer = 2;

-- 1.8 Compute the number of products with a price larger than or equal to $180.
SELECT COUNT(*) AS number_of_products
FROM Products
WHERE price >= 180;

-- 1.9 Select the name and price of all products with a price larger than or equal to $180, 
--     and sort first by price (in descending order), and then by name (in ascending order).
SELECT name, price
FROM Products
WHERE price >= 180
ORDER BY price DESC, name ASC;

-- 1.10 Select all the data from the products, including all the data for each product's manufacturer.
SELECT *
FROM Products
JOIN Manufacturers
ON manufacturer = manufacturers.code;

-- 1.11 Select the product name, price, and manufacturer name of all the products.
SELECT products.name, price, manufacturers.name
FROM Products
JOIN Manufacturers
ON manufacturer = manufacturers.code;

-- 1.12 Select the average price of each manufacturer's products, showing only the manufacturer's code.
SELECT ROUND(AVG(products.price)), manufacturer
FROM Products
GROUP BY manufacturer;

-- 1.13 Select the average price of each manufacturer's products, showing the manufacturer's name.
SELECT ROUND(AVG(products.price)), manufacturers.name
FROM Products
JOIN Manufacturers
ON manufacturer = manufacturers.code
GROUP BY manufacturers.name;

-- 1.14 Select the names of manufacturer whose products have an average price larger than or equal to $150.
SELECT manufacturers.name
FROM Manufacturers
JOIN Products
ON manufacturers.code = manufacturer
GROUP BY manufacturers.name
HAVING AVG(products.price) >= 150;

-- 1.15 Select the name and price of the cheapest product.
SELECT name, price
FROM Products
WHERE price = (
	SELECT MIN(price)
	FROM Products
);

-- 1.16 Select the name of each manufacturer along with the name and price of its most expensive product.
SELECT m.name, p.name, p.price
FROM Manufacturers m
JOIN Products p ON m.code = p.manufacturer
JOIN (
    SELECT manufacturer, MAX(price) AS max_price
    FROM Products
    GROUP BY manufacturer
) subquery
ON p.manufacturer = subquery.manufacturer AND p.price = subquery.max_price;

-- 1.17 Add a new product: Loudspeakers, $70, manufacturer 2.
INSERT INTO Products(Code,Name,Price,Manufacturer) VALUES(11,'Loudspeakers',70,2);

-- 1.19 Apply a 10% discount to all products.
ALTER TABLE Products
ADD discounted_price integer;

UPDATE Products
SET discounted_price = price * 0.9;

-- 1.20 Apply a 10% discount to all products with a price larger than or equal to $120.
UPDATE Products
SET discounted_price = price * 0.9
WHERE price >= 120;
