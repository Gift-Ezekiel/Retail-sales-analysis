-- =====================================================
-- RETAIL SALES ANALYSIS: DATABASE SETUP
-- Run section by section in MySQL Workbench
-- =====================================================

-- 1. DATABASE -----------------------------------------
CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- 2. DIMENSION TABLES (load these first) --------------
CREATE TABLE stores (
    store_id    INT PRIMARY KEY,
    store_name  VARCHAR(50),
    city        VARCHAR(50),
    region      VARCHAR(20)
);

 
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(80),
    category      VARCHAR(40),
    sub_category  VARCHAR(40),
    unit_cost     DECIMAL(10,2),
    unit_price    DECIMAL(10,2)
);

CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    customer_name  VARCHAR(80),
    gender         VARCHAR(10),
    segment        VARCHAR(20),
    city           VARCHAR(50),
    signup_date    DATE
);
 
-- 3. FACT TABLE ---------------------------------------
-- ordercompany_sales_data_id repeats (an order can have 2 lines), so we add
-- our own auto-numbered line_id as the primary key.


CREATE TABLE sales (
    line_id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    order_date      DATE NOT NULL,
    order_year      SMALLINT,
    order_month     VARCHAR(15),            -- change to VARCHAR(15) if yours holds names like "January"
    ship_date       DATE,
    shipping_days   SMALLINT,
    customer_id     INT,
    product_id      INT,
    store_id        INT,
    quantity        INT,
    discount        DECIMAL(4,2) NULL,  -- NULL = discount unknown
    payment_method  VARCHAR(20),
    sales           DECIMAL(10,2),
    profit          DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    FOREIGN KEY (store_id)    REFERENCES stores(store_id)
);
 
 -- 4. VERIFY THE LOAD ----------------------------------
 Select *
 FROM githubproject1.sales;
 
SELECT COUNT(*) AS total_rows 
FROM githubproject1.sales_raw;                         -- expect ~9,802

SELECT MIN(order_date), MAX(order_date)
FROM githubproject1.sales_raw;               -- within 2024-01-01 and 2025-12-31


SELECT payment_method, COUNT(*)
FROM githubproject1.sales_raw
GROUP BY payment_method; -- 5 methods + Unknown


SELECT COUNT(*) AS null_discounts
FROM githubproject1.sales_raw
WHERE discount IS NULL;


SELECT MIN(quantity), MAX(quantity)
FROM githubproject1.sales_raw;                   -- small positive numbers

-- here we fishe ot the outliers and give them the right quantiyt ----

SELECT s.order_id, s.product_id, s.quantity, s.discount, s.sales,
       p.unit_price,
       ROUND(s.sales / (p.unit_price * (1 - IFNULL(s.discount, 0)/100))) As expected_qty
FROM githubproject1.sales_raw s
JOIN githubproject1.products p ON s.product_id = p.product_id
WHERE s.quantity > 8;

UPDATE githubproject1.sales_raw s
JOIN githubproject1.products p ON s.product_id = p.product_id
SET s.quantity = ROUND(s.sales / (p.unit_price * (1 - IFNULL(s.discount, 0)/100)))
WHERE s.quantity > 8;

SET SQL_SAFE_UPDATES = 1;


SELECT MIN(shipping_days), MAX(shipping_days)
FROM githubproject1.sales_raw;         -- no negatives

truncate table githubproject1.sales_raw;

SELECT COUNT(*) AS orphan_rows                                     -- expect 0
FROM githubproject1.sales_raw s
JOIN products p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;
 
 
 -- KPIs ---
 
 -- Total orders ---
 Select DISTINCT(COUNT(order_Id)) Total_orders
 FROM githubproject1.sales_raw;
 
 -- Total units sold ---
  Select SUM(quantity)
 FROM githubproject1.sales_raw;
 
 -- Total sales/revenue --
  Select ROUND(SUM(sales), 2) sales_sum
 FROM githubproject1.sales_raw;
 
 -- Profit generated --
  Select ROUND(SUM(Profit), 2) Profit_sum
 FROM githubproject1.sales_raw;
 
 -- profit margin --
 SELECT ROUND(SUM(Profit) / SUM(sales) * 100, 1) Profit_margin
 FROM githubproject1.sales_raw;
 
 -- sales over time --
 -- By year --
 
 SELECT 
 order_year, 
 SUM(quantity) Units_sold,
 ROUND(SUM(Sales), 2) Yearly_sales,
 ROUND(SUM(Profit), 2) Yearly_profit
 FROM githubproject1.sales_raw
 GROUP BY order_year;
 
 -- By quater --
 SELECT
 order_year,
 QUARTER(order_date) Quater,
 ROUND(SUM(Sales), 0) Quaterly_sales,
 ROUND(SUM(Profit), 0) Quaterly_profit
 FROM githubproject1.sales_raw
 GROUP BY order_year, Quater
 ORDER BY Quater;
 
 -- By Month --
 
 SELECT
  SUM(quantity) Units_sold,
    order_year,
    order_month,
    ROUND(SUM(sales), 2)  AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM githubproject1.sales_raw
GROUP BY order_year, order_month
ORDER BY units_sold;

-- TOP 10 PRODUCTS -
SELECT 
product_name,
 p.category,
SUM(s.quantity) Quantity_sold,
ROUND(SUM(sales), 0) sales,
ROUND(SUM(profit), 0) Profits
FROM githubproject1.sales_raw s
JOIN githubproject1.products p
ON p.product_id = s.product_id
GROUP BY product_name,  p.category
ORDER BY profits DESC
LiMIT 10;
 
 
 -- TOP 10 CUSTOMERS -
SELECT
c.customer_name,
c.segment,
COUNT(DISTINCT s.order_id) AS orders,
ROUND(SUM(sales), 0) sales,
ROUND(SUM(profit), 0) Profits,
ROUND(SUM(discount), 0) discounts
FROM githubproject1.sales_raw s
JOIN githubproject1.customers c
ON c.customer_id = s.customer_id
GROUP BY customer_name, c.segment
Order by sales DESC
LiMIT 10;
 
-- CATEGORY REVENUE VS PROFIT MARGIN ------------------
SELECT
    p.category,
    SUM(s.quantity) Unit_sold,
    ROUND(SUM(s.sales), 2)  AS revenue,
    ROUND(SUM(s.profit), 2) AS profit,
    ROUND(SUM(s.discount), 2) AS discount,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.products p
ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;
 
-- STORE AND REGION PERFORMANCE ----
-- store --
SELECT 
store_name,
Region,
SUM(quantity) Umits_sold,
ROUND(SUM(sales), 0) sales,
ROUND(SUM(profit), 0) Profits,
ROUND(SUM(s.profit) / SUM(s.sales) * 100, 0) profit_margin
FROM githubproject1.stores st
JOIN githubproject1.sales_raw s
ON s.store_id = st.store_id
GROUP BY store_name, region
Order BY sales DESC;
 
 
 -- region ---
 
 SELECT 
region,
SUM(quantity) Umits_sold,
ROUND(SUM(sales), 0) sales,
ROUND(SUM(profit), 0) Profits,
ROUND(SUM(s.profit) / SUM(s.sales) * 100, 0) profit_margin
FROM githubproject1.stores st
JOIN githubproject1.sales_raw s
ON s.store_id = st.store_id
GROUP BY st.region
Order BY sales DESC;

--  Store revenue by year (who is growing, who is shrinking?)
SELECT 
store_name,
s.order_year,
SUM(quantity) Umits_sold,
ROUND(SUM(sales), 0) sales,
ROUND(SUM(profit), 0) Profits,
ROUND(SUM(discount), 0) Discounts,
ROUND(SUM(s.profit) / SUM(s.sales) * 100, 0) profit_margin
FROM githubproject1.stores st
JOIN githubproject1.sales_raw s
ON s.store_id = st.store_id
GROUP BY store_name, s.order_year 
Order BY sales DESC;

-- Seasonality: average revenue per month across both years --

SELECT
    order_month,
    ROUND(SUM(sales) / COUNT(DISTINCT order_year), 2) AS avg_monthly_revenue
FROM githubproject1.sales_raw
GROUP BY order_month
ORDER BY avg_monthly_revenue desc;

-- SHIPPING TIME ---------------------------------
 
-- 4a. Overall
SELECT
    ROUND(AVG(shipping_days), 2) AS avg_days,
    MIN(shipping_days) AS fastest,
    MAX(shipping_days) AS slowest
FROM githubproject1.sales_raw;
 
-- 4b. By store
SELECT
    st.store_name,
    ROUND(AVG(s.shipping_days), 2) AS avg_days,
    sum(discount)
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY avg_days DESC;
 
-- 4c. By region
SELECT
    st.region,
    ROUND(AVG(s.shipping_days), 2) AS avg_days
FROM githubproject1.sales_raw s
JOIN githubproject1.stores st ON s.store_id = st.store_id
GROUP BY st.region
ORDER BY avg_days DESC;

-- By month (do busy months ship slower?)
SELECT
    order_month,
    SUM(quantity) Units_sold,
    ROUND(AVG(shipping_days), 2) AS avg_days
FROM githubproject1.sales_raw
GROUP BY order_month
ORDER BY avg_days DESC;

-- Profit margin and average units by discount band
SELECT
    CASE
        WHEN discount IS NULL THEN 'Unknown'
        WHEN discount = 0     THEN '0 (none)'
        WHEN discount between 1 and 10 THEN '1-10'
        WHEN discount between 11 and 20 THEN '11-20'
        ELSE 'Over 20'
    END AS discount_band,
    COUNT(*)                          AS order_lines,
    ROUND(AVG(quantity), 2)           AS avg_units_per_line,
    ROUND(SUM(sales), 2)              AS revenue,
    ROUND(SUM(profit), 2)             AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw
GROUP BY discount_band
ORDER BY MIN(discount);
 
 SELECT
 category,
 ROUND(AVG(s.discount), 1) AS discounts,
 ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
 FROM githubproject1.sales_raw s
 JOIN githubproject1.products p
 ON p.product_id = s.product_id
 GROUP BY category
 ORDER BY Discounts DESC;
 
 --  Discounts by category (where are we discounting most?)
SELECT
    p.category,
    ROUND(AVG(IFNULL(s.discount, 0)) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS margin_pct
FROM githubproject1.sales_raw s
JOIN githubproject1.products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount_pct DESC;
 
 SELECT
    s.order_id,
    s.order_date,
    s.order_year,
    s.order_month,
    MONTHNAME(s.order_date)  AS month_name,
    QUARTER(s.order_date)    AS order_quarter,
    s.ship_date,
    s.shipping_days,
    c.customer_name,
    c.segment,
    p.product_name,
    p.category,
    p.sub_category,
    st.store_name,
    st.region,
    s.quantity,
    s.discount,
    CASE
        WHEN discount IS NULL THEN 'Unknown'
        WHEN discount = 0     THEN '0 (none)'
        WHEN discount between 1 and 10 THEN '1-10'
        WHEN discount between 11 and 20 THEN '11-20'
        ELSE 'Over 20'
    END AS discount_band,
    s.payment_method,
    s.sales,
    s.profit
FROM githubproject1.sales_raw s
JOIN githubproject1.customers c ON s.customer_id = c.customer_id
JOIN githubproject1.products  p ON s.product_id  = p.product_id
JOIN githubproject1.stores   st ON s.store_id    = st.store_id
ORDER BY s.order_date, s.order_id;
 
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
 