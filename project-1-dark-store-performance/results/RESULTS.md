# Query results (project-1-dark-store-performance)

Every table below is the real output of `analysis.sql` run on PostgreSQL 16 against the simulated data in `data/`. Long tables show the first rows; the full output is in the CSV file.


## Q1. Daily health of the business, by city

Rows returned: 315 | Full output: [`results/q1_daily_health_of_the_business_by_city.csv`](q1_daily_health_of_the_business_by_city.csv)

| city | order_date | orders | delivered_orders | gmv_inr | aov_inr | cancel_pct |
|---|---|---|---|---|---|---|
| Bengaluru | 2026-08-31 | 136 | 133 | 64249 | 483 | 2.21 |
| Delhi NCR | 2026-08-31 | 240 | 238 | 119310 | 501 | 0.83 |
| Hyderabad | 2026-08-31 | 55 | 54 | 25532 | 473 | 1.82 |
| Mumbai | 2026-08-31 | 171 | 169 | 81072 | 480 | 1.17 |
| Pune | 2026-08-31 | 59 | 59 | 26630 | 451 | 0.00 |
| Bengaluru | 2026-09-01 | 134 | 131 | 63698 | 486 | 2.24 |
| Delhi NCR | 2026-09-01 | 220 | 216 | 104356 | 483 | 1.82 |
| Hyderabad | 2026-09-01 | 65 | 64 | 31676 | 495 | 1.54 |
| Mumbai | 2026-09-01 | 162 | 159 | 73193 | 460 | 1.85 |
| Pune | 2026-09-01 | 55 | 52 | 24559 | 472 | 5.45 |
| Bengaluru | 2026-09-02 | 138 | 132 | 61491 | 466 | 4.35 |
| Delhi NCR | 2026-09-02 | 202 | 200 | 104422 | 522 | 0.99 |
| Hyderabad | 2026-09-02 | 62 | 60 | 28720 | 479 | 3.23 |
| Mumbai | 2026-09-02 | 173 | 168 | 77606 | 462 | 2.89 |
| Pune | 2026-09-02 | 49 | 48 | 21536 | 449 | 2.04 |

_... 300 more rows in the CSV._

## Q2. Delivery speed by store: share of orders delivered within 10 minutes

Rows returned: 42 | Full output: [`results/q2_delivery_speed_by_store_share_of_orders_.csv`](q2_delivery_speed_by_store_share_of_orders_.csv)

| store_name | city | delivered_orders | pct_within_10_min | median_min | p90_min |
|---|---|---|---|---|---|
| DS-DEL-06 | Delhi NCR | 1346 | 71.9 | 8.2 | 12.7 |
| DS-MUM-10 | Mumbai | 1402 | 71.3 | 8.2 | 12.4 |
| DS-HYD-03 | Hyderabad | 935 | 71.1 | 8.4 | 12.8 |
| DS-DEL-12 | Delhi NCR | 1449 | 69.7 | 8.3 | 13.0 |
| DS-BEN-01 | Bengaluru | 1098 | 69.2 | 8.4 | 13.3 |
| DS-HYD-04 | Hyderabad | 1143 | 67.2 | 8.7 | 13.5 |
| DS-BEN-06 | Bengaluru | 1219 | 65.5 | 8.7 | 13.5 |
| DS-BEN-04 | Bengaluru | 1136 | 62.9 | 8.8 | 13.7 |
| DS-DEL-08 | Delhi NCR | 1636 | 62.2 | 9.1 | 13.9 |
| DS-MUM-09 | Mumbai | 1503 | 61.4 | 9.0 | 13.7 |
| DS-PUN-03 | Pune | 860 | 61.4 | 9.1 | 13.8 |
| DS-DEL-11 | Delhi NCR | 1533 | 61.3 | 9.1 | 14.2 |
| DS-MUM-02 | Mumbai | 1557 | 57.0 | 9.5 | 14.9 |
| DS-BEN-10 | Bengaluru | 1232 | 56.1 | 9.5 | 14.4 |
| DS-MUM-01 | Mumbai | 1398 | 55.7 | 9.4 | 14.1 |

_... 27 more rows in the CSV._

## Q3. Which hours slow us down? (peak-hour pressure)

Rows returned: 18 | Full output: [`results/q3_which_hours_slow_us_down_peak_hour_press.csv`](q3_which_hours_slow_us_down_peak_hour_press.csv)

| hour_of_day | orders | avg_delivery_min | pct_within_10_min |
|---|---|---|---|
| 6 | 1339 | 10.3 | 55.2 |
| 7 | 2437 | 10.3 | 54.5 |
| 8 | 3795 | 11.9 | 37.2 |
| 9 | 3602 | 11.9 | 38.3 |
| 10 | 2560 | 10.0 | 57.6 |
| 11 | 2284 | 10.3 | 56.0 |
| 12 | 2296 | 10.1 | 56.5 |
| 13 | 2493 | 10.2 | 54.8 |
| 14 | 2270 | 10.1 | 54.4 |
| 15 | 2117 | 10.1 | 56.1 |
| 16 | 2487 | 10.1 | 55.9 |
| 17 | 3227 | 10.1 | 56.1 |
| 18 | 4609 | 10.2 | 54.7 |
| 19 | 5505 | 11.9 | 38.2 |
| 20 | 5360 | 11.8 | 38.8 |

_... 3 more rows in the CSV._

## Q4. Money lost to WASTAGE and STOCK-OUTS, by category

Rows returned: 7 | Full output: [`results/q4_money_lost_to_wastage_and_stock_outs_by_.csv`](q4_money_lost_to_wastage_and_stock_outs_by_.csv)

| category | wastage_cost_inr | lost_margin_from_stockouts_inr | wastage_pct_of_sales | stockout_loss_pct_of_sales |
|---|---|---|---|---|
| Dairy & Bakery | 472982 | 22345 | 7.98 | 0.38 |
| Fruits & Vegetables | 195204 | 14751 | 10.64 | 0.80 |
| Packaged Food | 28147 | 20492 | 0.47 | 0.34 |
| Personal Care | 15799 | 22700 | 0.30 | 0.43 |
| Home Care | 16366 | 17832 | 0.31 | 0.34 |
| Beverages | 11059 | 7924 | 0.55 | 0.40 |
| Snacks | 2215 | 2901 | 0.36 | 0.48 |

## Q5. ABC classification of SKUs (which items really make the money)

Rows returned: 60 | Full output: [`results/q5_abc_classification_of_skus_which_items_r.csv`](q5_abc_classification_of_skus_which_items_r.csv)

| product_name | category | brand_type | sales_inr | cumulative_pct | abc_class |
|---|---|---|---|---|---|
| Britannia Bread 400g | Dairy & Bakery | Big FMCG | 1798465 | 7.0 | A |
| Dettol Soap 3x125g | Personal Care | Big FMCG | 1270800 | 12.0 | A |
| Amul Taaza Milk 1L | Dairy & Bakery | Big FMCG | 1196188 | 16.7 | A |
| Surf Excel Detergent 1kg | Home Care | Big FMCG | 1081987 | 20.9 | A |
| Apple 4 pcs | Fruits & Vegetables | Own label | 972216 | 24.7 | A |
| Amul Cheese Slices 200g | Dairy & Bakery | Big FMCG | 956846 | 28.5 | A |
| Dettol Liquid Handwash 200ml | Personal Care | Big FMCG | 934689 | 32.1 | A |
| Head & Shoulders Shampoo 340ml | Personal Care | Big FMCG | 791260 | 35.2 | A |
| Aashirvaad Atta 5kg | Packaged Food | Big FMCG | 682789 | 37.9 | A |
| Tide Detergent 1kg | Home Care | Big FMCG | 678150 | 40.6 | A |
| Real Fruit Juice 1L | Beverages | Big FMCG | 678103 | 43.2 | A |
| Saffola Gold Oil 1L | Packaged Food | Big FMCG | 661962 | 45.8 | A |
| Lizol Floor Cleaner 975ml | Home Care | Big FMCG | 650268 | 48.4 | A |
| Ariel Detergent 2kg | Home Care | Big FMCG | 649532 | 50.9 | A |
| Amul Paneer 200g | Dairy & Bakery | Big FMCG | 570328 | 53.1 | A |

_... 45 more rows in the CSV._

## Q6. STORE SCORECARD (the main deliverable)

Rows returned: 42 | Full output: [`results/q6_store_scorecard_the_main_deliverable.csv`](q6_store_scorecard_the_main_deliverable.csv)

| store_name | city | pct_within_10_min | stockout_pct | wastage_pct | gmv_inr | score | rank_in_city | quartile |
|---|---|---|---|---|---|---|---|---|
| DS-DEL-06 | Delhi NCR | 71.9 | 1.3 | 1.93 | 619401 | 85.4 | 1 | 1 |
| DS-MUM-10 | Mumbai | 71.3 | 1.1 | 2.46 | 655585 | 84.6 | 1 | 1 |
| DS-DEL-08 | Delhi NCR | 62.2 | 1.5 | 1.63 | 771396 | 80.0 | 2 | 1 |
| DS-BEN-04 | Bengaluru | 62.9 | 1.1 | 2.14 | 524825 | 79.3 | 1 | 1 |
| DS-HYD-04 | Hyderabad | 67.2 | 1.2 | 2.69 | 534063 | 74.4 | 1 | 1 |
| DS-MUM-09 | Mumbai | 61.4 | 1.2 | 3.55 | 707716 | 70.7 | 2 | 1 |
| DS-HYD-03 | Hyderabad | 71.1 | 1.0 | 3.78 | 433401 | 70.7 | 2 | 1 |
| DS-MUM-02 | Mumbai | 57.0 | 1.6 | 1.67 | 718369 | 70.2 | 3 | 1 |
| DS-BEN-06 | Bengaluru | 65.5 | 1.6 | 1.93 | 586044 | 69.8 | 2 | 1 |
| DS-BEN-01 | Bengaluru | 69.2 | 1.0 | 4.30 | 539476 | 69.5 | 3 | 1 |
| DS-DEL-12 | Delhi NCR | 69.7 | 1.5 | 3.30 | 669988 | 69.0 | 3 | 1 |
| DS-PUN-03 | Pune | 61.4 | 1.3 | 2.34 | 424713 | 67.8 | 1 | 2 |
| DS-DEL-07 | Delhi NCR | 49.7 | 1.2 | 2.97 | 654331 | 63.4 | 4 | 2 |
| DS-DEL-03 | Delhi NCR | 42.2 | 1.6 | 1.54 | 690760 | 61.2 | 5 | 2 |
| DS-MUM-07 | Mumbai | 49.8 | 1.6 | 2.28 | 794131 | 60.2 | 4 | 2 |

_... 27 more rows in the CSV._

## Q7. Weekly GMV and growth vs last week (LAG)

Rows returned: 9 | Full output: [`results/q7_weekly_gmv_and_growth_vs_last_week_lag.csv`](q7_weekly_gmv_and_growth_vs_last_week_lag.csv)

| week_start | gmv_inr | wow_growth_pct |
|---|---|---|
| 2026-08-31 | 2400097 |  |
| 2026-09-07 | 2333328 | -2.8 |
| 2026-09-14 | 2617792 | 12.2 |
| 2026-09-21 | 2696386 | 3.0 |
| 2026-09-28 | 2679061 | -0.6 |
| 2026-10-05 | 3001412 | 12.0 |
| 2026-10-12 | 3265197 | 8.8 |
| 2026-10-19 | 3271249 | 0.2 |
| 2026-10-26 | 3283904 | 0.4 |
