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

-- Q11 – Customers Who Ordered Every Product

WITH hm AS (
SELECT customer_id
FROM orders 
GROUP BY customer_id
HAVING COUNT(DISTINCT product_id) = (
    SELECT COUNT(*)
    FROM products
    ) 
)

SELECT  c.customer_id,
        c.customer_name
FROM customers c 
LEFT JOIN hm h 
ON c.customer_id = h.customer_id
WHERE h.customer_id IS NOT NULL ;

-- Q12 – Consecutive Login Days (Gaps & Islands)

WITH hs AS (
    SELECT user_id,
    login_date - ROW_NUMBER() OVER(
        PARTITION BY user_id 
        ORDER BY login_date ASC
    ) AS hm
    FROM logins
)

SELECT user_id
FROM hs 
GROUP BY user_id,hm 
HAVING COUNT(*) >= 3 ;

-- Q13 – Department Salary Ranking
WITH salaries AS
(SELECT department,
        name,
        salary,
        DENSE_RANK() OVER(
            PARTITION BY department
            ORDER BY salary DESC
            ) AS sal 
FROM employees 
)

SELECT department,
        name,
        salary
FROM salaries
WHERE sal <= 2  ;

-- Q14 – Highest Paid Employee in Each Department.

WITH salaries AS
(SELECT department,
        name,
        salary,
        DENSE_RANK() OVER(
            PARTITION BY department
            ORDER BY salary DESC
            ) AS sal 
FROM employees 
)

SELECT department,
        name,
        salary
FROM salaries
WHERE sal = 1;

-- WITHOUT Window Functions
WITH salaries AS 
(SELECT department,MAX(salary) AS max_sal
FROM employees 
GROUP BY department )

SELECT e.department,
    e.name,e.salary
FROM employees e 
JOIN salaries s 
ON e.department = s.department
AND e.salary = s.max_sal ;

-- Q.15 Find the customer(s) whose total order amount is the highest.

-- METHOD - 1
WITH max_sal AS (SELECT customer_id,
        SUM(amount) AS total_amount
FROM orders 
GROUP BY customer_id 
)

SELECT customer_id ,
        total_amount
FROM max_sal
WHERE total_amount = (
    SELECT MAX(total_amount) FROM max_sal
    ) ;

-- METHOD - 2
WITH max_sal AS (SELECT customer_id,
        SUM(amount) AS total_amount
FROM orders 
GROUP BY customer_id 
),

ranked AS (SELECT customer_id,
        total_amount,
        DENSE_RANK() OVER(
            ORDER BY total_amount DESC
         ) AS rankings
FROM max_sal 
)

SELECT customer_id,total_amount
FROM ranked 
WHERE rankings = 1 ;

-- Q16.Running Total For each day, show:sale_date,amount,running_total.

SELECT sale_date,
        amount,
        SUM(amount) OVER(
            ORDER BY sale_date ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )AS running_total
FROM sales ;

-- Q17 – Highest Sale Till Date

SELECT sale_date,
        amount,
        MAX(amount) OVER(
            ORDER BY sale_date ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
            ) AS highest_sale_so_far
FROM sales ;

-- Q18 – Previous Order Difference(
-- For each customer, display:
-- customer_id,order_date,amount,previous_amount,difference)
-- Rules : don't use CTE 
SELECT customer_id,
        order_date,
        amount,
        previous_amount,
        amount - previous_amount AS difference
FROM ( SELECT customer_id,
        order_date,
        amount,
        LAG(amount) OVER(
            PARTITION BY customer_id
            ORDER BY order_date ASC
            ) AS previous_amount
  FROM orders ) 
  AS m ; 

-- Without a subquery and CTE
  SELECT customer_id,
       order_date,
       amount,
       LAG(amount) OVER (
           PARTITION BY customer_id
           ORDER BY order_date
       ) AS previous_amount,
       amount - LAG(amount) OVER (
           PARTITION BY customer_id
           ORDER BY order_date
       ) AS difference
FROM orders;
        
-- Q19 – Second Latest Order Per Customer
WITH ranked AS (
    SELECT customer_id,
           order_date,
           amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM orders
)
SELECT customer_id,
       order_date,
       amount
FROM ranked
WHERE rn = 2;

-- Q20. Find customers whose every order amount is strictly greater than their previous order amount.
WITH updated AS (SELECT customer_id,
        amount - LAG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS difference 
FROM orders )

SELECT customer_id
FROM updated
GROUP BY customer_id
HAVING SUM(
    CASE 
        WHEN difference < 0 THEN 1
        ELSE 0
    END
) = 0;