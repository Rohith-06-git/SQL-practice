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


