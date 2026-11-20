-- =====================================================================
-- STEP 2: create the 8 tables  |  MySQL 8.0+
-- Each table has ONE job. Tables are linked by id columns.
-- =====================================================================
USE quickcommerce;

SET FOREIGN_KEY_CHECKS = 0;            -- lets us drop tables in any order when re-running
DROP TABLE IF EXISTS ad_daily, ad_campaigns, inventory_daily, order_items, orders,
                     customers, products, dark_stores;
SET FOREIGN_KEY_CHECKS = 1;

-- 1) dark_stores : the small warehouses that deliver in ~10 minutes
CREATE TABLE dark_stores (
    store_id     INT PRIMARY KEY,
    store_name   VARCHAR(20),
    city         VARCHAR(30),
    area         VARCHAR(40),
    opened_date  DATE,
    size_sqft    INT
);

-- 2) products : one row per SKU (one sellable item and pack size)
CREATE TABLE products (
    sku_id          INT PRIMARY KEY,
    product_name    VARCHAR(80),
    category        VARCHAR(30),
    brand           VARCHAR(30),
    company         VARCHAR(30),           -- who owns the brand (Reckitt owns Dettol)
    brand_type      VARCHAR(12),           -- 'Big FMCG' or 'Own label'
    mrp             DECIMAL(8,2),          -- printed maximum retail price
    unit_cost       DECIMAL(8,2),          -- what the platform pays per unit
    shelf_life_days INT,                   -- 0 = long life
    is_perishable   BOOLEAN
);

-- 3) customers
CREATE TABLE customers (
    customer_id         INT PRIMARY KEY,
    city                VARCHAR(30),
    joined_date         DATE,
    acquisition_channel VARCHAR(15),
    offer_group         VARCHAR(20)        -- new customers only: got first-order offer or not
);

-- 4) orders : one row per order
CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT,
    store_id       INT,
    order_ts       DATETIME,
    delivered_ts   DATETIME,               -- NULL when cancelled
    status         VARCHAR(12),            -- 'Delivered' / 'Cancelled'
    items_total    DECIMAL(10,2),
    delivery_fee   DECIMAL(6,2),
    order_discount DECIMAL(6,2),           -- first-order offer amount
    promo_code     VARCHAR(12),
    is_first_order BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id)    REFERENCES dark_stores(store_id)
);

-- 5) order_items : the products inside each order
CREATE TABLE order_items (
    item_id      INT PRIMARY KEY,
    order_id     INT,
    sku_id       INT,
    quantity     INT,
    discount_pct INT,                      -- item discount that week
    unit_price   DECIMAL(8,2),             -- what the customer paid per unit
    unit_cost    DECIMAL(8,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (sku_id)   REFERENCES products(sku_id)
);

-- 6) inventory_daily : one row per store, SKU and day
CREATE TABLE inventory_daily (
    stock_date     DATE,
    store_id       INT,
    sku_id         INT,
    units_stocked  INT,                    -- units on shelf at start of day
    units_sold     INT,
    units_wasted   INT,                    -- expired / damaged / thrown away
    stockout_hours INT,                    -- hours unavailable (store open 18 hours)
    PRIMARY KEY (stock_date, store_id, sku_id),
    FOREIGN KEY (store_id) REFERENCES dark_stores(store_id),
    FOREIGN KEY (sku_id)   REFERENCES products(sku_id)
);

-- 7) ad_campaigns : brand ads shown inside the app
CREATE TABLE ad_campaigns (
    campaign_id   INT PRIMARY KEY,
    company       VARCHAR(30),
    ad_type       VARCHAR(10),             -- 'Search' or 'Banner'
    campaign_name VARCHAR(60),
    start_date    DATE,
    end_date      DATE
);

-- 8) ad_daily : daily results per campaign and city
CREATE TABLE ad_daily (
    campaign_id INT,
    ad_date     DATE,
    city        VARCHAR(30),
    impressions INT,
    clicks      INT,
    spend       DECIMAL(10,2),
    ad_orders   INT,
    ad_sales    DECIMAL(12,2),             -- sales the platform credits to the ad
    PRIMARY KEY (campaign_id, ad_date, city),
    FOREIGN KEY (campaign_id) REFERENCES ad_campaigns(campaign_id)
);

-- Indexes make joins and date filters fast
CREATE INDEX idx_orders_store_ts ON orders (store_id, order_ts);
CREATE INDEX idx_inv_store_sku   ON inventory_daily (store_id, sku_id);

SHOW TABLES;                           -- you should see 8 tables
