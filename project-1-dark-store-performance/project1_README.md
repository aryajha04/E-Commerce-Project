# Project 1: Dark Store Performance & Availability

**Question:** Which dark stores deliver fast, stay in stock and waste little - and where is money being lost?
**File:** `analysis.sql` (7 queries) | **Data:** simulated, 55,316 orders, GMV about Rs 2.55 Cr over 9 weeks

## What each query answers
| Query | Question | Key technique |
|---|---|---|
| Q1 | Daily orders, GMV, AOV and cancel % by city | `FILTER`, `GROUP BY` |
| Q2 | Share of orders delivered in 10 min, by store | CTE, `PERCENTILE_CONT` |
| Q3 | Which hours slow delivery down? | `EXTRACT(HOUR ...)` |
| Q4 | Money lost to wastage and stock-outs, by category | CTE chain, estimate logic |
| Q5 | ABC class of each SKU | running `SUM() OVER` |
| Q6 | Store scorecard and rank inside each city | `PERCENT_RANK`, `RANK ... PARTITION BY`, `NTILE` |
| Q7 | Weekly GMV and growth vs last week | `LAG`, `DATE_TRUNC` |

## What the (simulated) data shows
- **Speed gap between stores is large.** Best store delivers 71.9% of orders within 10 min; the weakest about 20%.
- **Peak hours hurt.** In 8-9 am and 7-10 pm only about 38% of orders arrive in 10 min, against about 55% at other hours.
- **Wastage is a fresh-food problem.** Dairy & Bakery (8.0% of sales) and Fruits & Vegetables (10.6%) are about 90% of all wastage cost.
  Other categories waste under 1%.
- **Stock-outs cost less than wastage** in this data: about Rs 1.1 lakh of estimated lost margin vs about Rs 7.4 lakh of wastage cost.
- **23 of 60 SKUs (38%) create 70% of sales** (class A) - these are the items that must never go out of stock.
- GMV grew from Rs 24.0 lakh in week 1 to Rs 32.8 lakh in week 9.

## Recommendation a manager could act on
1. Add riders / pick staff in the 8-9 am and 7-10 pm windows; target 10-min delivery above 55% at peak.
2. Cut fresh-food order quantity in the stores with the highest wastage; track wastage % weekly.
3. Fix the bottom-quartile stores first (scorecard Q6, quartile 4) - they drag city averages.
