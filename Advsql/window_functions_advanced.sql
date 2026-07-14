 -- LAG()
 -- Q. Find how much salary increased compared to the previous employee within each department 
SELECT name,
       salary,
       department_id,
       salary - LAG(salary) OVER(
        PARTITION BY department_id
        ORDER BY salary ASC
       ) AS ms 
FROM employees ;

-- LEAD()
-- Q. Find employees whose salary is lower than the next employee within dept.
SELECT name,
       salary,
       department_id,
       salary - LEAD(salary) OVER(
        PARTITION BY department_id
        ORDER BY salary DESC 
        ) AS ms
FROM employees;

-- FIRST_VALUE()
-- Q. Show every employee along with the lowest salary in their department.
SELECT department_id,
        FIRST_VALUE(salary) OVER(
                PARTITION BY department_id
                ORDER BY salary ASC
        ) AS rm
FROM employees ; 

-- Q. Show difference between employee salary and department's lowest salary.
SELECT  salary,
        department_id,
        salary - FIRST_VALUE(salary) OVER(
                PARTITION BY department_id
                ORDER BY salary ASC
        ) AS rm
FROM employees ; 

-- LAST_VALUE() 
-- Q. Show highest salary in every department
SELECT department_id,
        name,
        LAST_VALUE(salary) OVER(
                PARTITION BY department_id
                ORDER BY salary ASC
                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
                ) AS ms
FROM employees ;

-- Q. Difference from highest salary.
SELECT department_id,
        name,
        salary,
        salary - LAST_VALUE(salary) OVER(
                PARTITION BY department_id
                ORDER BY salary ASC
                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
                ) AS ms
FROM employees ;

-- NTILE()
-- Q. Find employees in the highest quartile.

SELECT * FROM 
(SELECT name,
        department_id,
        salary,
        NTILE(5) OVER (
                ORDER BY salary
                ) AS ms
FROM employees 
) AS t
WHERE ms = 5 ;
