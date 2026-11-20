# Quick-Commerce Commercial Analytics (SQL, PostgreSQL)

**Live project page (charts + every query and its output):** https://claude.ai/artifact/QAUuJS9byNAkb8b2qtCwue

By Arya Jha, MBA 2025-27, Department of Management Studies, IIT Delhi.

Two SQL projects on a **simulated** dark-store (10-minute delivery) business, built to show how I turn
raw order, stock and ad data into business decisions.

| Project | Business question | SQL skills |
|---|---|---|
| [1. Dark Store Performance & Availability](project-1-dark-store-performance/) | Which stores are fast, in stock and low on wastage? Where is money lost? | JOINs, CTEs, RANK, NTILE, PERCENT_RANK, LAG, running totals, percentiles |
| [2. Brand Ads, Discounts & First-Order Offers](project-2-brand-ads-and-discount-roi/) | Which ads, discounts and offers actually pay back? | CTEs, FILTER, CASE bands, cohort retention, difference-in-differences test |

## Proof of output
Each project folder has a `results/` folder with the real output of every query
(one CSV per query, plus `RESULTS.md` to read them on GitHub):
- [Project 1 results](project-1-dark-store-performance/results/RESULTS.md)
- [Project 2 results](project-2-brand-ads-and-discount-roi/results/RESULTS.md)

## The data (please read)
- **Simulated, not real.** No company data is used. `00_setup/generate_data.py` creates it with a fixed random seed.
- Scale: 42 dark stores in 5 cities, 60 SKUs, 9,000 customers, 55,316 orders, 185,204 order lines,
  158,760 store-SKU-day stock rows, 20 ad campaigns, 9 weeks (31 Aug - 1 Nov 2026).
- Some patterns (for example "deeper discounts lift units" and "the Reckitt search-ad pilot lifts share")
  are built into the generator on purpose, so each analysis has something real to find.
  The skill on display is the **method**, not the numbers.

## How to run (15 minutes)
1. Install PostgreSQL 14+ (or use a free hosted one such as Supabase / Neon).
2. `createdb quickcommerce`
3. `cd 00_setup`
4. `psql -d quickcommerce -f schema.sql`
5. `psql -d quickcommerce -f load_data.sql`   (loads the CSVs in `data/`)
6. Open `project-1-.../analysis.sql` or `project-2-.../analysis.sql` and run each query one by one.

To rebuild the data from scratch: `python3 00_setup/generate_data.py` (needs numpy and pandas).

## MySQL version
The `mysql/` folder has the same project for MySQL 8.0+ (tested on MySQL 8.0):
`01_create_database.sql`, `02_create_tables.sql`, `03_load_data.sql` (replace PATH_TO_FOLDER with your folder path),
`04_project1_dark_stores.sql`, `05_project2_ads_discounts.sql`.
Step-by-step guide: https://claude.ai/artifact/8LfCitDnhzMpdbhv3rsufD

## Tables
`dark_stores` - `products` - `customers` - `orders` - `order_items` - `inventory_daily` - `ad_campaigns` - `ad_daily`
(see comments inside `00_setup/schema.sql`).

