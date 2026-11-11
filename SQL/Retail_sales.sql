-- Part 1. Import data from excel as CSV-------------------------------------------


 USE githubproject1;
 
 
-- Part 2. VERIFY THE LOAD ----------------------------------

SELECT COUNT(*) AS total_rows 
FROM githubproject1.sales_raw;          
               -- expect ~9,802
               
               
SELECT MIN(order_date),
MAX(order_date)
FROM githubproject1.sales_raw;  
             
SELECT payment_method,
COUNT(*)
FROM githubproject1.sales_raw
GROUP BY payment_method; 


SELECT 
COUNT(*) AS null_discounts 
FROM githubproject1.sales_raw 
WHERE discount IS NULL;

SELECT MIN(quantity), MAX(quantity) 
FROM githubproject1.sales_raw;          

         
SELECT MIN(shipping_days), MAX(shipping_days) 
FROM githubproject1.sales_raw;       


SELECT COUNT(*) AS unknown_rows                                     
FROM githubproject1.sales_raw s
LEFT JOIN githubproject1.products p 
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;
 
  -- Part 3. Anaysis 1 ------------------------------------------
SELECT
    COUNT(DISTINCT order_id)              AS total_orders,
    SUM(quantity)                         AS units_sold,
    ROUND(SUM(sales), 2)                  AS total_revenue,
    ROUND(SUM(profit), 2)                 AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM githubproject1.sales_raw;
 
-- 3a SALES AND PROFIT OVER TIME -------------------
 
-- By year
SELECT
    order_year,
    ROUND(SUM(sales), 2)  AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM githubproject1.sales_raw
GROUP BY order_year
ORDER BY order_year;
 
-- By quarter
SELECT
    order_year,
    QUARTER(order_date)   AS quarter,
    ROUND(SUM(sales), 2)  AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM githubproject1.sales_raw
GROUP BY order_year, QUARTER(order_date)
ORDER BY order_year, quarter;
 
-- By month
SELECT
    order_year,
    order_month,
    ROUND(SUM(sales), 2)  AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM githubproject1.sales_raw
GROUP BY order_year, order_month
ORDER BY order_year, order_month;
 
-- 3B TOP PRODUCTS ---------------------------------
-- Top 10 products by revenue 
SELECT
    p.product_name,
    p.category,
    SUM(s.quantity)        AS units_sold,
    ROUND(SUM(s.sales), 2)  AS revenue,
    ROUND(SUM(s.profit), 2) AS profit
FROM githubproject1.sales_raw s
JOIN githubproject1.products p 
ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;
 
-- 3C TOP CUSTOMERS --------------------------------
SELECT
    c.customer_name,
    c.segment,
    COUNT(DISTINCT s.order_id) AS orders,
    ROUND(SUM(s.sales), 2)     AS revenue,
    ROUND(SUM(s.profit), 2)    AS profit
FROM githubproject1.sales_raw s
JOIN githubproject1.customers c 
ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY revenue DESC
LIMIT 10;
 
-- 4C BONUS: CATEGORY REVENUE VS PROFIT MARGIN ------------------
SELECT
    p.category,
    ROUND(SUM(s.sales), 2)  AS revenue,
    ROUND(SUM(s.profit), 2) AS profit,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.products p 
ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Part 4 ---
-- 4A STORE AND REGION PERFORMANCE ------------------
 
-- By region
SELECT
    st.region,
    ROUND(SUM(s.sales), 2)  AS revenue,
    ROUND(SUM(s.profit), 2) AS profit,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st 
ON s.store_id = st.store_id
GROUP BY st.region
ORDER BY revenue DESC;
 
-- By store
SELECT
    st.store_name,
    st.region,
    ROUND(SUM(s.sales), 2)  AS revenue,
    ROUND(SUM(s.profit), 2) AS profit,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st 
ON s.store_id = st.store_id
GROUP BY st.store_id, st.store_name, st.region
ORDER BY revenue DESC;
 
-- Store revenue by year (who is growing, who is shrinking?)
SELECT
    st.store_name,
    s.order_year,
    ROUND(SUM(s.sales), 2) AS revenue
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st
ON s.store_id = st.store_id
GROUP BY st.store_name, s.order_year
ORDER BY st.store_name, s.order_year;
 
-- Seasonality: average revenue per month across both years

SELECT
    order_month,
    ROUND(SUM(sales) / COUNT(DISTINCT order_year), 2) AS avg_monthly_revenue
FROM githubproject1.sales_raw
GROUP BY order_month
ORDER BY order_month;
 
-- 5 SHIPPING ---------------------------------
-- Overall time -------------------

SELECT
    ROUND(AVG(shipping_days), 2) AS avg_days,
    MIN(shipping_days) AS fastest,
    MAX(shipping_days) AS slowest
FROM githubproject1.sales_raw;
 
-- Shipping by store -------

SELECT
    st.store_name,
    ROUND(AVG(s.shipping_days), 2) AS avg_days
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st 
ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY avg_days DESC;
 
-- Shippping by region

SELECT
    st.region,
    ROUND(AVG(s.shipping_days), 2) AS avg_days
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st 
ON s.store_id = st.store_id
GROUP BY st.region
ORDER BY avg_days DESC;
 
-- Shippping By month (do busy months ship slower?)
SELECT
    order_month,
    ROUND(AVG(shipping_days), 2) AS avg_days
FROM githubproject1.sales_raw
GROUP BY order_month
ORDER BY order_month;
 
-- Part 6 IMPACT OF DISCOUNTS ---------------------------
 
-- Profit margin and average units by discount band
SELECT
    CASE
        WHEN discount IS NULL THEN 'Unknown'
        WHEN discount = 0     THEN '0% (none)'
        WHEN discount BETWEEN 1 AND 10 THEN '1-10%'
        WHEN discount BETWEEN 11 AND 19 THEN '11-20%'
        ELSE 'Over 20%'
    END AS discount_band,
    COUNT(*)                          AS order_lines,
    ROUND(AVG(quantity), 2)           AS avg_units_per_line,
    ROUND(SUM(sales), 2)              AS revenue,
    ROUND(SUM(profit), 2)             AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw
GROUP BY discount_band
ORDER BY MIN(discount);
 
-- Discounts by category (where are we discounting most?)

SELECT
    p.category,
    ROUND(AVG(IFNULL(s.discount, 0)) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.products p 
ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount_pct DESC;
 
 
 -- export to excel and biuld dashboard --- 