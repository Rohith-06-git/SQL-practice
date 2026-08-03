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