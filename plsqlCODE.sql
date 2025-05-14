-- View all records from the walmart table
SELECT * FROM walmart;
-- Count total number of transactions
SELECT COUNT(*) FROM walmart;
-- Count the number of transactions per payment method
SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method;
-- Count the number of distinct branches
SELECT 
	COUNT(DISTINCT "branch") 
FROM walmart;
-- Get the minimum quantity sold
SELECT MIN(quantity) FROM walmart;
-- Q1: Find different payment methods and show number of transactions and quantity sold per method
SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;
-- Q2: Identify the highest-rated category in each branch
-- Show branch, category and average rating for the top-rated category
SELECT * 
FROM (
	SELECT 
		"branch",
		"category",
		AVG("rating") as avg_rating,
		RANK() OVER(PARTITION BY "branch" ORDER BY AVG("rating") DESC) as rank
	FROM walmart
	GROUP BY 1, 2
) sub
WHERE rank = 1;
-- Q3: Identify the busiest day for each branch based on number of transactions
SELECT * 
FROM (
	SELECT 
		"branch",
		TO_CHAR(TO_DATE("date", 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY "branch" ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
) sub
WHERE rank = 1;
-- Q4: Calculate total quantity of items sold per payment method
SELECT 
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine average, minimum, and maximum rating of each category for each city
SELECT 
	"city",
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2;

-- Q6: Calculate total profit for each category using profit = total * profit_margin
-- List category and total_profit, ordered from highest to lowest profit
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1;

-- Q7: Determine the most common (preferred) payment method for each branch
WITH cte AS (
	SELECT 
		"branch",
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY "branch" ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1;

-- Q8: Categorize sales by time of day (Morning, Afternoon, Evening)
-- Count number of invoices per shift and branch
SELECT
	"branch",
	CASE 
		WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        (ls.revenue - cs.revenue)::numeric / ls.revenue::numeric * 100, 
        2
    ) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;

