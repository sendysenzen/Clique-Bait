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

-- C. Product Funnel Analysis
-- Using a single SQL query - create a new output table which has the following details:

-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?
DROP TABLE IF EXISTS products;
CREATE TABLE products AS
WITH cte_views_added AS (
SELECT 
    t2.product_id,
    t2.page_name,
    SUM(CASE WHEN t1.event_type=1 THEN 1 ELSE 0 END) num_views,
    SUM(CASE WHEN t1.event_type=2 THEN 1 ELSE 0 END) num_added
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t2.product_id IS NOT NULL
GROUP BY 1,2
ORDER BY 1
), cte_abandoned AS (
SELECT 
    t2.product_id,
    t2.page_name,
    SUM(CASE WHEN t1.event_type=2 THEN 1 ELSE 0 END) num_abandoned
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t1.visit_id NOT IN ( 
    SELECT visit_id
    FROM events
    WHERE event_type = 3
    ) AND t2.product_id IS NOT NULL
GROUP BY 1,2
ORDER BY 1
), cte_purchased AS ( 
SELECT 
    t2.product_id,
    t2.page_name,
    SUM(CASE WHEN t1.event_type=2 THEN 1 ELSE 0 END) num_purchased
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t1.visit_id IN ( 
    SELECT visit_id
    FROM events
    WHERE event_type = 3
    ) AND t2.product_id IS NOT NULL
GROUP BY 1,2
ORDER BY 1
)
SELECT 
    t1.product_id,
    t1.page_name product_name,
    t1.num_views,
    t1.num_added,
    t2.num_abandoned,
    t3.num_purchased
FROM cte_views_added t1
    INNER JOIN cte_abandoned t2
    ON t1.product_id = t2.product_id
    INNER JOIN cte_purchased t3
    ON t1.product_id = t3.product_id;
    
-- actually one cte step can be reduced because total cart_add minus the abandoned ones is the purchased ones :)   

-- C.1 Which product had the most views, cart adds and purchases?
-- This question can be answered with ORDER BY and LIMIT from the table above

-- C.2 Which product was most likely to be abandoned?
-- probability to be abandoned? percentage of a product to be abandoned compared to the total
SELECT 
    product_name,
    ROUND(num_abandoned::NUMERIC/num_added::NUMERIC,2) prob_abandoned
FROM products
ORDER BY 2 DESC
LIMIT 1;

-- C.3 Which product had the highest view to purchase percentage?
SELECT 
    product_name,
    ROUND(100*num_purchased::NUMERIC/num_views::NUMERIC,2) pct_purchased
FROM products
ORDER BY 2 DESC
LIMIT 1;

-- C.4 What is the average conversion rate from view to cart add?
SELECT 
    ROUND(100*AVG(num_added::NUMERIC/num_views::NUMERIC),2) avg_crate_views_add
FROM products

-- C.5 What is the average conversion rate from cart add to purchase?
SELECT 
    ROUND(100*AVG(num_purchased::NUMERIC/num_added::NUMERIC),2) avg_crate_add_purchase
FROM products

-- D. Campaigns Analysis

/*
Generate a table that has 1 single row for every unique visit_id record and has the following columns:

-user_id
-visit_id
-visit_start_time: the earliest event_time for each visit
-page_views: count of page views for each visit
-cart_adds: count of product cart add events for each visit
-purchase: 1/0 flag if a purchase event exists for each visit
-campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
-impression: count of ad impressions for each visit
-click: count of ad clicks for each visit
-(Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order 
they were added to the cart (hint: use the sequence_number)
*/

WITH cte_campaign AS(
SELECT 
    t2.user_id,
    t1.visit_id,
    MIN(event_time) visit_start_time,
    SUM(CASE WHEN event_type=1 THEN 1 ELSE 0 END) page_views,
    SUM(CASE WHEN event_type=2 THEN 1 ELSE 0 END) cart_adds,
    MAX(CASE WHEN event_type=3 THEN 1 ELSE 0 END) purchase,
    t3.campaign_name,
    MAX(CASE WHEN event_type=4 THEN 1 ELSE 0 END) impression,
    MAX(CASE WHEN event_type=5 THEN 1 ELSE 0 END) click
FROM events t1
    INNER JOIN users t2
    ON t1.cookie_id = t2.cookie_id
    LEFT JOIN campaign_identifier t3 
    ON t1.event_time BETWEEN t3.start_date AND t3.end_date 
GROUP BY 1,2,t3.campaign_name
ORDER BY 1
), cte_optional AS (
SELECT
    t1.visit_id,
    STRING_AGG(t2.page_name::text, ', 'ORDER BY t1.sequence_number ) cart_products
FROM events t1
    INNER JOIN page_hierarchy t2
    ON t1.page_id = t2.page_id
WHERE t1.event_type = 2
GROUP BY 1
ORDER BY 1
)
SELECT
    t1.user_id,
    t1.visit_id, 
    t1.visit_start_time,
    t1.page_views,
    t1.cart_adds,
    t1.purchase,
    t1.campaign_name,
    t1.impression,
    t1.click,
    t2.cart_products
FROM cte_campaign t1
    LEFT JOIN cte_optional t2
    ON t1.visit_id = t2.visit_id

-- Campaign analysis will be continued with executive summary.. to be updated


