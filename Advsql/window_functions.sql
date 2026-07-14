-- Q.Assign row numbers based on salary.
SELECT name,
     salary,
     ROW_NUMBER() OVER(
        ORDER BY salary DESC
     )
FROM employees ;

-- Q.Rank employees by salary.
SELECT name,
    salary,
    RANK() OVER(
        ORDER BY salary DESC
    )
FROM employees ;

-- Q.Dense rank employees by salary.
SELECT name,
    salary,
    DENSE_RANK() OVER(
        ORDER BY salary DESC
    )
FROM employees ;

-- Q.Number employees within each department.
SELECT department_id,
        name,
        ROW_NUMBER() OVER(
            PARTITION BY department_id 
            ORDER BY name
        ) AS rn 
FROM employees ;

-- Q. Find highest-paid employee in each department.

SELECT * FROM
    ( SELECT name,
         salary ,
         department_id,
         DENSE_RANK() OVER (
             PARTITION BY department_id
             ORDER BY salary DESC
            ) AS rn
    FROM employees ) AS t
    WHERE rn = 1 ;

-- Q.Find top 3 salaries in each department.

SELECT * FROM (
    SELECT  name,
            salary,
            department_id,
            DENSE_RANK() OVER(
                PARTITION BY department_id
                ORDER BY salary DESC
                )AS rn 
    FROM employees 
    ) AS t 
WHERE rn < 4 ;

-- Q.Find second-highest salary in each department.

SELECT * FROM (
    SELECT  name,
            salary,
            department_id,
            DENSE_RANK() OVER(
                PARTITION BY department_id
                ORDER BY salary DESC
            ) AS rn
    FROM employees 
    ) AS t
WHERE rn = 2 ;

-- Q.Find employees whose salary rank is ≤ 5.

SELECT * FROM (
    SELECT  name,
            salary,
            department_id,
            DENSE_RANK() OVER(
                PARTITION BY department_id
                ORDER BY salary DESC
            ) AS rn
    FROM employees 
    ) AS t
WHERE rn <= 5 ;

-- Q.Find duplicate records using ROW_NUMBER().

SELECT * FROM (
    SELECT name,
            id,
            salary,
            ROW_NUMBER() OVER(
                PARTITION BY salary
                ORDER BY id ASC
                ) AS rn
    FROM employees 
        ) AS t 
WHERE rn > 1 ;

-- Q.Find nth highest salary using DENSE_RANK().

 SELECT  name,
         salary,
         DENSE_RANK() OVER(
            ORDER BY salary DESC
        )AS rn
 FROM employees  ;

-- Q. Find department-wise highest salary employee.
SELECT * FROM
(SELECT name,
       salary,
       department_id,
       DENSE_RANK() OVER(
        PARTITION BY department_id
        ORDER BY salary DESC
       ) AS ms
FROM employees ) AS t
WHERE ms = 1 ;


