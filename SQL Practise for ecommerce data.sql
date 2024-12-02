--Creating the 3 tables

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    JoinDate DATE
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);


CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


INSERT INTO Customers (CustomerID, Name, Email, JoinDate)
VALUES
(1, 'Alice', 'alice@mail.com', '2020-01-15'),
(2, 'Bob', 'bob@mail.com', '2019-03-20'),
(3, 'Charlie', 'charlie@mail.com', '2021-06-10');



INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
(101, 1, '2023-10-15', 200.50),
(102, 1, '2023-11-01', 150.00),
(103, 2, '2023-09-12', 300.00),
(104, 3, '2023-10-10', 100.00);


INSERT INTO Products (ProductID, ProductName, Price)
VALUES
(1, 'Laptop', 800.00),
(2, 'Mouse', 25.00),
(3, 'Keyboard', 40.00);


INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
VALUES
(1, 101, 1, 1),
(2, 101, 2, 2),
(3, 102, 3, 1),
(4, 103, 1, 1),
(5, 104, 2, 4);


--Task 1: High-Spending Customers
--Write a query to find customers who have spent more than $250 in total. Include their name, email, and total spending.

SELECT 
          Customers.Name,
	  Customers.Email,
	  SUM(Orders.TotalAmount) AS TotalSpending
FROM Customers 
LEFT JOIN Orders ON Customers.CustomerID = Orders.OrderID
GROUP BY Customers.Name,Customers.Email
HAVING SUM(Orders.TotalAmount)>250;

--Task 2: Popular Products
--Find the most frequently purchased product(s) and the total quantity sold.

--OPTION 1 USING JOINS
SELECT
    Products.ProductName,
    SUM(OrderDetails.Quantity) AS Total_Quantity
FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Products.ProductName;
	

--OPTION 2 AS A CTE

WITH ProductSales AS (
    SELECT 
        P.ProductID,
        P.ProductName,
        SUM(OD.Quantity) AS TotalQuantitySold
    FROM Products P
    JOIN OrderDetails OD ON P.ProductID = OD.ProductID
    GROUP BY P.ProductID, P.ProductName
)
SELECT 
    ProductID,
    ProductName,
    TotalQuantitySold
FROM ProductSales
WHERE TotalQuantitySold = (SELECT MAX(TotalQuantitySold) FROM ProductSales);


--Task 3: Customer Purchase Trends
--For each customer, calculate:
--The total number of orders they placed.
--Their average order value.

SELECT 
    CustomerID,
    COUNT(OrderID) AS TotalOrders,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(TotalAmount) AS AverageOrderValue
FROM Orders
GROUP BY CustomerID;

--Task 4: Order Insights
--Identify orders where the total value (calculated based on the products and their quantities) 
--does not match the TotalAmount in the Orders table

SELECT 
    O.OrderID,
    O.TotalAmount AS ReportedTotal,
    SUM(P.Price * OD.Quantity) AS CalculatedTotal
FROM Orders O
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY O.OrderID, O.TotalAmount
HAVING SUM(P.Price * OD.Quantity) <> O.TotalAmount;

	
--Task 5: Monthly Sales Report
--Generate a report showing total sales (in dollars) for each month of 2023.

SELECT 
    DATE_PART('year', OrderDate) AS Year,
    DATE_PART('month', OrderDate) AS Month,
    SUM(TotalAmount) AS TotalSales
FROM Orders
WHERE 
    DATE_PART('year', OrderDate) = 2023 -- Filter for the year 2023
GROUP BY 
    DATE_PART('year', OrderDate), 
    DATE_PART('month', OrderDate)
ORDER BY Year, Month;

