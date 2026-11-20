-- Run from the repo's 00_setup folder with:  psql -d quickcommerce -f load_data.sql
\copy dark_stores      FROM '../data/dark_stores.csv'      CSV HEADER
\copy products         FROM '../data/products.csv'         CSV HEADER
\copy customers        FROM '../data/customers.csv'        CSV HEADER
\copy orders           FROM '../data/orders.csv'           CSV HEADER
\copy order_items      FROM '../data/order_items.csv'      CSV HEADER
\copy inventory_daily  FROM '../data/inventory_daily.csv'  CSV HEADER
\copy ad_campaigns     FROM '../data/ad_campaigns.csv'     CSV HEADER
\copy ad_daily         FROM '../data/ad_daily.csv'         CSV HEADER
-- Quick check: row counts
SELECT 'orders' AS tbl, COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'inventory_daily', COUNT(*) FROM inventory_daily;
