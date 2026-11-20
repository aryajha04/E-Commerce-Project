# Quick-Commerce Commercial Analytics (SQL)

By **Arya Jha**, MBA 2025-27, Department of Management Studies, IIT Delhi.

Two SQL projects on a **simulated** dark-store (10-minute delivery) business, built to show how I turn
raw order, stock and ad data into business decisions. Runs on **MySQL 8** and **PostgreSQL 14+**.

| Project | Business question | SQL skills |
|---|---|---|
| [1. Dark Store Performance & Availability](project-1-dark-store-performance/) | Which stores are fast, in stock and low on wastage? Where is money lost? | JOINs, CTEs, RANK, NTILE, PERCENT_RANK, LAG, running totals, percentiles |
| [2. Brand Ads, Discounts & First-Order Offers](project-2-brand-ads-and-discount-roi/) | Which ads, discounts and offers actually pay back? | CTEs, CASE bands, cohort retention, difference-in-differences test |

## Key findings (simulated data)
- Peak hours (8-9 am, 7-10 pm) cut 10-minute delivery from about 56% to 38% of orders.
- Fresh food (dairy, fruits & vegetables) causes about 90% of wastage cost.
- 23 of 60 SKUs make 70% of sales (ABC analysis).
- Search ads return about 2x what banner ads return (ROAS 4.9-6.5 vs 1.9-3.1).
- 5-10% discounts lift units 1.4x at steady margin; 25% discounts lose money.
- A test vs control (difference-in-differences) read of a search-ad pilot shows a 2.99-point share lift.

## Proof of output
Each project folder has a `results/` folder with the real output of every query
(one CSV per query, plus `RESULTS.md` to read them on GitHub):
- [Project 1 results](project-1-dark-store-performance/results/RESULTS.md)
- [Project 2 results](project-2-brand-ads-and-discount-roi/results/RESULTS.md)

## How to run
**MySQL 8 (Workbench):** run the files in `mysql/` in order:
`01_create_database.sql` → `02_create_tables.sql` → `03_load_data.sql` (replace `PATH_TO_FOLDER` with your folder path) →
`04_project1_dark_stores.sql` → `05_project2_ads_discounts.sql`.

**PostgreSQL 14+:** `createdb quickcommerce`, then in `00_setup/` run `psql -d quickcommerce -f schema.sql` and
`psql -d quickcommerce -f load_data.sql`, then the `analysis.sql` file in each project folder.

## The data (please read)
- **Simulated, not real.** No company data is used. `00_setup/generate_data.py` creates it with a fixed random seed.
- Scale: 42 dark stores in 5 cities, 60 SKUs, 9,000 customers, 55,316 orders, 185,204 order lines,
  158,760 store-SKU-day stock rows, 20 ad campaigns, 9 weeks (31 Aug - 1 Nov 2026).
- Some patterns (for example "deeper discounts lift units" and "the search-ad pilot lifts share")
  are built into the generator on purpose, so each analysis has something to find.
  The skill on display is the **method**, not the numbers.

## Tables
`dark_stores` · `products` · `customers` · `orders` · `order_items` · `inventory_daily` · `ad_campaigns` · `ad_daily`
(see comments inside `mysql/02_create_tables.sql` or `00_setup/schema.sql`).

## Tools
SQL (MySQL 8, PostgreSQL 16) · Python (pandas, NumPy) for data generation · GitHub
