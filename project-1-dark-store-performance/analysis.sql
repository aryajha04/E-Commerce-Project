-- =====================================================================
-- PROJECT 1 : DARK STORE PERFORMANCE & AVAILABILITY
-- Business question: Which dark stores deliver fast, stay in stock and
--                    waste little - and where is money being lost?
-- Database: PostgreSQL 14+ | Data: simulated (see 00_setup/generate_data.py)
-- Skills shown: JOINs, CASE WHEN, CTEs, window functions
--               (RANK, NTILE, LAG, running SUM), percentiles, date functions
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1. Daily health of the business, by city
-- Why it matters: first thing a manager opens every morning.
-- GMV = total value of goods sold. AOV = average order value.
-- ---------------------------------------------------------------------
SELECT  s.city,
        o.order_ts::date                                          AS order_date,
        COUNT(*)                                                  AS orders,
        COUNT(*) FILTER (WHERE o.status = 'Delivered')            AS delivered_orders,
        ROUND(SUM(o.items_total) FILTER (WHERE o.status = 'Delivered'), 0) AS gmv_inr,
        ROUND(AVG(o.items_total) FILTER (WHERE o.status = 'Delivered'), 0) AS aov_inr,
        ROUND(100.0 * COUNT(*) FILTER (WHERE o.status = 'Cancelled') / COUNT(*), 2) AS cancel_pct
FROM    orders o
JOIN    dark_stores s ON s.store_id = o.store_id
GROUP BY s.city, o.order_ts::date
ORDER BY order_date, s.city;


-- ---------------------------------------------------------------------
-- Q2. Delivery speed by store: share of orders delivered within 10 minutes
-- A CTE (WITH ...) is a named temporary table. It keeps the query readable.
-- ---------------------------------------------------------------------
WITH delivery AS (
    SELECT  store_id,
            EXTRACT(EPOCH FROM (delivered_ts - order_ts)) / 60.0 AS delivery_min
    FROM    orders
    WHERE   status = 'Delivered'
)
SELECT  s.store_name,
        s.city,
        COUNT(*)                                                       AS delivered_orders,
        ROUND(100.0 * AVG((d.delivery_min <= 10)::int), 1)             AS pct_within_10_min,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY d.delivery_min)::numeric, 1) AS median_min,
        ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY d.delivery_min)::numeric, 1) AS p90_min
FROM    delivery d
JOIN    dark_stores s ON s.store_id = d.store_id
GROUP BY s.store_name, s.city
ORDER BY pct_within_10_min DESC;


-- ---------------------------------------------------------------------
-- Q3. Which hours slow us down? (peak-hour pressure)
-- ---------------------------------------------------------------------
SELECT  EXTRACT(HOUR FROM order_ts)::int                               AS hour_of_day,
        COUNT(*)                                                       AS orders,
        ROUND(AVG(EXTRACT(EPOCH FROM (delivered_ts - order_ts)) / 60.0)::numeric, 1) AS avg_delivery_min,
        ROUND(100.0 * AVG((EXTRACT(EPOCH FROM (delivered_ts - order_ts)) <= 600)::int), 1) AS pct_within_10_min
FROM    orders
WHERE   status = 'Delivered'
GROUP BY 1
ORDER BY 1;


-- ---------------------------------------------------------------------
-- Q4. Money lost to WASTAGE and STOCK-OUTS, by category
-- Wastage cost  = units thrown away x unit cost.
-- Lost sales    = estimate: (hours out of stock / 18 open hours) x normal daily
--                 units for that store-SKU, valued at selling margin.
-- ---------------------------------------------------------------------
WITH normal_sales AS (            -- usual daily units, measured on days the SKU was in stock
    SELECT store_id, sku_id, AVG(units_sold) AS normal_daily_units
    FROM   inventory_daily
    WHERE  stockout_hours = 0
    GROUP BY store_id, sku_id
),
loss AS (
    SELECT  p.category,
            SUM(i.units_wasted * p.unit_cost)                                         AS wastage_cost,
            SUM(i.stockout_hours / 18.0 * n.normal_daily_units * (p.mrp - p.unit_cost)) AS lost_margin_est,
            SUM(i.units_sold * p.mrp)                                                  AS sales_at_mrp
    FROM    inventory_daily i
    JOIN    products p     ON p.sku_id = i.sku_id
    JOIN    normal_sales n ON n.store_id = i.store_id AND n.sku_id = i.sku_id
    GROUP BY p.category
)
SELECT  category,
        ROUND(wastage_cost)                                       AS wastage_cost_inr,
        ROUND(lost_margin_est)                                    AS lost_margin_from_stockouts_inr,
        ROUND(100 * wastage_cost / sales_at_mrp, 2)               AS wastage_pct_of_sales,
        ROUND(100 * lost_margin_est / sales_at_mrp, 2)            AS stockout_loss_pct_of_sales
FROM    loss
ORDER BY wastage_cost + lost_margin_est DESC;


-- ---------------------------------------------------------------------
-- Q5. ABC classification of SKUs (which items really make the money)
-- A = first 70% of sales, B = next 20%, C = last 10%.
-- Window function: running total with SUM() OVER (ORDER BY ...).
-- ---------------------------------------------------------------------
WITH sku_sales AS (
    SELECT  p.sku_id, p.product_name, p.category, p.brand_type,
            SUM(oi.quantity * oi.unit_price) AS sales
    FROM    order_items oi
    JOIN    orders o   ON o.order_id = oi.order_id AND o.status = 'Delivered'
    JOIN    products p ON p.sku_id = oi.sku_id
    GROUP BY p.sku_id, p.product_name, p.category, p.brand_type
),
cum AS (
    SELECT  *,
            SUM(sales) OVER (ORDER BY sales DESC) / SUM(sales) OVER () AS cum_share
    FROM    sku_sales
)
SELECT  product_name, category, brand_type,
        ROUND(sales)                       AS sales_inr,
        ROUND(100 * cum_share, 1)          AS cumulative_pct,
        CASE WHEN cum_share <= 0.70 THEN 'A'
             WHEN cum_share <= 0.90 THEN 'B'
             ELSE 'C' END                  AS abc_class
FROM    cum
ORDER BY sales DESC;


-- ---------------------------------------------------------------------
-- Q6. STORE SCORECARD (the main deliverable)
-- Score = 40% speed + 30% availability + 20% low wastage + 10% sales.
-- Each metric is turned into a percentile rank first, so metrics measured
-- in different units can be added fairly.
-- Window functions: PERCENT_RANK, RANK ... PARTITION BY city, NTILE.
-- ---------------------------------------------------------------------
WITH speed AS (
    SELECT store_id,
           AVG((EXTRACT(EPOCH FROM (delivered_ts - order_ts)) <= 600)::int) AS within_10
    FROM   orders WHERE status = 'Delivered' GROUP BY store_id
),
stock AS (
    SELECT store_id,
           SUM(stockout_hours) / (COUNT(*) * 18.0)                          AS stockout_rate,
           SUM(units_wasted)::numeric / NULLIF(SUM(units_stocked), 0)       AS waste_rate
    FROM   inventory_daily GROUP BY store_id
),
sales AS (
    SELECT store_id, SUM(items_total) AS gmv
    FROM   orders WHERE status = 'Delivered' GROUP BY store_id
),
metrics AS (
    SELECT s.store_id, s.store_name, s.city,
           sp.within_10, st.stockout_rate, st.waste_rate, sa.gmv
    FROM   dark_stores s
    JOIN   speed sp ON sp.store_id = s.store_id
    JOIN   stock st ON st.store_id = s.store_id
    JOIN   sales sa ON sa.store_id = s.store_id
),
scored AS (
    SELECT *,
           100 * ( 0.40 * PERCENT_RANK() OVER (ORDER BY within_10)
                 + 0.30 * PERCENT_RANK() OVER (ORDER BY stockout_rate DESC)
                 + 0.20 * PERCENT_RANK() OVER (ORDER BY waste_rate DESC)
                 + 0.10 * PERCENT_RANK() OVER (ORDER BY gmv) )  AS score
    FROM metrics
)
SELECT  store_name, city,
        ROUND(100 * within_10, 1)       AS pct_within_10_min,
        ROUND(100 * stockout_rate, 1)   AS stockout_pct,
        ROUND(100 * waste_rate, 2)      AS wastage_pct,
        ROUND(gmv)                      AS gmv_inr,
        ROUND(score::numeric, 1)        AS score,
        RANK()  OVER (PARTITION BY city ORDER BY score DESC) AS rank_in_city,
        NTILE(4) OVER (ORDER BY score DESC)                  AS quartile   -- 1 = best 25%
FROM    scored
ORDER BY score DESC;


-- ---------------------------------------------------------------------
-- Q7. Weekly GMV and growth vs last week (LAG)
-- ---------------------------------------------------------------------
WITH weekly AS (
    SELECT  DATE_TRUNC('week', order_ts)::date AS week_start,
            SUM(items_total)                   AS gmv
    FROM    orders
    WHERE   status = 'Delivered'
    GROUP BY 1
)
SELECT  week_start,
        ROUND(gmv)                                                   AS gmv_inr,
        ROUND(100.0 * (gmv - LAG(gmv) OVER (ORDER BY week_start))
              / LAG(gmv) OVER (ORDER BY week_start), 1)              AS wow_growth_pct
FROM    weekly
ORDER BY week_start;
