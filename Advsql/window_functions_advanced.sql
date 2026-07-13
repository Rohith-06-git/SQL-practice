SELECT * FROM
(SELECT name,
       salary,
       department_id,
       DENSE_RANK() OVER(
        PARTITION BY department_id
        ORDER BY salary DESC
       ) AS ms
FROM employees ) AS t
WHERE ms = 1