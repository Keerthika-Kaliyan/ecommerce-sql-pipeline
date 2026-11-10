USE ECommercePipelineDB;
GO

--------------------------------------------------
-- PHASE 1: FOUNDATIONS & FILTERING (BASIC)
--------------------------------------------------

SELECT * FROM Categories;
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_Items;
SELECT * FROM Inventory_Audit_Log;


-- Definition: SELECT DISTINCT returns unique rows and LIKE filters text patterns.
-- Scenario: Retrieve a de-duplicated list of customer emails matching a domain pattern.

SELECT DISTINCT FirstName, LastName, Email
FROM Customers
WHERE Email LIKE '%@example.com';


-- Definition: BETWEEN filters a numeric range and ORDER BY sorts the result set.
-- Scenario: Review mid-tier products ordered by price descending.

SELECT ProductName, Price, StockQuantity
FROM Products
WHERE Price BETWEEN 100.00 AND 1500.00
ORDER BY Price DESC;


-- Definition: GROUP BY aggregates rows into groups and HAVING filters those groups based on aggregate conditions.
-- Scenario: Identify high-value categories with an average product price greater than $500.

SELECT CategoryID, 
       COUNT(ProductID) AS TotalProducts, 
       AVG(Price) AS AveragePrice
FROM Products
GROUP BY CategoryID
HAVING AVG(Price) > 500.00;

--------------------------------------------------
-- PHASE 2: RELATIONAL POWER & COMBINING SETS (INTERMEDIATE)
--------------------------------------------------

-- Definition: INNER JOIN returns only rows with matching values in both tables.
-- Scenario: Retrieve active orders alongside customer details.

SELECT o.OrderID, c.FirstName, c.LastName, o.OrderStatus, o.OrderDate
FROM Orders o
INNER JOIN Customers c 
    ON o.CustomerID = c.CustomerID;


-- Definition: LEFT JOIN returns all records from the left table and matched rows from the right table.
-- Scenario: List every customer and their order IDs, including those without orders.

SELECT c.CustomerID, c.FirstName, c.LastName, o.OrderID, o.OrderStatus
FROM Customers c
LEFT JOIN Orders o 
    ON c.CustomerID = o.CustomerID;

-- Definition: LEFT JOIN combined with GROUP BY and aggregate functions summarizes data across categories, including any categories with no products.
-- Scenario: Inventory management needs to analyze total stock levels and product counts across every product category.

SELECT c.CategoryName, 
       COUNT(p.ProductID) AS ProductCount,
       SUM(p.StockQuantity) AS TotalStock
FROM Categories c
LEFT JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;

-- Definition: RIGHT JOIN returns all records from the right table and matched rows from the left table.
-- Scenario: Retrieve order items and match them back to their parent orders.

SELECT o.OrderID, oi.ProductID, oi.Quantity, oi.UnitPrice
FROM Orders o
RIGHT JOIN Order_Items oi 
    ON o.OrderID = oi.OrderID;


-- Definition: FULL OUTER JOIN returns all records from both tables, showing NULLs where matches do not exist.
-- Scenario: Capture all customers and all orders side-by-side with unmatched records.

SELECT c.CustomerID, c.FirstName, o.OrderID, o.OrderStatus
FROM Customers c
FULL OUTER JOIN Orders o 
    ON c.CustomerID = o.CustomerID;


-- Definition: CROSS JOIN produces the Cartesian product of two tables.
-- Scenario: Generate every possible product and category combination for a grid layout.

SELECT p.ProductName, cat.CategoryName
FROM Products p
CROSS JOIN Categories cat;


-- Definition: UNION combines multiple result sets and removes duplicate rows.
-- Scenario: Combine targeted customer lists while removing duplicates.

SELECT FirstName, Email FROM Customers WHERE CustomerID = 1
UNION
SELECT FirstName, Email FROM Customers WHERE CustomerID = 2;


-- Definition: UNION ALL combines multiple result sets while retaining duplicate rows.
-- Scenario: Audit all order statuses including duplicate occurrences.

SELECT OrderStatus FROM Orders
UNION ALL
SELECT OrderStatus FROM Orders;


--------------------------------------------------
-- PHASE 3: SUBQUERIES & COMMON TABLE EXPRESSIONS (INTERMEDIATE TO ADVANCED)
--------------------------------------------------

-- Definition: Single-Row Subquery returns exactly one value and is used with operators like =, >, <.
-- Scenario: Find all products that are more expensive than the overall average product price.

SELECT ProductName, Price
FROM Products
WHERE Price > (
    SELECT AVG(Price) 
    FROM Products
);


-- Definition: Multi-Row Subquery returns a list of values and is used with operators like IN, ANY, ALL.
-- Scenario: Find all customers who have placed at least one completed order.

SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID 
    FROM Orders 
    WHERE OrderStatus = 'Completed'
);


-- Definition: Correlated Subquery depends on the outer query and executes once for every row processed.
-- Scenario: Find products whose price is higher than the average price of their specific category.

SELECT p.ProductName, p.CategoryID, p.Price
FROM Products p
WHERE p.Price > (
    SELECT AVG(sub.Price)
    FROM Products sub
    WHERE sub.CategoryID = p.CategoryID
);


-- Definition: Common Table Expression (CTE) creates a temporary, named result set for readability and reusability.
-- Scenario: Calculate the total inventory value per category using a CTE, then query it.

WITH CategoryInventory AS (
    SELECT CategoryID, 
           SUM(Price * StockQuantity) AS TotalStockValue,
           COUNT(ProductID) AS ProductCount
    FROM Products
    GROUP BY CategoryID
)
SELECT CategoryID, TotalStockValue, ProductCount
FROM CategoryInventory
WHERE TotalStockValue > 1000.00;

--------------------------------------------------
-- PHASE 4: ADVANCED ANALYTICS, HIERARCHIES & PROGRAMMABILITY (EXPERT)
--------------------------------------------------

-- Definition: Ranking window functions assign unique or tiered ranks to rows within partitions using OVER().
-- Scenario: Rank products by price within each category from highest to lowest using DENSE_RANK().

SELECT ProductName, CategoryID, Price,
       DENSE_RANK() OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS PriceRank,
       ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS RowNum
FROM Products;


-- Definition: Aggregate window functions perform calculations across partitions while retaining individual rows.
-- Interview Scenario: Calculate a running total of product stock levels grouped by category.

SELECT ProductName, CategoryID, StockQuantity,
       SUM(StockQuantity) OVER (PARTITION BY CategoryID ORDER BY ProductID) AS RunningStockTotal
FROM Products;


-- Definition: Recursive CTE references itself to traverse hierarchical parent-child relationships step-by-step.
-- Scenario: Traverse the category tree to map top-level categories down to their subcategories and levels.

WITH CategoryHierarchy AS (
    -- Anchor Member: Select top-level categories (no parent)
    SELECT CategoryID, CategoryName, ParentCategoryID, 1 AS CategoryLevel
    FROM Categories
    WHERE ParentCategoryID IS NULL
    
    UNION ALL
    
    -- Recursive Member: Join the CTE to fetch subcategories linked to the parent
    SELECT c.CategoryID, c.CategoryName, c.ParentCategoryID, ch.CategoryLevel + 1
    FROM Categories c
    INNER JOIN CategoryHierarchy ch 
        ON c.ParentCategoryID = ch.CategoryID
)
SELECT CategoryID, CategoryName, ParentCategoryID, CategoryLevel
FROM CategoryHierarchy;


-- Definition: Transactions (TCL) use BEGIN, COMMIT, ROLLBACK, and SAVEPOINT to ensure data safety and atomicity.
-- Scenario: Safely execute a multi-step price update with a savepoint fallback.

BEGIN TRANSACTION;

-- Step 1: Adjust product price
UPDATE Products 
SET Price = Price * 1.05 
WHERE ProductID = 1;

-- Step 2: Set a savepoint so we can roll back selectively if needed
SAVE TRANSACTION PriceUpdateSavepoint;

-- Step 3: Perform another operation (e.g., inventory adjustment)
UPDATE Products 
SET StockQuantity = StockQuantity - 2 
WHERE ProductID = 1;

-- If everything looks correct, commit the transaction
COMMIT TRANSACTION;
-- Note: If an error occurred after the savepoint, you could run: 
-- ROLLBACK TRANSACTION PriceUpdateSavepoint;


-- Definition: Stored Procedure is a reusable, pre-compiled block of SQL code stored in the database.
-- Scenario: Create a stored procedure to retrieve orders for a specific customer ID.

CREATE PROCEDURE GetCustomerOrders
    @InputCustomerID INT
AS
BEGIN
    SELECT o.OrderID, o.OrderDate, o.OrderStatus, c.FirstName, c.LastName
    FROM Orders o
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE c.CustomerID = @InputCustomerID;
END;
GO

-- How to execute the stored procedure:
-- EXEC GetCustomerOrders @InputCustomerID = 1;


-- Definition: DML Trigger automatically fires background code when an INSERT, UPDATE, or DELETE occurs.
-- Scenario: Create an audit trigger to automatically log product stock changes into Inventory_Audit_Log.

CREATE TRIGGER trg_ProductStockUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    IF UPDATE(StockQuantity)
    BEGIN
        INSERT INTO Inventory_Audit_Log (ProductID, OldStock, NewStock, ChangeType, ChangedAt)
        SELECT 
            i.ProductID,
            d.StockQuantity AS OldStock,
            i.StockQuantity AS NewStock,
            'STOCK_QUANTITY_MODIFIED',
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.ProductID = d.ProductID;
    END
END;


/*
--- To check if the created trigger worked, we can proceed with the below queries.

--- Check the current stock of ProductID 1 (MacBook Pro 16)

SELECT ProductID, ProductName, StockQuantity 
FROM Products 
WHERE ProductID = 1;

--- Check the Audit Log right now (it should be empty)

SELECT * FROM Inventory_Audit_Log;


--- PERFORM THE TEST UPDATE: Change the StockQuantity for ProductID 1
--- (This should automatically fire our trigger!)

UPDATE Products 
SET StockQuantity = StockQuantity - 5 
WHERE ProductID = 1;


--- Check the Audit Log again
SELECT * FROM Inventory_Audit_Log;
*/

-- Example: Visualize product stock levels as a text-based bar chart
SELECT ProductName, 
       StockQuantity,
       REPLICATE('█', StockQuantity / 5) AS StockVisual
FROM Products;