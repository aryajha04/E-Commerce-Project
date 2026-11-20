# Query results (project-2-brand-ads-and-discount-roi)

Every table below is the real output of `analysis.sql` run on PostgreSQL 16 against the simulated data in `data/`. Long tables show the first rows; the full output is in the CSV file.


## Q1. Ad report card by company and ad type

Rows returned: 20 | Full output: [`results/q1_ad_report_card_by_company_and_ad_type.csv`](q1_ad_report_card_by_company_and_ad_type.csv)

| company | ad_type | spend_inr | impressions | clicks | ctr_pct | cpc_inr | cpa_inr | roas |
|---|---|---|---|---|---|---|---|---|
| Nestle India | Search | 20794.54 | 88694 | 2832 | 3.19 | 7.34 | 162.5 | 6.54 |
| Reckitt | Search | 126717.86 | 302281 | 12313 | 4.07 | 10.29 | 134.4 | 6.47 |
| Dabur | Search | 42006.44 | 114409 | 3934 | 3.44 | 10.68 | 199.1 | 6.26 |
| Marico | Search | 24849.35 | 47206 | 2025 | 4.29 | 12.27 | 421.2 | 6.08 |
| Tata Consumer | Search | 27945.16 | 43501 | 2175 | 5.00 | 12.85 | 405.0 | 5.59 |
| HUL | Search | 72654.11 | 168912 | 5649 | 3.34 | 12.86 | 208.2 | 5.52 |
| P&G | Search | 63397.97 | 128847 | 4852 | 3.77 | 13.07 | 221.7 | 5.24 |
| Britannia | Search | 80599.92 | 184467 | 7668 | 4.16 | 10.51 | 148.7 | 5.21 |
| PepsiCo | Search | 4506.60 | 6148 | 306 | 4.98 | 14.73 |  | 5.04 |
| ITC | Search | 33194.74 | 126258 | 4812 | 3.81 | 6.90 | 118.1 | 4.94 |
| Tata Consumer | Banner | 29637.17 | 1010766 | 11003 | 1.09 | 2.69 | 35.3 | 3.12 |
| Marico | Banner | 29318.31 | 1168545 | 7550 | 0.65 | 3.88 | 55.0 | 3.05 |
| Reckitt | Banner | 140176.95 | 4490765 | 51664 | 1.15 | 2.71 | 31.9 | 3.02 |
| Britannia | Banner | 98478.42 | 6283747 | 38616 | 0.61 | 2.55 | 29.4 | 2.63 |
| HUL | Banner | 97480.30 | 2932719 | 24663 | 0.84 | 3.95 | 46.9 | 2.56 |

_... 5 more rows in the CSV._

## Q2. How much of each company's sales is supported by ads?

Rows returned: 10 | Full output: [`results/q2_how_much_of_each_company_s_sales_is_supp.csv`](q2_how_much_of_each_company_s_sales_is_supp.csv)

| company | total_sales_inr | ad_spend_inr | ad_spend_pct_of_sales | ad_attributed_pct_of_sales |
|---|---|---|---|---|
| ITC | 1026463 | 86818 | 8.5 | 25.7 |
| P&G | 2118942 | 156300 | 7.4 | 25.4 |
| PepsiCo | 141780 | 9916 | 7.0 | 25.7 |
| Britannia | 2702950 | 179078 | 6.6 | 25.1 |
| HUL | 2587424 | 170134 | 6.6 | 25.1 |
| Dabur | 1563050 | 102262 | 6.5 | 26.3 |
| Nestle India | 852007 | 54064 | 6.3 | 25.4 |
| Reckitt | 4394228 | 266895 | 6.1 | 28.3 |
| Tata Consumer | 958305 | 57582 | 6.0 | 25.9 |
| Marico | 938468 | 54168 | 5.8 | 25.6 |

## Q3. Own label vs big FMCG brands: share and margin, by category

Rows returned: 13 | Full output: [`results/q3_own_label_vs_big_fmcg_brands_share_and_m.csv`](q3_own_label_vs_big_fmcg_brands_share_and_m.csv)

| category | brand_type | sales_inr | share_of_category_pct | margin_pct |
|---|---|---|---|---|
| Beverages | Big FMCG | 1549474 | 80.8 | 18.5 |
| Beverages | Own label | 368668 | 19.2 | 32.9 |
| Dairy & Bakery | Big FMCG | 5053077 | 87.7 | 13.7 |
| Dairy & Bakery | Own label | 706713 | 12.3 | 20.4 |
| Fruits & Vegetables | Own label | 1812247 | 100.0 | 35.2 |
| Home Care | Big FMCG | 4416831 | 91.3 | 16.2 |
| Home Care | Own label | 419164 | 8.7 | 43.2 |
| Packaged Food | Big FMCG | 4444344 | 78.9 | 16.2 |
| Packaged Food | Own label | 1189355 | 21.1 | 26.3 |
| Personal Care | Big FMCG | 4889389 | 97.9 | 17.9 |
| Personal Care | Own label | 107314 | 2.1 | 43.7 |
| Snacks | Big FMCG | 375442 | 63.4 | 22.0 |
| Snacks | Own label | 216410 | 36.6 | 38.3 |

## Q4. Do discounts pay? Units, sales and margin by discount depth

Rows returned: 4 | Full output: [`results/q4_do_discounts_pay_units_sales_and_margin_.csv`](q4_do_discounts_pay_units_sales_and_margin_.csv)

| discount_band | sku_weeks | units_index_vs_no_discount | margin_pct | margin_inr_per_baseline_unit |
|---|---|---|---|---|
| 0. No discount | 396 | 1.00 | 26.0 | 34.0 |
| 1. 5-10% | 90 | 1.42 | 20.7 | 35.6 |
| 2. 15-20% | 49 | 2.33 | 5.8 | 16.7 |
| 3. 25% | 5 | 3.20 | -2.7 | -16.0 |

## Q5. A/B-style test: did the Reckitt Dettol Search pilot lift sales?

Rows returned: 4 | Full output: [`results/q5_a_b_style_test_did_the_reckitt_dettol_se.csv`](q5_a_b_style_test_did_the_reckitt_dettol_se.csv)

| grp | period | reckitt_share_pct | reckitt_sales_per_week |
|---|---|---|---|
| Control | During pilot | 15.63 | 331921 |
| Control | Before | 17.06 | 302390 |
| Test | During pilot | 18.80 | 175011 |
| Test | Before | 17.24 | 127512 |

## Q5b. The lift itself and the return on pilot spend

Rows returned: 1 | Full output: [`results/q5b_the_lift_itself_and_the_return_on_pilot_.csv`](q5b_the_lift_itself_and_the_return_on_pilot_.csv)

| share_lift_pct_points | relative_lift_pct | incremental_sales_inr | pilot_spend_inr | incremental_roas |
|---|---|---|---|---|
| 2.99 | 17.3 | 111304 | 19312 | 5.8 |

## Q6. First-order offer: does a Rs 100 off first order buy loyal customers?

Rows returned: 2 | Full output: [`results/q6_first_order_offer_does_a_rs_100_off_firs.csv`](q6_first_order_offer_does_a_rs_100_off_firs.csv)

| offer_group | customers | avg_first_order_inr | repeat_within_30d_pct | repeat_orders_per_customer | spend_per_customer_30d_inr |
|---|---|---|---|---|---|
| first_order_offer | 1301 | 392 | 83.8 | 2.54 | 1576 |
| no_offer | 542 | 452 | 88.7 | 3.18 | 1937 |
