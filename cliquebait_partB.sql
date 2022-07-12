-- 6th study case
-- insert data is done by copying the code from db fiddle in the case detail
-- first thing first is to understand the tables first.

-- B. Digital Analysis

-- B.1 How many users are there?
SELECT 
    COUNT (DISTINCT user_id) unique_user
FROM users;

-- B.2 How many cookies does each user have on average?
WITH cte AS (
    SELECT 
        DISTINCT user_id,
        COUNT (cookie_id) num_cookie_id
    FROM users
    GROUP BY 1
)
SELECT 
    ROUND(AVG(num_cookie_id),2) avg_cookie
FROM cte;

-- B.3 What is the unique number of visits by all users per month?
SELECT 
    DATE_PART('month', event_time) month_num,
    COUNT(DISTINCT visit_id) number_unique
FROM events
GROUP BY 1;

-- B.4 What is the number of events for each event type?
SELECT
    event_type,
    COUNT(*)
FROM events
GROUP BY 1
ORDER BY 1;
    
-- B.5 What is the percentage of visits which have a purchase event?
-- purchase is #3 from event_identifier table
WITH cte AS (
SELECT
    visit_id,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) purchase_mark
FROM events
GROUP BY 1
)
SELECT 
    ROUND(100*SUM(purchase_mark)/COUNT(*),2) pct_purchase
FROM cte;


-- B.6 What is the percentage of visits which view the checkout page but do not have a purchase event?
-- keywords: 'which view the checkout page' --> search for event_type 1 with page_id = 12 for first step filter
-- then event page <> 3
-- keep in mind that for a person to visit a checkout page he/she has multiple visits. 
-- then we can use MAX function to give the binary mark when a person view the checkout page. 

WITH cte AS (
SELECT
    visit_id,
    MAX(CASE WHEN event_type = 1
        AND page_id = 12
        THEN 1 ELSE 0 END) view_checkout,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) purchase_mark
FROM events
GROUP BY 1
)
SELECT 
    ROUND(100*CAST(SUM(CASE WHEN purchase_mark = 0 THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*),2) pct_visits
FROM cte
WHERE view_checkout = 1;

-- B.7 What are the top 3 pages by number of views?
SELECT
    t2.page_name,
    COUNT(*) num_views
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE event_type = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- B.8 What is the number of views and cart adds for each product category?
SELECT
    t2.product_category,
    SUM(CASE WHEN t1.event_type = 1 THEN 1 ELSE 0 END) page_view_num,
    SUM(CASE WHEN t1.event_type = 2 THEN 1 ELSE 0 END) add_cart_num
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t2.product_category IS NOT NULL 
GROUP BY 1
ORDER BY 2 DESC;
    
-- B.9 What are the top 3 products by purchases?
-- by purchases meant that the products should have event_type 3. 
-- so, we need to filter out visit_id's that have event_type 3 only. 
-- products purchased must be added to the cart before purchased (event type 2),
-- and we need to calculate the number of products through the occurence of page_id 3-11

WITH cte_calculate AS ( 
SELECT
    t1.visit_id,
    t2.product_id,
    t2.page_name,
    SUM(CASE WHEN t2.page_id BETWEEN 3 AND 11 
        AND event_type = 2
        THEN 1 ELSE 0 END) product_bought     
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t1.visit_id IN (
    SELECT visit_id
    FROM events
    WHERE event_type = 3)
GROUP BY 1,2,3
)
SELECT
    page_name,
    SUM(product_bought) total_purchased
FROM cte_calculate
WHERE product_id IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
