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