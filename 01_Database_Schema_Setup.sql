--- Create a dedicated project database
	CREATE DATABASE ECommercePipelineDB;

--- Send everything above this line to the server, execute it, and then start a fresh batch.
GO

USE ECommercePipelineDB;
GO

/* IDENTITY(1,1) - Make this column an integer, make it the primary key, 
and automatically number it sequentially starting at 1. */

-- 1. Categories Table (Hierarchical for Recursive CTEs)
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL FOREIGN KEY REFERENCES Categories(CategoryID)
);

-- 2. Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL
);

-- 3. Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    SignupDate DATE DEFAULT GETDATE()
);

-- 4. Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus VARCHAR(30) DEFAULT 'Pending' -- Pending, Completed, Cancelled
);

-- 5. Order_Items Table (Many-to-Many relationship between Orders and Products)
CREATE TABLE Order_Items (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL
);

-- 6. Audit Log Table (For Triggers later)
CREATE TABLE Inventory_Audit_Log (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    OldStock INT,
    NewStock INT,
    ChangeType VARCHAR(50),
    ChangedAt DATETIME DEFAULT GETDATE()
);

-- 1. Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS Inventory_Audit_Log;
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;
GO