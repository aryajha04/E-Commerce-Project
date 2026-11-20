-- =====================================================================
-- STEP 3: load the 8 CSV files into the tables  |  MySQL 8.0+
-- BEFORE RUNNING: replace every PATH_TO_FOLDER with the full path of the
-- unzipped project folder, using FORWARD slashes, for example
--   C:/Users/Arya/Downloads/quick-commerce-sql-portfolio
-- (Workbench: Ctrl+H opens Find & Replace.)
-- Needs local_infile switched on: see the guide, step 3.
-- =====================================================================
USE quickcommerce;
SET GLOBAL local_infile = 1;
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/dark_stores.csv' INTO TABLE dark_stores
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/products.csv' INTO TABLE products
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
  (sku_id, product_name, category, brand, company, brand_type, mrp, unit_cost, shelf_life_days, @perish)
  SET is_perishable = (@perish = 'True');

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/customers.csv' INTO TABLE customers
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
  (customer_id, city, joined_date, acquisition_channel, @offer)
  SET offer_group = NULLIF(@offer, '');

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/orders.csv' INTO TABLE orders
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
  (order_id, customer_id, store_id, order_ts, @delivered, status, items_total, delivery_fee,
   order_discount, @promo, @first)
  SET delivered_ts   = NULLIF(@delivered, ''),
      promo_code     = NULLIF(@promo, ''),
      is_first_order = (@first = 'True');

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/order_items.csv' INTO TABLE order_items
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
  (item_id, order_id, sku_id, quantity, discount_pct, unit_price, unit_cost);

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/inventory_daily.csv' INTO TABLE inventory_daily
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/ad_campaigns.csv' INTO TABLE ad_campaigns
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'PATH_TO_FOLDER/data/ad_daily.csv' INTO TABLE ad_daily
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

SET FOREIGN_KEY_CHECKS = 1;

-- Check: these counts must match exactly
SELECT 'dark_stores' AS table_name, COUNT(*) AS row_count FROM dark_stores UNION ALL
SELECT 'products',        COUNT(*) FROM products        UNION ALL
SELECT 'customers',       COUNT(*) FROM customers       UNION ALL
SELECT 'orders',          COUNT(*) FROM orders          UNION ALL
SELECT 'order_items',     COUNT(*) FROM order_items     UNION ALL
SELECT 'inventory_daily', COUNT(*) FROM inventory_daily UNION ALL
SELECT 'ad_campaigns',    COUNT(*) FROM ad_campaigns    UNION ALL
SELECT 'ad_daily',        COUNT(*) FROM ad_daily;
