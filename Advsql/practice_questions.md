# Q48 - Query Optimization & Execution Plan

## Query Optimization
- Process of choosing the lowest-cost execution plan.
- The optimizer decides how to execute a query efficiently.

## EXPLAIN
Shows the execution plan without executing the query.

```sql
EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';
```

## Table Scan (Sequential Scan)
- Reads every row.
- Good for small tables or when most rows match.

## Index Scan
- Uses an index to locate matching rows.
- Faster when only a few rows match.

## Why Index May Not Be Used?
- Low selectivity (many rows match).
- Outdated statistics.
- `SELECT *` requires many table lookups.
- Small table.
- Function on indexed column.

## Important EXPLAIN Terms
- `type = ALL` → Full Table Scan.
- `key = NULL` → No index selected.

## Covering Index
If all required columns exist in the index, the table doesn't need to be accessed.

Example:

```sql
CREATE INDEX idx_dept_salary
ON employees(department, salary);
```

## Interview Takeaways
- Use `EXPLAIN` to analyze queries.
- Optimizer chooses the lowest-cost plan.
- Indexes speed up reads but slow writes.
- Indexes are useful only when they reduce the number of rows scanned significantly.


# Q49 - Indexes

## What is an Index?
- A data structure that helps the database locate rows faster.
- Avoids Full Table Scans.
- Improves SELECT, WHERE, JOIN and ORDER BY performance.
- Slows INSERT, UPDATE and DELETE because indexes must also be updated.

---

## Types of Indexes

### 1. Clustered Index
- Stores table data physically in sorted order.
- Only one clustered index per table.
- Fast for range queries.

### 2. Non-Clustered Index
- Separate structure containing indexed values and pointers to rows.
- Multiple non-clustered indexes can exist.
- May require table lookup after finding the row.

### 3. Composite Index
- Index created on multiple columns.

Example:

```sql
CREATE INDEX idx_dept_salary
ON employees(department, salary);
```

---

## Leftmost Prefix Rule

Composite Index:

```sql
(department, salary)
```

| Query | Uses Index |
|--------|------------|
| WHERE department='IT' | ✅ |
| WHERE department='IT' AND salary>50000 | ✅ |
| WHERE salary>50000 | ❌ |

---

## Common SQL

```sql
-- Create Index
CREATE INDEX idx_department
ON employees(department);

-- Composite Index
CREATE INDEX idx_dept_salary
ON employees(department, salary);

-- Drop Index
DROP INDEX idx_dept_salary;
```

---

## Interview Takeaways

- Clustered Index → Data stored in sorted order.
- Non-Clustered Index → Separate structure with row pointers.
- Only one Clustered Index per table.
- Multiple Non-Clustered Indexes are allowed.
- Composite Index follows the Leftmost Prefix Rule.
- Create indexes on frequently searched columns.
- Avoid indexing every column because indexes slow write operations.


# Q50 - Transactions & Isolation Levels

## Transaction
A transaction is a group of SQL statements executed as a single unit of work.

Either:
- All operations succeed (COMMIT).
- All operations fail (ROLLBACK).

---

## ACID Properties

### Atomicity
- All or nothing.

### Consistency
- Database remains in a valid state.

### Isolation
- Concurrent transactions do not interfere.

### Durability
- Committed data survives crashes.

---

## Transaction Commands

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 1000
WHERE id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE id = 2;

COMMIT;

-- or

ROLLBACK;
```

---

## Isolation Levels

| Level | Prevents |
|---------|-------------------------------|
| Read Uncommitted | Nothing |
| Read Committed | Dirty Reads |
| Repeatable Read | Dirty Reads, Non-Repeatable Reads |
| Serializable | Dirty Reads, Non-Repeatable Reads, Phantom Reads |

---

## Common Problems

### Dirty Read
Reading data that has not been committed.

### Non-Repeatable Read
Reading the same row twice gives different values.

### Phantom Read
Running the same query twice returns different numbers of rows due to INSERT/DELETE.

---

## Interview Takeaways

- COMMIT saves changes.
- ROLLBACK undoes changes.
- ACID ensures reliable transactions.
- Serializable is the safest but slowest isolation level.
- Read Committed is commonly used.
- Repeatable Read is MySQL's default isolation level.


# Q51 - Views vs Materialized Views

## What is a View?
- A View is a saved SQL query.
- It does not store data.
- Every time a View is queried, the underlying SQL query is executed.

### Syntax

```sql
CREATE VIEW department_avg_salary AS
SELECT department,
       AVG(salary) AS avg_salary
FROM employees
GROUP BY department;
```

---

## Materialized View

- Stores the actual query result.
- Faster than a normal View.
- Needs to be refreshed when underlying data changes.

---

## View vs Materialized View

| View | Materialized View |
|------|--------------------|
| Stores Query | Stores Data |
| Always Up-to-date | Needs Refresh |
| Slower | Faster |
| No Extra Storage | Requires Storage |

---

## Updatable View

A View is generally updatable if it:

- Uses a single table.
- Does not use GROUP BY.
- Does not use Aggregate Functions.
- Does not use DISTINCT.
- Does not use UNION.

Otherwise, it is generally not updatable.

---

## Interview Takeaways

- View = Saved SQL Query.
- Materialized View = Stored Query Result.
- Materialized Views improve read performance.
- Materialized Views require refresh.
- MySQL does not support Materialized Views natively.

# Q54 - SQL Debugging & Query Optimization

## Scenario

Given Query:

```sql
SELECT *
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE YEAR(order_date) = 2024
ORDER BY amount;
```

---

## Problems

### 1. Avoid SELECT *

```sql
SELECT c.customer_name,
       o.order_date,
       o.amount
```

Reason:
- Retrieves only required columns.
- Reduces I/O.

---

### 2. Avoid Functions on Indexed Columns

❌

```sql
WHERE YEAR(order_date) = 2024
```

✅

```sql
WHERE order_date >= '2024-01-01'
AND order_date < '2025-01-01'
```

Reason:
- Allows index usage.

---

### 3. Create Appropriate Indexes

```sql
CREATE INDEX idx_order_date
ON orders(order_date);
```

If joins and filtering are frequent:

```sql
CREATE INDEX idx_customer_date
ON orders(customer_id, order_date);
```

---

### 4. Verify Using EXPLAIN

```sql
EXPLAIN
SELECT ...
```

Check:

- Execution Plan
- Index Usage
- Rows Scanned

---

## Interview Takeaways

- Avoid `SELECT *`.
- Avoid functions on indexed columns.
- Use range conditions for dates.
- Create indexes on frequently filtered and joined columns.
- Always verify optimization using `EXPLAIN`.

# Q55 - Final Amazon/Microsoft SQL Challenge

## Main Concepts

- JOIN
- CTE
- LAG()
- ROW_NUMBER()
- CASE
- GROUP BY
- Aggregate Functions
- DENSE_RANK()

## Approach

### 1. Order Level

Use `LAG()` to find the previous order amount for each customer.

```sql
LAG(amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
)
```

Use `ROW_NUMBER()` to identify the latest order.

```sql
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC
)
```

---

### 2. Customer Level

Use `GROUP BY customer_id, customer_name` to calculate:

- Total orders → `COUNT()`
- Total spending → `SUM()`
- Average order → `AVG()`
- First order → `MIN()`
- Last order → `MAX()`

Use `CASE` to extract information from the latest order.

---

### 3. Final Ranking

Use:

```sql
DENSE_RANK() OVER (
    ORDER BY total_spent DESC
)
```

to rank customers by total spending while including ties.

---

## Key Interview Insight

Always identify the **level of each calculation**.

| Calculation | Level |
|---|---|
| `LAG()` | Order level |
| `ROW_NUMBER()` | Order level |
| `SUM()` | Customer level |
| `AVG()` | Customer level |
| `MIN()` / `MAX()` | Customer level |
| `DENSE_RANK()` | Customer level |

## General Strategy

```text
Understand the output
        ↓
Identify the data level
        ↓
Calculate row-level metrics
        ↓
Aggregate to required level
        ↓
Apply window functions
        ↓
Final result
```

## Interview Takeaway

Complex SQL problems are usually solved by breaking them into
multiple logical stages using CTEs instead of trying to write
everything in one SELECT.

Q55 combines most of the important SQL interview patterns learned
throughout the roadmap.