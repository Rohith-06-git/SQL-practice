-- Q. Q1. Find customers who have never placed an order.
SELECT c.name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- ALTERNATE 
SELECT name
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM orders
);

-- Q2. Find the second highest salary.
WITH salary_rank AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT salary
FROM salary_rank
WHERE rnk = 2;

-- ALTERNATE
SELECT name,
       salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);

--ALTERNATE 
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- Q3. Employees earning more than their department average.

-- Correlated Subquery
SELECT name,
       salary
FROM employees e
WHERE salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e.department_id = e2.department_id
);

-- CTE + JOIN
WITH avg_salary AS (
    SELECT department_id,
           AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
)
SELECT e.name,
       e.salary
FROM employees e
JOIN avg_salary a
ON e.department_id = a.department_id
WHERE e.salary > a.avg_sal;

-- Q4. Find customer(s) who placed the highest number of orders.
WITH order_count AS (
    SELECT customer_id,
           COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.name,
       oc.total_orders
FROM customers c
JOIN order_count oc
ON c.customer_id = oc.customer_id
WHERE oc.total_orders = (
    SELECT MAX(total_orders)
    FROM order_count
);

-- Q5. Find employees earning the highest salary in each department.
-- Window Function

WITH hs AS (
    SELECT name,
           salary,
           department_id,
           DENSE_RANK() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC
           ) AS hm
    FROM employees
)
SELECT name,
       salary,
       department_id
FROM hs
WHERE hm = 1;

-- Correlated Subquery
SELECT name,
       salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees e2
    WHERE e.department_id = e2.department_id
);

Q6. Find customers who placed more than one order.
-- Using HAVING
SELECT c.name,
       COUNT(*) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(*) > 1;

-- Using CTE
WITH hm AS (
    SELECT customer_id,
           COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.name,
       h.total_orders
FROM customers c
JOIN hm h
ON c.customer_id = h.customer_id
WHERE h.total_orders > 1;

-- Q7. Find the second highest salary in each department.

-- Window Function
WITH ranked AS (
    SELECT department_id,
           name,
           salary,
           DENSE_RANK() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC
           ) AS rn
    FROM employees
)
SELECT department_id,
       name,
       salary
FROM ranked
WHERE rn = 2;

--Alternative (Without Window Functions)
SELECT department_id,
       name,
       salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees e2
    WHERE e.department_id = e2.department_id
      AND salary < (
          SELECT MAX(salary)
          FROM employees e3
          WHERE e.department_id = e3.department_id
      )
);

-- Q8. Find employees who have the same salary as at least one other employee.
SELECT name,
       salary
FROM employees
WHERE salary IN (
    SELECT salary
    FROM employees
    GROUP BY salary
    HAVING COUNT(*) > 1
);

-- Q9. Find the latest hired employee from each department.
WITH ranked AS (
    SELECT department_id,
           name,
           hire_date,
           ROW_NUMBER() OVER (
               PARTITION BY department_id
               ORDER BY hire_date DESC
           ) AS rn
    FROM employees
)
SELECT department_id,
       name,
       hire_date
FROM ranked
WHERE rn = 1;

-- Q10. Find the latest order placed by each customer.
WITH ranked AS (
    SELECT order_id,
           customer_id,
           order_date,
           amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date,
       amount
FROM ranked
WHERE rn = 1;