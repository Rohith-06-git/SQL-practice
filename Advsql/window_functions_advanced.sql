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


