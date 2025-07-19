USE walmart_db;
SELECT * FROM walmart LIMIT 10;
SELECT COUNT(*) FROM walmart;
SELECT DISTINCT 
   payment_method,
   COUNT(*)
FROM walmart
GROUP BY payment_method;


SELECT 
branch
FROM walmart;

SELECT COUNT(DISTINCT branch) 
FROM walmart;

 SELECT MAX(quantity) FROM walmart;
 SELECT MIN(quantity) FROM walmart;
 
 -- Business Problem
 -- Q1. Find different payment method and number of transactions, number of qty sold
 
 SELECT
     payment_method,
     COUNT(*) as no_payments,
     SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;    

-- Q2.Identify the highest-rated category in each branch, displaying the branch, category
-- AVG Rating 


SELECT *
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS value
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE value = 1;

-- Q3. Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
 (SELECT
    branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
    COUNT(*) AS no_transactions,
    RANK() OVER(PARTITION BY branch   ORDER BY COUNT(*) DESC) as value
FROM walmart
GROUP BY branch, day_name
ORDER BY branch, no_transactions DESC
) AS ranked_data
WHERE value =1;

-- Q4. Find the Different payment method and number of transactions, number of aty sold

SELECT 
    payment_method,
    -- COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;    

-- Q5 Determine the average, minimum, and maximum rating of products from each city,
-- List the city, average_rating, min_rating, and max_rating.
SELECT 
  city,
  category,
   MIN(rating) as min_rating,
   MAX(rating) as max_rating,
   AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2;
     
-- Q6. Calculate the total profit for each category by considering total_profit
-- as (unit_price*quantity*profit_margin). List category and total_profit, ordered from highest to lowest profit

SELECT
   category,
   SUM(total) as total,
   SUM(total*profit_margin) as profit
FROM walmart
GROUP BY 1;   

-- Q7.Determine the most common payment method for each branch
-- Display branch and each preferred payment method
WITH cte
AS
(
SELECT
   branch,
   payment_method,
   COUNT(*) as total_trans,
   RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as value
FROM walmart
GROUP BY 1,2   
) 
SELECT *
FROM cte
WHERE value=1;
   
-- Q8. Categorize sales into 3 categories into Morning, Afternoon, Evening
-- Find out each of the shift and no of invoices
SELECT
    branch,
CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'MORNING'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS day_time,
    COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Q9. Identify 5 branch with highest decrease ratio in revenue
-- compare to last year(Current year 2023 and last year 2022)
-- rdr == last_rev - cr_rev/last_rev

SELECT 
    *, 
    YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS formatted_date
FROM walmart;
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY 1
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY 1
)
SELECT
    ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as current_year_revenue,
 ROUND(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) AS percent_change
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch=cs.branch
WHERE 
   ls.revenue > cs.revenue
ORDER BY 4 DESC    
LIMIT 5





