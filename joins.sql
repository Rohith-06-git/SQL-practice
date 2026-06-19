/*
SELECT *
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id;

SELECT 
    employees.id,
    employees.name, 
    employees.salary, 
    departments.department_name, 
    departments.building_floor
FROM employees
INNER JOIN departments 
ON employees.department_id = departments.department_id;

SELECT *
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id;

SELECT COUNT(*)
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id;

SELECT d.department_name,COUNT(*)
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_name ;
*/



