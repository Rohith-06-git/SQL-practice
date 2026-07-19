-- Q.Total revenue for each year.
SELECT YEAR(sale_date) AS year,
        SUM(amount) 
FROM sales
GROUP BY YEAR(sale_date) 
ORDER BY year;

-- Q.Show every sale along with the total revenue of its year.
SELECT sale_id,
        sale_date,
        YEAR(sale_date) AS year,
        product_name,
        amount,
        SUM(amount) OVER(
            PARTITION BY YEAR(sale_date)
        ) AS ms 
FROM sales;

-- Q. Total revenue for each month of each year.
SELECT sale_id,
        sale_date,
        MONTH(sale_date),
        YEAR(sale_date),
        amount,
        product_name,
        SUM(amount) OVER (
            PARTITION BY MONTH(sale_date),YEAR(sale_date)

            ) AS ms
FROM sales ;

-- Q. Which year had the highest sales?
SELECT  YEAR(sale_date),
        SUM(amount) OVER(
                PARTITION BY YEAR(sale_date)
                ) AS ms
FROM sales
ORDER BY ms DESC
LIMIT 1 ;

-- Q. Compare January sales across 2023, 2024, and 2025.
SELECT  DISTINCT
        MONTH(sale_date) ,
        YEAR(sale_date),
        SUM(amount) OVER( 
            PARTITION BY YEAR(sale_date)
             ) AS ms 
FROM sales
WHERE MONTH(sale_date) = '1' ;

-- Q. Find the highest-selling month in each year.
WITH ttsales AS
(
SELECT  MONTH(sale_date) As month,
        YEAR(sale_date) AS year,
        SUM(amount) AS ms
FROM sales
GROUP BY YEAR(sale_date) , MONTH(sale_date)
)

SELECT year,
        month,
        ms 
        FROM (
            SELECT *,
                    RANK() OVER(
                        PARTITION BY year
                        ORDER BY ms DESC
                        ) AS mr
            FROM ttsales
            ) AS mc
WHERE mr = 1;

-- Q. Calculate Year-over-Year (YoY) growth.

WITH ttdata AS (
    SELECT MONTH(sale_date) AS month,
            YEAR(sale_date) AS year,
            SUM(amount) AS total_sales
    FROM sales
    GROUP BY MONTH(sale_date),YEAR(sale_date)
    )

SELECT
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (
        PARTITION BY month
        ORDER BY year
    ) AS previous_year_sales,
    total_sales -
    LAG(total_sales) OVER (
        PARTITION BY month
        ORDER BY year
    ) AS yoy_growth
FROM ttdata
ORDER BY month, year;

-- Q. Calculate Month-over-Month (MoM) growth using LAG().

WITH ttdata AS (
    SELECT MONTH(sale_date) AS month,
            YEAR(sale_date) AS year,
            SUM(amount) AS total_sales
    FROM sales
    GROUP BY YEAR(sale_date),MONTH(sale_date)
    )

SELECT
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (
        PARTITION BY year
        ORDER BY month
    ) AS previous_year_sales,
    total_sales -
    LAG(total_sales) OVER (
        PARTITION BY year
        ORDER BY month
    ) AS mom_growth
FROM ttdata
ORDER BY year,month;

-- Q. Find the customer who spent the most in each year.

WITH ttdata AS
(SELECT customer_id,
        YEAR(sale_date) AS year,
        SUM(amount) AS ms
FROM sales
GROUP BY customer_id,YEAR(sale_date)
)

SELECT  customer_id,
        year,
        ms FROM (
            SELECT *,
                    RANK() OVER(
                        PARTITION BY year
                        ORDER BY ms DESC
                        ) AS mr
            FROM ttdata
            ) AS mc
WHERE mr = 1;


