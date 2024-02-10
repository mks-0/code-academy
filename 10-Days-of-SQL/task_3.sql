CREATE TABLE Warehouses (
   Code INTEGER NOT NULL,
   Location VARCHAR(255) NOT NULL ,
   Capacity INTEGER NOT NULL,
   PRIMARY KEY (Code)
 );
CREATE TABLE Boxes (
    Code CHAR(4) NOT NULL,
    Contents VARCHAR(255) NOT NULL ,
    Value REAL NOT NULL ,
    Warehouse INTEGER NOT NULL,
    PRIMARY KEY (Code)
 );
 
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(1,'Chicago',3);
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(2,'Chicago',4);
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(3,'New York',7);
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(4,'Los Angeles',2);
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(5,'San Francisco',8);
 
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('0MN7','Rocks',180,3);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('4H8P','Rocks',250,1);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('4RT3','Scissors',190,4);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('7G3H','Rocks',200,1);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('8JN6','Papers',75,1);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('8Y6U','Papers',50,3);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('9J6F','Papers',175,2);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('LL08','Rocks',140,4);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('P0H6','Scissors',125,1);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('P2T6','Scissors',150,2);
 INSERT INTO Boxes(Code,Contents,Value,Warehouse) VALUES('TU55','Papers',90,5);

--3.1 Select all warehouses.
SELECT *
FROM Warehouses;

--3.2 Select all boxes with a value larger than $150.
SELECT *
FROM Boxes
WHERE value > 150;

--3.3 Select all distinct contents in all the boxes.
SELECT DISTINCT contents
FROM Boxes;

--3.4 Select the average value of all the boxes.
SELECT ROUND(AVG(value))
FROM Boxes;

--3.5 Select the warehouse code and the average value of the boxes in each warehouse.
SELECT w.code, AVG(b.value)
FROM Boxes b
JOIN Warehouses w
ON w.code = b.warehouse
GROUP BY w.code;

--3.6 Same as previous exercise, but select only those warehouses where the average value of the boxes is greater than 150.
SELECT *
FROM (
	SELECT w.code, AVG(b.value) as avg_value
	FROM Boxes b
	JOIN Warehouses w
	ON w.code = b.warehouse
	GROUP BY w.code)
WHERE avg_value > 150;

--3.7 Select the code of each box, along with the name of the city the box is located in.
SELECT b.code, w.location
FROM Boxes b
JOIN Warehouses w
ON b.warehouse = w.code;

--3.8 Select the warehouse codes, along with the number of boxes in each warehouse. 
SELECT  warehouse, COUNT(*) cnt
FROM Boxes
GROUP BY warehouse

--3.9 Select the codes of all warehouses that are saturated
--(a warehouse is saturated if the number of boxes in it is larger than the warehouse's capacity).
SELECT w.code
FROM (
	SELECT  warehouse, COUNT(*) cnt
	FROM Boxes
	GROUP BY warehouse) b
JOIN Warehouses w
ON b.warehouse = w.code
WHERE w.capacity < b.cnt;


--3.10 Select the codes of all the boxes located in Chicago.
SELECT b.code
FROM Boxes b
JOIN Warehouses w
ON b.warehouse = w.code
WHERE w.location = 'Chicago';

--3.11 Create a new warehouse in New York with a capacity for 3 boxes.
 INSERT INTO Warehouses(Code,Location,Capacity) VALUES(6,'New York',3);

--3.12 Create a new box, with code "H5RT", containing "Papers" with a value of $200, and located in warehouse 2.
INSERT INTO Boxes (Code,Contents,Value,Warehouse) VALUES('H5RT', 'Papers', 200, 2);

--3.13 Reduce the value of all boxes by 15%.
ALTER TABLE Boxes
ADD reduced_value integer;

UPDATE Boxes
SET reduced_value = value * 0.85;

--3.14 Remove all boxes with a value lower than $100.
DELETE FROM Boxes
WHERE value < 100;

SELECT *
FROM Boxes
-- 3.15 Remove all boxes from saturated warehouses.
DELETE FROM Boxes b
WHERE EXISTS (
	SELECT 1
	FROM (
		SELECT  warehouse, COUNT(*) cnt
		FROM Boxes
		GROUP BY warehouse) b
	JOIN Warehouses w
	ON b.warehouse = w.code
	WHERE b.cnt > w.capacity 
);

-- 3.16 Add Index for column "Warehouse" in table "boxes"
    -- !!!NOTE!!!: index should NOT be used on small tables in practice
CREATE INDEX w_index
ON Boxes(warehouse);

-- 3.17 Print all the existing indexes
    -- !!!NOTE!!!: index should NOT be used on small tables in practice
SELECT indexname
FROM pg_indexes;

-- 3.18 Remove (drop) the index you added just
    -- !!!NOTE!!!: index should NOT be used on small tables in practice
DROP INDEX w_index;
