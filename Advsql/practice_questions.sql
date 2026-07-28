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

-- Q.21 Find customers whose order amounts are always increasing (without using LAG())

WITH ranks AS (
    SELECT customer_id,
           order_date,
           amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS rn
    FROM orders
)

SELECT r1.customer_id
FROM ranks r1
JOIN ranks r2
    ON r1.customer_id = r2.customer_id
   AND r1.rn = r2.rn + 1
GROUP BY r1.customer_id
HAVING SUM(
    CASE
        WHEN r1.amount <= r2.amount THEN 1
        ELSE 0
    END
) = 0;

-- Q.22 Customers Who Placed Orders in Consecutive Months
WITH months AS (
    SELECT DISTINCT
           customer_id,
           YEAR(order_date) AS year,
           MONTH(order_date) AS month
    FROM orders
),
 updated AS (
    SELECT customer_id,
            year,
            month,
            (year * 12 + month) -
            LAG(year * 12 + month) OVER(
                PARTITION BY customer_id
                ORDER BY year,month
            ) AS difference
    FROM months
)

SELECT DISTINCT customer_id
FROM updated 
WHERE difference = 1 ;

-- Q.23 Find the longest consecutive streak of days each customer placed an order.

WITH no_dup AS (
    SELECT DISTINCT 
            customer_id,
            order_date
    FROM orders 
),
 hs AS (
    SELECT customer_id,
            order_date,
    order_date - INTERVAL ROW_NUMBER() OVER(
        PARTITION BY customer_id 
        ORDER BY order_date ASC
    )DAY AS hm
    FROM no_dup
),

streak AS (
    SELECT customer_id,
            hm,
            COUNT(*) AS streak_length
            FROM hs 
            GROUP BY customer_id,hm
)

SELECT customer_id,
        MAX(streak_length) AS longest_streak
        FROM streak
        GROUP BY customer_id ;

-- Q24.Write a query to display the total sales for the first three months of the year in separate columns.

SELECT
    customer_id,
    SUM(CASE WHEN MONTH(order_date) = 1 THEN amount ELSE 0 END) AS Jan,
    SUM(CASE WHEN MONTH(order_date) = 2 THEN amount ELSE 0 END) AS Feb,
    SUM(CASE WHEN MONTH(order_date) = 3 THEN amount ELSE 0 END) AS Mar
FROM orders
GROUP BY customer_id;

-- Q.25 For each transaction, display the customer's running account balance.

SELECT customer_id,
        transaction_date,
        transaction_type,
        amount,
        SUM( CASE
        WHEN transaction_type = 'Credit' THEN amount
        ELSE -amount
    END) OVER(
            PARTITION BY customer_id
            ORDER BY transaction_date,transaction_id
        ) AS running_total
FROM transactions ;


-- Sessionization
-- Q.26 A new session starts when the gap between two consecutive events is more than 30 minutes.

WITH session AS (
    SELECT user_id,
            event_time,
            LAG(event_time) OVER(
                PARTITION BY user_id
                ORDER BY event_time
            ) AS previous_time
    FROM user_events
),

x AS (
    SELECT
    user_id,
    event_time,
    previous_time,
    CASE
        WHEN previous_time IS NULL THEN 1
        WHEN TIMESTAMPDIFF(MINUTE, previous_time, event_time) > 30 THEN 1
        ELSE 0
    END AS new_session
FROM session
),

y AS (
    SELECT user_id,
            event_time,
            new_session,
            SUM(new_session) OVER(
                PARTITION BY user_id
                ORDER BY event_time ASC
            ) AS session_id
    FROM x
)

SELECT user_id,
        event_time,
        session_id
FROM y;

-- Q.27 Cohort Analysis
-- For every customer, find:Their first purchase month (cohort month),The month in which each order occurred.
--The number of months since their first purchase.

WITH new AS (
SELECT customer_id,
        order_date,
        MIN(order_date) OVER(
            PARTITION BY customer_id
        ) AS cohort_month
FROM Orders
),

old AS (
    SELECT customer_id,
            cohort_month,
            order_date,
            TIMESTAMPDIFF(MONTH,cohort_month,order_date) 
            AS month_number
    FROM new
)

SELECT customer_id,
        cohort_month,  -- DATE_FORMAT(cohort_month, '%Y-%m') AS cohort_month,
        order_date,    -- DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        month_number
FROM old ;

-- Q.28 (Funnel Analysis)Find how many unique users reached each stage of the funnel.

SELECT event_name,COUNT(DISTINCT user_id) AS users
FROM user_events
GROUP BY event_name;

-- Q.29 Count only those users who completed the entire funnel.

WITH users AS (
    SELECT user_id,
    COUNT(DISTINCT event_name) AS completed
    FROM user_events
    GROUP BY user_id
) 

SELECT COUNT(*) AS completed_users
FROM users 
WHERE completed = 3;

-- Q.29.1 Count users who followed exactly:visit -> add to cart -> purchase

 WITH normal AS (
    SELECT user_id,
            MIN(CASE WHEN event_name = 'visit' THEN event_time END) visit_time,
            MIN(CASE WHEN event_name = 'Add to Cart' THEN event_time END) cart_time,
            MIN(CASE WHEN event_name = 'purchase' THEN event_time END) purchase_time
            FROM user_events
            GROUP BY user_id
    )
SELECT COUNT(*) AS completed_users
FROM normal 
WHERE visit_time IS NOT NULL AND
cart_time IS NOT NULL AND
purchase_time IS NOT NULL AND
visit_time < cart_time AND
cart_time < purchase_time ;

-- Q.30 (Market Basket Analysis) Find the top product pairs that are purchased together.

SELECT
    o1.product AS product1,
    o2.product AS product2,
    COUNT(*) AS times_bought_together
FROM orders o1
JOIN orders o2
    ON o1.order_id = o2.order_id
   AND o1.product < o2.product
GROUP BY
    o1.product,
    o2.product
ORDER BY
    times_bought_together DESC;

--Customer Retention Analysis
-- Q.31 Write a query to find the number of repeat customers in each month.

WITH min_date AS (
    SELECT customer_id,MIN(order_date) AS mini
    FROM Orders
    GROUP BY customer_id
)

SELECT MONTH(o.order_date) AS month,
       COUNT(DISTINCT o.customer_id) AS repeat_customers
       FROM orders o
       JOIN min_date m
       ON o.customer_id = m.customer_id
       WHERE DATE_FORMAT(o.order_date, '%Y-%m')
        <> DATE_FORMAT(m.mini, '%Y-%m')
       GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
       ORDER BY MONTH(o.order_date) ;

-- Q.32 Customers Who Bought Product A But Never Bought Product B

SELECT DISTINCT o.customer_id
    FROM orders o
    WHERE product = 'A'
    AND NOT EXISTS (
             SELECT b.customer_id
             FROM orders b 
                WHERE b.customer_id = o.customer_id
                AND b.product = 'B'
            )

--Q33. First and Last Order for Every Customer

SELECT customer_id,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MAX(order_date),MIN(order_date)) AS days_between
        FROM orders  
        GROUP BY customer_id
        ORDER BY customer_id ;

-- METHOD - 2
WITH new AS (
    SELECT customer_id,
            order_date,
            ROW_NUMBER() OVER(
                PARTITION BY customer_id
                ORDER BY order_date 
            ) AS f_date,
            ROW_NUMBER() OVER(
                PARTITION BY customer_id
                ORDER BY order_date DESC
            ) AS l_date
    FROM orders
)

WITH result AS (
    SELECT customer_id,
        MAX(CASE WHEN f_date = 1 THEN order_date END) AS first_date,
        MAX(CASE WHEN l_date = 1 THEN order_date END) AS last_date
        FROM new 
        GROUP BY customer_id 
    )

SELECT customer_id,
        first_date,
        last_date,
        DATEDIFF(last_date,first_date) AS days_between
        FROM result 
        ORDER BY customer_id ;

-- Q.34 Customers Who Bought Every Product

    SELECT customer_id
    FROM orders 
    GROUP BY customer_id
    HAVING COUNT(DISTINCT product_id) = (
        SELECT COUNT(*) FROM products) ;

-- Q.35 Median Salary by Department

WITH median AS (
    SELECT department,
            salary,
            ROW_NUMBER() OVER(
                PARTITION BY department
                ORDER BY salary
            ) AS rn,
            COUNT(*) OVER(
                PARTITION BY department
            ) AS count
    FROM employees
)

SELECT department,
        AVG(salary) AS median 
    FROM median 
    WHERE rn IN (
        FLOOR((count + 1) /2),
        CEIL((count + 1) /2)
    )
GROUP BY department;

-- Q.36 Find employees whose salary is greater than their manager's salary.

SELECT e.emp_name
       e.salary AS employee_salary
       m.salary AS manager_salary
       FROM employee e 
       JOIN employee m 
       ON e.manager_id = m.emp_id
       WHERE e.salary > m.salary ;

-- Q.37 Employees Earning More Than Their Department Average

SELECT emp_name,
        department,
        salary
FROM employees e 
WHERE salary > (
    SELECT AVG(salary) AS sal 
            FROM employees m 
            WHERE e.department = m.department
) ;

-- with joins 
SELECT e.emp_name,
       e.department,
       e.salary
FROM employees e
JOIN (
    SELECT department,
           AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department
) d
ON e.department = d.department
WHERE e.salary > d.avg_sal;

-- Q.38 Find Each Employee Along with Their Manager's Name

SELECT e.emp_name AS employee,
        m.emp_name AS manager
FROM employees e 
JOIN employees m 
ON e.manager_id = m.emp_id ;

-- Q.39 Find all pairs of employees who have the same salary.

SELECT e1.emp_name AS employee1,
        e2.emp_name AS employee2,
        e1.salary
FROM employees e1
JOIN employees e2
ON e1.salary = e2.salary 
AND e1.emp_id < e2.emp_id ;