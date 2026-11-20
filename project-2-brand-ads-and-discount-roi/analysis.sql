-- =====================================================================
-- PROJECT 2 : BRAND ADS, DISCOUNTS & FIRST-ORDER OFFERS - WHAT PAYS BACK?
-- Business question: Which ads, discounts and offers actually create profit
--                    for a quick-commerce platform and its FMCG brands?
-- Database: PostgreSQL 14+ | Data: simulated (see 00_setup/generate_data.py)
-- Skills shown: CTEs, window functions, CASE WHEN bands, ratio metrics,
--               difference-in-differences (A/B style test), cohort retention
-- Words: ROAS = ad sales / ad spend | CTR = clicks / impressions
--        CPC = spend / clicks | CPA = spend / ad orders | GMV = sales value
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1. Ad report card by company and ad type
-- ---------------------------------------------------------------------
SELECT  c.company,
        c.ad_type,
        SUM(a.spend)                                              AS spend_inr,
        SUM(a.impressions)                                        AS impressions,
        SUM(a.clicks)                                             AS clicks,
        ROUND(100.0 * SUM(a.clicks) / SUM(a.impressions), 2)      AS ctr_pct,
        ROUND(SUM(a.spend) / NULLIF(SUM(a.clicks), 0), 2)         AS cpc_inr,
        ROUND(SUM(a.spend) / NULLIF(SUM(a.ad_orders), 0), 1)      AS cpa_inr,
        ROUND(SUM(a.ad_sales) / SUM(a.spend), 2)                  AS roas
FROM    ad_daily a
JOIN    ad_campaigns c ON c.campaign_id = a.campaign_id
GROUP BY c.company, c.ad_type
ORDER BY roas DESC;


-- ---------------------------------------------------------------------
-- Q2. How much of each company's sales is supported by ads?
-- Compares ad-attributed sales with the company's total sales on the platform.
-- ---------------------------------------------------------------------
WITH company_sales AS (
    SELECT p.company, SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM   order_items oi
    JOIN   orders o   ON o.order_id = oi.order_id AND o.status = 'Delivered'
    JOIN   products p ON p.sku_id = oi.sku_id
    GROUP BY p.company
),
company_ads AS (
    SELECT c.company, SUM(a.spend) AS ad_spend, SUM(a.ad_sales) AS ad_sales
    FROM   ad_daily a JOIN ad_campaigns c ON c.campaign_id = a.campaign_id
    GROUP BY c.company
)
SELECT  s.company,
        ROUND(s.total_sales)                                  AS total_sales_inr,
        ROUND(a.ad_spend)                                     AS ad_spend_inr,
        ROUND(100 * a.ad_spend / s.total_sales, 1)            AS ad_spend_pct_of_sales,
        ROUND(100 * a.ad_sales / s.total_sales, 1)            AS ad_attributed_pct_of_sales
FROM    company_sales s
JOIN    company_ads a ON a.company = s.company
ORDER BY ad_spend_pct_of_sales DESC;


-- ---------------------------------------------------------------------
-- Q3. Own label vs big FMCG brands: share and margin, by category
-- Window function SUM() OVER (PARTITION BY category) gives the category total.
-- ---------------------------------------------------------------------
WITH mix AS (
    SELECT  p.category, p.brand_type,
            SUM(oi.quantity * oi.unit_price)                       AS sales,
            SUM(oi.quantity * (oi.unit_price - oi.unit_cost))      AS margin
    FROM    order_items oi
    JOIN    orders o   ON o.order_id = oi.order_id AND o.status = 'Delivered'
    JOIN    products p ON p.sku_id = oi.sku_id
    GROUP BY p.category, p.brand_type
)
SELECT  category, brand_type,
        ROUND(sales)                                                   AS sales_inr,
        ROUND(100 * sales / SUM(sales) OVER (PARTITION BY category), 1) AS share_of_category_pct,
        ROUND(100 * margin / sales, 1)                                 AS margin_pct
FROM    mix
ORDER BY category, brand_type;


-- ---------------------------------------------------------------------
-- Q4. Do discounts pay? Units, sales and margin by discount depth
-- Unit of analysis = one SKU in one week. Each SKU-week has one discount level.
-- "Lift" compares units with the SAME SKU's units in weeks without a discount.
-- ---------------------------------------------------------------------
WITH sku_week AS (
    SELECT  oi.sku_id,
            DATE_TRUNC('week', o.order_ts)::date                     AS week_start,
            MAX(oi.discount_pct)                                     AS discount_pct,
            SUM(oi.quantity)                                         AS units,
            SUM(oi.quantity * oi.unit_price)                         AS sales,
            SUM(oi.quantity * (oi.unit_price - oi.unit_cost))        AS margin
    FROM    order_items oi
    JOIN    orders o ON o.order_id = oi.order_id AND o.status = 'Delivered'
    GROUP BY oi.sku_id, DATE_TRUNC('week', o.order_ts)
),
baseline AS (       -- each SKU's average weekly units when NOT discounted
    SELECT sku_id, AVG(units) AS base_units
    FROM   sku_week WHERE discount_pct = 0 GROUP BY sku_id
)
SELECT  CASE WHEN w.discount_pct = 0  THEN '0. No discount'
             WHEN w.discount_pct <= 10 THEN '1. 5-10%'
             WHEN w.discount_pct <= 20 THEN '2. 15-20%'
             ELSE '3. 25%' END                                          AS discount_band,
        COUNT(*)                                                        AS sku_weeks,
        ROUND(AVG(w.units / b.base_units), 2)                           AS units_index_vs_no_discount,
        ROUND(AVG(w.margin / NULLIF(w.sales, 0)) * 100, 1)              AS margin_pct,
        ROUND(AVG(w.margin / b.base_units), 1)                          AS margin_inr_per_baseline_unit
FROM    sku_week w
JOIN    baseline b ON b.sku_id = w.sku_id
GROUP BY 1
ORDER BY 1;


-- ---------------------------------------------------------------------
-- Q5. A/B-style test: did the Reckitt Dettol Search pilot lift sales?
-- Test cities (Bengaluru, Pune) got the pilot in weeks 5-8.  Other cities = control.
-- Method: DIFFERENCE-IN-DIFFERENCES on Reckitt's share of city sales.
--   share = Reckitt sales / all sales in that city and week
--   lift  = (test: during - before) - (control: during - before)
-- This removes things that hit all cities equally (festivals, weather, trend).
-- ---------------------------------------------------------------------
WITH city_week AS (
    SELECT  s.city,
            DATE_TRUNC('week', o.order_ts)::date                                         AS week_start,
            SUM(oi.quantity * oi.unit_price)                                             AS city_sales,
            SUM(oi.quantity * oi.unit_price) FILTER (WHERE p.company = 'Reckitt')        AS reckitt_sales
    FROM    order_items oi
    JOIN    orders o       ON o.order_id = oi.order_id AND o.status = 'Delivered'
    JOIN    dark_stores s  ON s.store_id = o.store_id
    JOIN    products p     ON p.sku_id = oi.sku_id
    GROUP BY s.city, DATE_TRUNC('week', o.order_ts)
),
tagged AS (
    SELECT  *,
            CASE WHEN city IN ('Bengaluru', 'Pune') THEN 'Test' ELSE 'Control' END       AS grp,
            CASE WHEN week_start BETWEEN DATE '2026-09-28' AND DATE '2026-10-25'
                 THEN 'During pilot'
                 WHEN week_start < DATE '2026-09-28' THEN 'Before' END                   AS period
    FROM    city_week
    WHERE   week_start <= DATE '2026-10-25'       -- ignore the last (post-pilot) week
),
shares AS (
    SELECT  grp, period,
            ROUND(100 * SUM(reckitt_sales) / SUM(city_sales), 2) AS reckitt_share_pct,
            ROUND(SUM(reckitt_sales) / COUNT(DISTINCT week_start)) AS reckitt_sales_per_week
    FROM    tagged
    GROUP BY grp, period
)
SELECT * FROM shares ORDER BY grp, period DESC;

-- Q5b. The lift itself and the return on pilot spend
--      incremental sales = share lift x total sales of the test cities during the pilot
WITH city_week AS (
    SELECT  s.city,
            DATE_TRUNC('week', o.order_ts)::date AS week_start,
            SUM(oi.quantity * oi.unit_price)     AS city_sales,
            SUM(oi.quantity * oi.unit_price) FILTER (WHERE p.company = 'Reckitt') AS reckitt_sales
    FROM    order_items oi
    JOIN    orders o      ON o.order_id = oi.order_id AND o.status = 'Delivered'
    JOIN    dark_stores s ON s.store_id = o.store_id
    JOIN    products p    ON p.sku_id = oi.sku_id
    GROUP BY s.city, DATE_TRUNC('week', o.order_ts)
),
agg AS (
    SELECT  (city IN ('Bengaluru', 'Pune'))                                              AS is_test,
            (week_start BETWEEN DATE '2026-09-28' AND DATE '2026-10-25')                 AS is_pilot,
            SUM(reckitt_sales) / SUM(city_sales)                                         AS share,
            SUM(city_sales)                                                              AS city_sales
    FROM    city_week
    WHERE   week_start <= DATE '2026-10-25'
    GROUP BY 1, 2
),
did AS (
    SELECT  (MAX(share) FILTER (WHERE is_test AND is_pilot)  - MAX(share) FILTER (WHERE is_test AND NOT is_pilot))
          - (MAX(share) FILTER (WHERE NOT is_test AND is_pilot) - MAX(share) FILTER (WHERE NOT is_test AND NOT is_pilot))
            AS share_lift,
            MAX(share) FILTER (WHERE is_test AND NOT is_pilot)                           AS test_share_before,
            MAX(city_sales) FILTER (WHERE is_test AND is_pilot)                          AS test_city_sales_pilot
    FROM    agg
),
pilot_spend AS (
    SELECT SUM(a.spend) AS spend
    FROM   ad_daily a JOIN ad_campaigns c ON c.campaign_id = a.campaign_id
    WHERE  c.campaign_name = 'Reckitt Dettol Search Pilot'
)
SELECT  ROUND(100 * share_lift, 2)                                          AS share_lift_pct_points,
        ROUND(100 * share_lift / test_share_before, 1)                      AS relative_lift_pct,
        ROUND(share_lift * test_city_sales_pilot)                           AS incremental_sales_inr,
        ROUND(spend)                                                        AS pilot_spend_inr,
        ROUND(share_lift * test_city_sales_pilot / spend, 1)                AS incremental_roas
FROM    did, pilot_spend;


-- ---------------------------------------------------------------------
-- Q6. First-order offer: does a Rs 100 off first order buy loyal customers?
-- Only customers whose first order was in the first 33 days (so each has a
-- full 30-day follow-up window inside the data).
-- ---------------------------------------------------------------------
WITH ranked AS (
    SELECT  o.*,
            c.offer_group,
            ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_ts) AS order_no,
            MIN(o.order_ts) OVER (PARTITION BY o.customer_id)                   AS first_ts
    FROM    orders o
    JOIN    customers c ON c.customer_id = o.customer_id
    WHERE   o.status = 'Delivered' AND c.offer_group IS NOT NULL
),
cohort AS (
    SELECT * FROM ranked
    WHERE  first_ts < DATE '2026-08-31' + INTERVAL '33 days'
),
per_customer AS (
    SELECT  customer_id, offer_group,
            MAX(items_total - order_discount) FILTER (WHERE order_no = 1)                       AS first_order_value,
            COUNT(*) FILTER (WHERE order_no > 1 AND order_ts <= first_ts + INTERVAL '30 days')  AS repeat_orders_30d,
            SUM(items_total - order_discount) FILTER (WHERE order_ts <= first_ts + INTERVAL '30 days') AS spend_30d
    FROM    cohort
    GROUP BY customer_id, offer_group
)
SELECT  offer_group,
        COUNT(*)                                                        AS customers,
        ROUND(AVG(first_order_value))                                   AS avg_first_order_inr,
        ROUND(100.0 * AVG((repeat_orders_30d >= 1)::int), 1)            AS repeat_within_30d_pct,
        ROUND(AVG(repeat_orders_30d), 2)                                AS repeat_orders_per_customer,
        ROUND(AVG(spend_30d))                                           AS spend_per_customer_30d_inr
FROM    per_customer
GROUP BY offer_group
ORDER BY offer_group;
