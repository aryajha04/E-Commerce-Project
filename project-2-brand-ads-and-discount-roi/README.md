# Project 2: Brand Ads, Discounts & First-Order Offers

**Question:** Which ads, discounts and offers actually create profit - for the platform and for FMCG brands?
**File:** `analysis.sql` (7 queries) | **Data:** simulated

## What each query answers
| Query | Question | Key technique |
|---|---|---|
| Q1 | ROAS, CTR, CPC, CPA by company and ad type | ratio metrics, `NULLIF` |
| Q2 | How much of each company's sales is ad-supported? | two CTEs joined |
| Q3 | Own label vs big FMCG: share and margin by category | `SUM() OVER (PARTITION BY ...)` |
| Q4 | Do discounts pay? Units vs margin by discount depth | CTE, `CASE` bands, baseline index |
| Q5 / Q5b | Did the Reckitt Dettol search-ad pilot lift sales? | difference-in-differences (test vs control cities) |
| Q6 | Does Rs 100 off the first order build loyal customers? | `ROW_NUMBER`, cohort window |

## What the (simulated) data shows
- **Search ads beat banner ads on return:** ROAS about 4.9-6.5 for search vs about 1.9-3.1 for banners. Banners are cheaper per order (about Rs 30-60 vs Rs 120-420) but return less sales per rupee spent.
- **Ads support about a quarter of every brand's sales** (attributed sales 25-28% of total).
- **Own label earns much more margin:** for example Home Care 43.2% vs 16.2% for big brands; but own label is under 10% of Home Care and Personal Care sales - room to grow.
- **Discounts have a sweet spot.** 5-10% off gives 1.42x units at nearly the same margin per baseline unit (Rs 35.6 vs Rs 34.0).
  15-20% gives 2.33x units but margin per unit drops to Rs 16.7. 25% loses money (-2.7% margin).
- **Reckitt search pilot (test vs control cities):** Reckitt's share of sales rose 2.99 points (17.3% relative lift)
  after removing the trend seen in control cities; about Rs 1.1 lakh incremental sales on Rs 19,300 spend (incremental ROAS about 5.8).
- **First-order offer attracts less loyal buyers:** repeat within 30 days 83.8% (offer) vs 88.7% (no offer);
  30-day spend per customer Rs 1,576 vs Rs 1,937.

## Caution
- The pilot and offer groups are simulated. In real life, offer groups should be randomly assigned; if not, the
  comparison can be biased (selection bias).
- Ad-attributed sales come from the platform's own tracking and can over-count. The pilot test (Q5) is the cleaner proof of real lift.
