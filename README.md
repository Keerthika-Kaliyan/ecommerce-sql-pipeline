# E-Commerce Data Pipeline & Advanced T-SQL Project

A production-grade relational database pipeline and advanced T-SQL implementation built in Microsoft SQL Server (SSMS). This project demonstrates the design of a robust e-commerce database schema alongside clean, structured queries translating core business logic into high-performance database operations.

---

## Tech Stack
* **Database Management System:** Microsoft SQL Server (T-SQL)
* **Environment:** SQL Server Management Studio (SSMS)

---

## Repository Structure

1. **`01_Database_Schema_Setup.sql`**
   * Handles database initialization, table creation (`Customers`, `Categories`, `Products`, `Orders`, `Order_Items`, `Inventory_Audit_Log`), foreign key constraints, and sample data seeding.
2. **`02_ECommerce_Pipeline_Master.sql`**
   * Contains the complete sequence of structured query phases, spanning basic filtering to expert-level programmable components.

---

## Core Technical Scope Covered

**Phase 1: Foundations & Filtering (Basic)**
  * Pattern matching with `LIKE`, range filtering with `BETWEEN`, duplicate elimination with `SELECT DISTINCT`, and group filtering via `GROUP BY` and `HAVING`.
**Phase 2: Relational Power & Combining Sets (Intermediate)**
  * Multi-table integration using `INNER`, `LEFT`, `RIGHT`, `FULL OUTER`, and `CROSS JOIN` operators, combined with set operations (`UNION`, `UNION ALL`).
**Phase 3: Advanced Subqueries & CTEs (Intermediate to Advanced)**
  * Execution of single-row, multi-row, and correlated subqueries, alongside modular Common Table Expressions (CTEs) for enhanced readability.
**Phase 4: Expert Analytics, Hierarchies & Programmability (Expert)**
  * Advanced window ranking (`DENSE_RANK`, `ROW_NUMBER`) and aggregate window functions.
  * Recursive CTEs for hierarchical tree traversal.
  * Transaction control language (`BEGIN`, `COMMIT`, `SAVEPOINT`) for data safety.
  * Modular architecture using stored procedures (`CREATE PROCEDURE`) and event-driven automation via DML triggers (`AFTER UPDATE`) logging changes into an audit table.

---

## How to Run This Project

1. Open **SQL Server Management Studio (SSMS)**.
2. Open and execute **`01_Database_Schema_Setup.sql`** to create the `ECommercePipelineDB` database and populate test data.
3. Open and execute **`02_ECommerce_Pipeline_Master.sql`** to run through the structured query phases and programmable objects.
