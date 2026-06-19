-- Single-Row Subquery : Q. Employees earning above average salary
SELECT salary FROM employees
WHERE salary >
( SELECT AVG(salary) FROM employees );

-- Multi-Row Subquery
SELECT * FROM employees 
WHERE department_id IN 
( SELECT department_id FROM departments );

-- Correlated Subquery
SELECT * FROM Employees e
WHERE salary >
( SELECT AVG(salary) FROM Employees
  WHERE department_id = e.department_id);

-- Q. Second Highest Salary
SELECT MAX(salary) FROM employees
WHERE salary < 
(SELECT MAX(salary) FROM employees ) ;

-- Q.Employees working in departments located in 4th Floor
SELECT * FROM employees 
WHERE department_id IN
( SELECT department_id FROM departments
  WHERE building_floor = "4th Floor" );

-- Q.Find the highest-paid employee in each department
SELECT * FROM employees e
WHERE salary IN 
( SELECT MAX(SALARY) FROM employees
  WHERE department_id = e.department_id );

-- Q. Find departments having more than the average number of employees
SELECT department_id FROM Employees
GROUP BY department_id
HAVING COUNT(*) >
(SELECT AVG(emp_count) FROM
    (
        SELECT COUNT(*) AS emp_count
        FROM Employees
        GROUP BY department_id 
    ) AS dept_counts
);
