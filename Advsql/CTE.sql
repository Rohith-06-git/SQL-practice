--  Single CTE

-- Q. Create a CTE containing employees earning more than 50,000.
WITH ideal_salary AS (
    SELECT * FROM employees
    WHERE salary > 50000
)

SELECT * FROM ideal_salary ;

-- Q .Create a CTE containing employees from department 10.
WITH dep_10 AS (
    SELECT name,salary FROM employees
    WHERE department_id = 10 
    )

SELECT * FROM dep_10 ;


-- Aggregate CTE

-- Q.Create a CTE that calculates average salary for each department.
WITH avg_salary AS (
    SELECT department_id,AVG(salary) AS sal
    FROM employees
    GROUP BY department_id
    )

SELECT sal FROM avg_salary;

-- Q.Create a CTE that calculates employee count for each department.
WITH emp_count AS (
    SELECT COUNT(*) FROM employees 
    GROUP BY department_id
    )

SELECT * FROM emp_count; 


Multiple CTE

-- Q.First CTE: Calculate average salary per department.
--  Second CTE: Keep only departments whose average salary is above 60,000.

WITH avg_salary AS (
    SELECT AVG(salary) AS sal
    FROM employees 
    GROUP BY department_id
    ),

    updated_sal AS (
    SELECT sal FROM avg_salary 
    WHERE sal > 60000
)

SELECT * FROM updated_sal ;


-- Q.First CTE: Count employees per department.
--  Second CTE: Display departments with more than 10 employees.

WITH emp_count AS (
    SELECT COUNT(*) AS emp_per_dep 
    FROM employees
    GROUP BY department_id
    ),
    updated_emp AS (
    SELECT emp_per_dep FROM emp_count
    WHERE emp_per_dep > 1
    )

SELECT * FROM updated_emp ;


-- CTE + JOIN

-- Q. Create a CTE for average salary per department and Join with Departments

WITH avg_sal AS (
    SELECT department_id,AVG(salary) AS sal 
    FROM employees
    GROUP BY department_id
    )

SELECT a.sal,
d.department_name
FROM avg_sal a 
LEFT JOIN departments d 
ON a.department_id = d.department_id ;

-- Q.Create a CTE for employee count per department Join with Departments.

WITH emp_count AS (
    SELECT department_id,COUNT(*) AS updated_emp
    FROM employees
    GROUP BY department_id
  )

SELECT e.updated_emp,
d.department_name
FROM emp_count e 
LEFT JOIN departments d
ON e.department_id = d.department_id ;

-- Q. Using a CTE, find employees earning more than their department's average salary.

WITH avg_sal AS (
    SELECT department_id,AVG(salary) as sal
    FROM employees
    GROUP BY department_id
)
SELECT e.salary ,
e.name 
FROM avg_sal a 
INNER JOIN employees e 
ON a.department_id = e.department_id
WHERE e.salary > a.sal ;

