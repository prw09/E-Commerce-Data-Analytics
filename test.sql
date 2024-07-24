create database onlinebussinessdb;

use onlinebussinessdb;


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

SELECT c.CategoryID, c.CategoryName, AVG(p.Price) as AveragePrice 
FROM Categories c JOIN Products p
ON c.CategoryID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName;


