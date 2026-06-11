
SELECT department, COUNT(*) AS employee_count 
FROM employees 
GROUP BY department;

SELECT department,AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

SELECT department,MAX(salary) AS max_salary
FROM employees
GROUP BY department;

SELECT department,MIN(salary) AS min_salary
FROM employees
GROUP BY department;

SELECT department,SUM(salary) AS total_salary
FROM employees
GROUP BY department;

SELECT *FROM employees
ORDER BY age ASC;


