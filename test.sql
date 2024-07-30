create database onlinebussinessdb;

use onlinebussinessdb;

select * from onlinebussinessdb.categories;
select * from onlinebussinessdb.customers;
select * from onlinebussinessdb.orderitems;
select * from onlinebussinessdb.orders;
select * from onlinebussinessdb.products;


CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(50),
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(50),
    Country VARCHAR(50),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE Products (
    ProductId INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(50),
    CategoryID INT,
    Price DECIMAL(10 , 2 ),
    Stock INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- .....   ALTERING THE ProductId

ALTER TABLE Products 
RENAME COLUMN ProductId to ProductID; 


CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100),
    Description VARCHAR(255)
);


CREATE TABLE Orders (
    OrderId INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10 , 2 ),
    FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
);

-- .....   ALTERING THE OrderID

ALTER TABLE Orders 
RENAME COLUMN OrderId to OrderID; 


CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10 , 2 ),
    FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID),
    FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
);


INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');


INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);


INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');


INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, NOW(), 719.98),
(2, NOW(), 49.99),
(3, NOW(), 44.98);


INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);


-- Query 1: Retrieve all orders for a specific customer

SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    oi.ProductID,
    p.ProductName,
    oi.Quantity,
    oi.Price
FROM
    Orders o
        JOIN
    OrderItems oi ON o.OrderId = oi.OrderID
        JOIN
    Products p ON oi.ProductID = p.ProductID
WHERE
    o.CustomerID = 3;

-- Query 2: Find the total sales for each product

SELECT 
    p.ProductID,
    p.ProductName,
    SUM(oi.Price * oi.Quantity) AS Total_Sales
FROM
    OrderItems oi
        JOIN
    Products p ON p.ProductID = oi.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY Total_Sales DESC;


-- Query 3: Calculate the average order value

SELECT 
    AVG(TotalAmount) AS AverageOrderValue
FROM
    Orders;

-- Query 4: List the top 5 customers by total spending

SELECT 
    C.CustomerID, O.TotalAmount
FROM
    CustomerS C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
WHERE
    O.TotalAmount
LIMIT 5;

-- OPTIMIZED QUERY 

SELECT CustomerID , FirstName , Total_Spendings
FROM 
(
SELECT C.CustomerID , C.FirstName , SUM(O.TotalAmount) AS Total_Spendings , 
ROW_NUMBER() OVER (ORDER BY SUM(O.TotalAmount) DESC ) AS RN 
FROM Customers C 
JOIN Orders O
ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID , C.FirstName 
) 
Res WHERE RN <= 5;

-- Query 5: Retrieve the most popular product category


SELECT CategoryID , CategoryName , TOTALQUANTITYSOLD , RN 
FROM
(SELECT C.CategoryID , C.CategoryName , SUM(OI.Quantity) AS TOTALQUANTITYSOLD , 
ROW_NUMBER () OVER (ORDER BY SUM(OI.Quantity) DESC) AS RN
FROM OrderItems OI 
JOIN Products P
ON OI.ProductID = P.ProductID
JOIN Categories C
ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryID , C.CategoryName 
)
RES 
WHERE RN = 1;


-- Query 6: List all products that are out of stock, i.e. stock = 0

SELECT ProductID , ProductName , Stock  from products 
where Stock = 0;

-- with category name
SELECT p.ProductID, p.ProductName, c.CategoryName, p.Stock 
FROM Products p JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE Stock = 0;


-- Query 7: Find customers who placed orders in the last 30 days

SELECT C.CustomerID , C.FirstName , C.LastName , C.Phone , C.Email 
FROM Customers C
JOIN Orders O 
ON C.CustomerID = O.CustomerID
WHERE O.OrderDate >= DATE_SUB(NOW(), INTERVAL 30 DAY);


-- Query 8: Calculate the total number of orders placed each month

SELECT MONTH(OrderDate) as OrderMonth,
YEAR(OrderDate) AS OrderYear, 
COUNT(OrderID) AS TOTALOrders 
FROM Orders
GROUP BY OrderYear , OrderMonth
ORDER BY OrderYear , OrderMonth ;


-- Query 9: Retrieve the details of the most recent order

SELECT O.OrderID , C.FirstName , C.LastName , O.OrderDate , O.TotalAmount  
FROM Orders O 
JOIN Customers C 
ON O.CustomerID = C.CustomerID
ORDER BY O.OrderDate DESC LIMIT 1 ;


--  10: Find the average price of products in each category

SELECT c.CategoryID, c.CategoryName, round(AVG(p.Price), 2) as AveragePrice 
FROM Categories c JOIN Products p
ON c.CategoryID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName;


-- Query 11: List customers who have never placed an order

-- SELECT C.CustomerID , O.OrderID, C.FirstName , C.LastName ,C.Email, C.Phone , O.TotalAmount 
-- FROM Customers C  
-- FULL JOIN Orders O
-- ON O.CustomerID = O.CustomerID
-- WHERE O.OrderID = 0

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone, O.OrderID, o.TotalAmount
FROM Customers c LEFT OUTER JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderId IS NULL;


-- Query 12: Retrieve the total quantity sold for each product


SELECT P.ProductID , P.ProductName , SUM(O.Quantity) 
From Products P 
JOIN Orderitems O
ON P.ProductID = O.ProductID
GROUP BY P.ProductID , P.ProductName 
ORDER BY P.ProductID;

-- If we use indeing here so we can optimize it futher ...

-- CREATE INDEX idx_products_productid ON Products(ProductID);
-- CREATE INDEX idx_orderitems_productid ON Orderitems(ProductID);


-- Query 13: Calculate the total revenue generated from each category

SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;



-- Query 14: Find the highest-priced product in each category

SELECT c.CategoryID, c.CategoryName, p1.ProductID, p1.ProductName, p1.Price
FROM Categories c
JOIN Products p1 ON c.CategoryID = p1.CategoryID
WHERE p1.Price = (SELECT MAX(Price) FROM Products p2 WHERE p2.CategoryID = p1.CategoryID)
ORDER BY p1.Price DESC;
 
 

-- Query 15: Retrieve orders with a total amount greater than a specific value (e.g., $500)
  
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.TotalAmount >= 500
ORDER BY o.TotalAmount DESC;
 
 
 
-- Query 16: List products along with the number of orders they appear in

SELECT p.ProductID, p.ProductName, COUNT(oi.OrderID) as OrderCount
FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY OrderCount DESC;
  
 
-- Query 17: Find the top 3 most frequently ordered products
  
SELECT p.ProductID, p.ProductName, COUNT(oi.OrderID) AS OrderCount
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY OrderCount DESC
LIMIT 3;
 
 
 
-- Query 18: Calculate the total number of customers from each country
 
SELECT Country, COUNT(CustomerID) AS TotalCustomers
FROM Customers
GROUP BY Country
ORDER BY TotalCustomers DESC;
 
 
-- Query 19: Retrieve the list of customers along with their total spending
  
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
 
 
-- Query 20: List orders with more than a specified number of items (e.g., 5 items)
 
 
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(oi.OrderItemID) >= 5
ORDER BY NumberOfItems DESC;
 
 


#########                                   
/*

===========================
WINDOW FUNCTIONS QUESTIONS ....
===========================
 */
#########


### Question 1: Calculate the running total of `TotalAmount` for each order placed by each customer.

SELECT 
    CustomerID, 
    OrderID, 
    OrderDate, 
    TotalAmount, 
    SUM(TotalAmount) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotal
FROM Orders;


### Question 2: Determine the rank of each product within its category based on price.
 
SELECT 
    ProductID, 
    ProductName, 
    CategoryID, 
    Price, 
    RANK() OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS PriceRank
FROM Products;
 

### Question 3: Find the average `TotalAmount` of orders for each customer and the difference of each order's `TotalAmount` from the customer's average.

SELECT 
    CustomerID, 
    OrderID, 
    TotalAmount, 
    AVG(TotalAmount) OVER (PARTITION BY CustomerID) AS AvgTotalAmount, 
    TotalAmount - AVG(TotalAmount) OVER (PARTITION BY CustomerID) AS DifferenceFromAvg
FROM Orders;


### Question 4: Calculate the cumulative quantity of each product sold across all orders.

SELECT 
    ProductID, 
    SUM(Quantity) AS TotalQuantitySold, 
    SUM(SUM(Quantity)) OVER (ORDER BY ProductID) AS CumulativeQuantitySold
FROM OrderItems
GROUP BY ProductID
ORDER BY ProductID;


### Question 5: Identify the most recent order date for each customer.

SELECT 
    CustomerID, 
    OrderID, 
    OrderDate, 
    MAX(OrderDate) OVER (PARTITION BY CustomerID) AS MostRecentOrderDate
FROM Orders;


### Question 6: Calculate the percentage contribution of each products price to the total price of all products within the same category.

SELECT 
    ProductID, 
    ProductName, 
    CategoryID, 
    Price, 
    Price / SUM(Price) OVER (PARTITION BY CategoryID) * 100 AS PricePercentage
FROM Products;


### Question 7: Find the first order date and last order date for each customer.

SELECT 
    CustomerID, 
    OrderID, 
    OrderDate, 
    MIN(OrderDate) OVER (PARTITION BY CustomerID) AS FirstOrderDate, 
    MAX(OrderDate) OVER (PARTITION BY CustomerID) AS LastOrderDate
FROM Orders;


### Question 8: Calculate the difference in days between consecutive orders for each customer.

SELECT 
    CustomerID, 
    OrderID, 
    OrderDate, 
    LAG(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate, 
    DATEDIFF(OrderDate, LAG(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY OrderDate)) AS DaysBetweenOrders
FROM Orders;

 
#########                                   
/*

===========================
 🛠️ LOG MAINTENANCE 
===========================
 */
######### 

-- Automate SQL Server Logging with Triggers  
  
 
-- create a log table ....

CREATE TABLE ChangeLog 
(
	LogID INT PRIMARY KEY AUTO_INCREMENT,
    TableName VARCHAR(100),
    Operations Varchar(20),
    RecordID INT, 
    ChangeDate DATETIME DEFAULT current_timestamp,
    ChangedBy VARCHAR(100)
); 

DROP TABLE IF EXISTS changinglogs;

DROP TRIGGER IF EXISTS triggers_Insert_Products;


-- Trigger for INSERT on Products table
 
DELIMITER //

CREATE TRIGGER trg_Insert_Products 
AFTER INSERT ON Products 
FOR EACH ROW 
BEGIN
    -- Insert a record into the CHANGINGLOGS table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Products', 'INSERT', NEW.ProductID, USER());

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
--     VALUES ('Operation completed ....');
END; //

DELIMITER ;



INSERT INTO Products(ProductName , CategoryID , Price , Stock)
VALUES('Mouse' , 2 , 48.99, 50); 

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Spiderman Multiverse Comic', 3, 2.50, 150);


-- Display the products table  
SELECT * FROM onlinebussinessdb.products;

-- Display the changelog table  
SELECT * FROM onlinebussinessdb.changelog;



 -- Trigger for update table ..

DELIMITER //

CREATE TRIGGER trg_Update_Product 
AFTER UPDATE ON Products 
FOR EACH ROW 
BEGIN
    -- Insert a record into the CHANGINGLOGS table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Products', 'UPDATE', NEW.ProductID, USER());

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
--     VALUES ('Operation completed ....');

END; //

DELIMITER ;


-- Update any row from the Products table .....

UPDATE Products SET Price = 990 
WHERE ProductID = 2;

UPDATE Products SET Price = Price - 300 
WHERE ProductID = 2;
 

-- Display the products table  
SELECT * FROM onlinebussinessdb.products;

-- Display the changelog table  
SELECT * FROM onlinebussinessdb.changelog;


-- Trigger for delete table ..

DELIMITER //

CREATE TRIGGER trg_delete_Product 
AFTER DELETE ON Products 
FOR EACH ROW 
BEGIN
    -- Insert a record into the ChangeLog table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Products', 'DELETE', OLD.ProductID, USER());
    
    -- OLD.ProductID: Refers to the ProductID of the row that was deleted from the Products table.
	-- USER(): Returns the current MySQL user.
	-- The commented-out section is left as is, and you can uncomment it if needed.

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
    -- VALUES ('Operation completed ....');

END; //

DELIMITER ;

-- DELETE any row from the Products table .....

DELETE FROM Products 
WHERE ProductID = 10;

-- Display the products table  
SELECT * FROM onlinebussinessdb.products;

-- Display the changelog table  
SELECT * FROM onlinebussinessdb.changelog;


--  NOW FOR THE CUSTOMER TABLE ....

-- Trigger for INSERT on Products table

DELIMITER //

CREATE TRIGGER trg_Insert_Customers 
AFTER INSERT ON Customers 
FOR EACH ROW 
BEGIN
    -- Insert a record into the CHANGINGLOGS table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Customers', 'INSERT', NEW.CustomerID, USER());

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
--     VALUES ('Operation completed ....');
END; //

DELIMITER ;


-- Trigger for update table ..

DELIMITER //

CREATE TRIGGER trg_Update_Customers
AFTER UPDATE ON Customers 
FOR EACH ROW 
BEGIN
    -- Insert a record into the CHANGINGLOGS table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Customers', 'UPDATE', NEW.CustomerID, USER());

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
    -- VALUES ('Operation completed ....');

END; //

DELIMITER ;

-- Trigger for Delete on Products table

DELIMITER //

CREATE TRIGGER trg_delete_Customers
AFTER DELETE ON Customers 
FOR EACH ROW 
BEGIN
    -- Insert a record into the ChangeLog table
    INSERT INTO ChangeLog (TableName, Operations, RecordID, ChangedBy)
    VALUES ('Customers', 'DELETE', OLD.CustomerID, USER());
    
    -- OLD.ProductID: Refers to the ProductID of the row that was deleted from the Products table.
	-- USER(): Returns the current MySQL user.
	-- The commented-out section is left as is, and you can uncomment it if needed.

    -- Insert a log message into the OperationLogs table
    -- INSERT INTO OperationLogs (LogMessage)
    -- VALUES ('Operation completed ....');

END; //

DELIMITER ;


-- Try to insert a new record to see the effect of Trigger
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 
'Delhi', '5456665', 'INDIA');

-- Display the Customers Table ... 
SELECT * FROM onlinebussinessdb.customers;

-- DELETED DUPLICATE ROWS ADDED BY MISTAKE ......
DELETE FROM Customers WHERE CustomerID = 6;



#########                                   
/*

===========================
Implementing Indexing 📊
===========================
 */
######### 


















#########                                   

/*

===========================
Implementing Views 📊
===========================
 
*/

#########


-- View for Product Details: A view combining product details with category names.
CREATE VIEW vw_ProductDetails AS
SELECT ProductID ,  ProductName , Price , Stock , CategoryName 
FROM Products P 
INNER JOIN Categories C
ON P.CategoryID = C.CategoryID;

SELECT * FROM vw_ProductDetails;


-- View for Customer Orders : A view to get a summary of orders placed by each customer.

SELECT C.CustomerID , C.FirstName , C.LastName , COUNT(OI.OrderID) AS T











