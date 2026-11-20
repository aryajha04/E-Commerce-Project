-- =====================================================================
-- QUICK-COMMERCE SQL PORTFOLIO  |  Database: PostgreSQL 14+
-- Simulated data modelled on dark-store / 10-minute delivery businesses.
-- 8 tables. Each table has ONE job. We join them by ids.
-- =====================================================================
DROP TABLE IF EXISTS ad_daily, ad_campaigns, inventory_daily, order_items, orders,
                     customers, products, dark_stores CASCADE;

-- 1) dark_stores : the small warehouses that deliver in ~10 minutes
CREATE TABLE dark_stores (
    store_id     INT PRIMARY KEY,
    store_name   VARCHAR(20),
    city         VARCHAR(30),
    area         VARCHAR(40),
    opened_date  DATE,
    size_sqft    INT
);

-- 2) products : one row per SKU (a SKU = one sellable item and pack size)
CREATE TABLE products (
    sku_id          INT PRIMARY KEY,
    product_name    VARCHAR(80),
    category        VARCHAR(30),
    brand           VARCHAR(30),
    company         VARCHAR(30),             -- who owns the brand (e.g. Reckitt owns Dettol)
    brand_type      VARCHAR(12),             -- 'Big FMCG' or 'Own label'
    mrp             NUMERIC(8,2),            -- printed maximum retail price
    unit_cost       NUMERIC(8,2),            -- what the platform pays per unit
    shelf_life_days INT,                     -- 0 = long life
    is_perishable   BOOLEAN
);

-- 3) customers
CREATE TABLE customers (
    customer_id         INT PRIMARY KEY,
    city                VARCHAR(30),
    joined_date         DATE,
    acquisition_channel VARCHAR(15),
    offer_group         VARCHAR(20)          -- new customers only: got first-order offer or not
);

-- 4) orders : one row per order (the container)
CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT REFERENCES customers(customer_id),
    store_id       INT REFERENCES dark_stores(store_id),
    order_ts       TIMESTAMP,
    delivered_ts   TIMESTAMP,                -- NULL when cancelled
    status         VARCHAR(12),              -- 'Delivered' / 'Cancelled'
    items_total    NUMERIC(10,2),
    delivery_fee   NUMERIC(6,2),
    order_discount NUMERIC(6,2),             -- first-order offer amount
    promo_code     VARCHAR(12),
    is_first_order BOOLEAN
);

-- 5) order_items : what was inside each order (one row per SKU per order)
CREATE TABLE order_items (
    item_id      INT PRIMARY KEY,
    order_id     INT REFERENCES orders(order_id),
    sku_id       INT REFERENCES products(sku_id),
    quantity     INT,
    discount_pct INT,                        -- item discount that week
    unit_price   NUMERIC(8,2),               -- what the customer paid per unit
    unit_cost    NUMERIC(8,2)
);

-- 6) inventory_daily : one row per store, SKU and day
CREATE TABLE inventory_daily (
    stock_date     DATE,
    store_id       INT REFERENCES dark_stores(store_id),
    sku_id         INT REFERENCES products(sku_id),
    units_stocked  INT,                      -- units on shelf at start of day
    units_sold     INT,
    units_wasted   INT,                      -- expired / damaged / thrown away
    stockout_hours INT,                      -- hours the item was unavailable (store open 18h)
    PRIMARY KEY (stock_date, store_id, sku_id)
);

-- 7) ad_campaigns : brand ads shown inside the app
CREATE TABLE ad_campaigns (
    campaign_id   INT PRIMARY KEY,
    company       VARCHAR(30),
    ad_type       VARCHAR(10),               -- 'Search' or 'Banner'
    campaign_name VARCHAR(60),
    start_date    DATE,
    end_date      DATE
);

-- 8) ad_daily : daily ad results per campaign and city
CREATE TABLE ad_daily (
    campaign_id INT REFERENCES ad_campaigns(campaign_id),
    ad_date     DATE,
    city        VARCHAR(30),
    impressions INT,
    clicks      INT,
    spend       NUMERIC(10,2),
    ad_orders   INT,
    ad_sales    NUMERIC(12,2),               -- sales the platform attributes to the ad
    PRIMARY KEY (campaign_id, ad_date, city)
);

-- Indexes make joins and date filters fast
CREATE INDEX idx_orders_store_ts  ON orders (store_id, order_ts);
CREATE INDEX idx_orders_customer  ON orders (customer_id);
CREATE INDEX idx_items_order      ON order_items (order_id);
CREATE INDEX idx_items_sku        ON order_items (sku_id);
CREATE INDEX idx_inv_store_sku    ON inventory_daily (store_id, sku_id);
