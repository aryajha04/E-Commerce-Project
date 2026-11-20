"""
Generates SIMULATED quick-commerce data (dark stores, SKUs, orders, stock, ads).
No real company data is used. Brand names are only labels for realism.
Run:  python3 generate_data.py   ->  writes CSV files into ../data/
Fixed random seed, so everyone gets the same data.
"""
import numpy as np, pandas as pd, os, math

rng = np.random.default_rng(42)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")
os.makedirs(OUT, exist_ok=True)

START = pd.Timestamp("2026-08-31")          # a Monday
DAYS = 63                                   # 9 full weeks
WEEKS = DAYS // 7
PILOT_WEEKS = range(4, 8)                   # weeks 5-8 (0-indexed 4..7)
TEST_CITIES = ["Bengaluru", "Pune"]         # Reckitt search-ad pilot cities

# ---------------------------------------------------------------- stores
city_stores = {"Delhi NCR": 12, "Mumbai": 10, "Bengaluru": 10, "Hyderabad": 5, "Pune": 5}
areas = {
 "Delhi NCR": ["Sector 65 Gurugram", "Saket", "Dwarka", "Noida Sec 62", "Rohini", "Lajpat Nagar",
               "Vasant Kunj", "Indirapuram", "Golf Course Rd", "Janakpuri", "Mayur Vihar", "Sohna Rd"],
 "Mumbai": ["Andheri West", "Bandra", "Powai", "Thane", "Borivali", "Worli", "Malad", "Navi Mumbai",
            "Chembur", "Goregaon"],
 "Bengaluru": ["Koramangala", "Indiranagar", "HSR Layout", "Whitefield", "Jayanagar", "Marathahalli",
               "Electronic City", "Hebbal", "BTM Layout", "Yelahanka"],
 "Hyderabad": ["Gachibowli", "Madhapur", "Banjara Hills", "Kondapur", "Kukatpally"],
 "Pune": ["Kothrud", "Viman Nagar", "Hinjewadi", "Baner", "Magarpatta"],
}
stores = []
sid = 1
for c, n in city_stores.items():
    for i in range(n):
        stores.append(dict(
            store_id=sid, store_name=f"DS-{c.split()[0][:3].upper()}-{i+1:02d}", city=c, area=areas[c][i],
            opened_date=(pd.Timestamp("2024-01-01") + pd.Timedelta(days=int(rng.integers(0, 800)))).date(),
            size_sqft=int(rng.choice([2500, 3000, 3500, 4000, 4500], p=[.15, .3, .3, .15, .1])),
        ))
        sid += 1
stores = pd.DataFrame(stores)
NS = len(stores)
# hidden quality factors (not exported): speed, stock, waste
speed_f = rng.uniform(0.82, 1.35, NS)
stock_f = np.clip(speed_f * rng.uniform(0.7, 1.3, NS), 0.5, 2.0)
waste_f = rng.uniform(0.6, 1.7, NS)
stores["_speed"], stores["_stock"], stores["_waste"] = speed_f, stock_f, waste_f

# ---------------------------------------------------------------- products
# name, category, brand, company, type, mrp, cost_pct, perishable(shelf days or 0)
P = [
 ("Dove Soap 3x100g","Personal Care","Dove","HUL","Big FMCG",165,.77,0),
 ("Lifebuoy Handwash 190ml","Personal Care","Lifebuoy","HUL","Big FMCG",99,.76,0),
 ("Clinic Plus Shampoo 340ml","Personal Care","Clinic Plus","HUL","Big FMCG",210,.75,0),
 ("Dettol Soap 3x125g","Personal Care","Dettol","Reckitt","Big FMCG",150,.77,0),
 ("Dettol Liquid Handwash 200ml","Personal Care","Dettol","Reckitt","Big FMCG",99,.76,0),
 ("Dettol Antiseptic Liquid 250ml","Personal Care","Dettol","Reckitt","Big FMCG",150,.78,0),
 ("Dabur Red Toothpaste 200g","Personal Care","Dabur","Dabur","Big FMCG",125,.76,0),
 ("Head & Shoulders Shampoo 340ml","Personal Care","Head & Shoulders","P&G","Big FMCG",355,.77,0),
 ("Parachute Coconut Oil 500ml","Personal Care","Parachute","Marico","Big FMCG",230,.78,0),
 ("Store Brand Handwash 250ml","Personal Care","Store Brand","Store Brand","Own label",79,.55,0),
 ("Surf Excel Detergent 1kg","Home Care","Surf Excel","HUL","Big FMCG",235,.77,0),
 ("Vim Dishwash Liquid 500ml","Home Care","Vim","HUL","Big FMCG",115,.76,0),
 ("Harpic Toilet Cleaner 500ml","Home Care","Harpic","Reckitt","Big FMCG",105,.77,0),
 ("Lizol Floor Cleaner 975ml","Home Care","Lizol","Reckitt","Big FMCG",215,.76,0),
 ("Colin Glass Cleaner 500ml","Home Care","Colin","Reckitt","Big FMCG",95,.77,0),
 ("Mortein Mosquito Spray 425ml","Home Care","Mortein","Reckitt","Big FMCG",199,.77,0),
 ("Ariel Detergent 2kg","Home Care","Ariel","P&G","Big FMCG",520,.78,0),
 ("Tide Detergent 1kg","Home Care","Tide","P&G","Big FMCG",125,.78,0),
 ("Store Brand Detergent 1kg","Home Care","Store Brand","Store Brand","Own label",109,.58,0),
 ("Store Brand Toilet Cleaner 500ml","Home Care","Store Brand","Store Brand","Own label",72,.55,0),
 ("Store Brand Floor Cleaner 1L","Home Care","Store Brand","Store Brand","Own label",129,.56,0),
 ("Maggi Noodles 12-pack","Packaged Food","Maggi","Nestle India","Big FMCG",168,.79,0),
 ("Nescafe Classic 50g","Packaged Food","Nescafe","Nestle India","Big FMCG",185,.78,0),
 ("KitKat 4-pack","Packaged Food","KitKat","Nestle India","Big FMCG",90,.77,0),
 ("Aashirvaad Atta 5kg","Packaged Food","Aashirvaad","ITC","Big FMCG",285,.8,0),
 ("Sunfeast Dark Fantasy 300g","Packaged Food","Sunfeast","ITC","Big FMCG",135,.76,0),
 ("Yippee Noodles 4-pack","Packaged Food","Yippee","ITC","Big FMCG",60,.77,0),
 ("Tata Salt 1kg","Packaged Food","Tata Salt","Tata Consumer","Big FMCG",28,.82,0),
 ("Tata Sampann Toor Dal 1kg","Packaged Food","Tata Sampann","Tata Consumer","Big FMCG",190,.82,0),
 ("Saffola Gold Oil 1L","Packaged Food","Saffola","Marico","Big FMCG",210,.8,0),
 ("Britannia Good Day 600g","Packaged Food","Good Day","Britannia","Big FMCG",120,.76,0),
 ("Britannia Marie Gold 500g","Packaged Food","Marie Gold","Britannia","Big FMCG",55,.77,0),
 ("Dabur Honey 250g","Packaged Food","Dabur","Dabur","Big FMCG",200,.77,0),
 ("Store Brand Atta 5kg","Packaged Food","Store Brand","Store Brand","Own label",245,.68,0),
 ("Store Brand Toor Dal 1kg","Packaged Food","Store Brand","Store Brand","Own label",165,.7,0),
 ("Store Brand Sunflower Oil 1L","Packaged Food","Store Brand","Store Brand","Own label",150,.76,0),
 ("Amul Taaza Milk 1L","Dairy & Bakery","Amul","Amul","Big FMCG",68,.9,3),
 ("Amul Dahi 400g","Dairy & Bakery","Amul","Amul","Big FMCG",45,.82,5),
 ("Amul Paneer 200g","Dairy & Bakery","Amul","Amul","Big FMCG",95,.82,6),
 ("Amul Butter 500g","Dairy & Bakery","Amul","Amul","Big FMCG",285,.86,90),
 ("Amul Cheese Slices 200g","Dairy & Bakery","Amul","Amul","Big FMCG",130,.84,90),
 ("Britannia Bread 400g","Dairy & Bakery","Britannia","Britannia","Big FMCG",50,.8,4),
 ("Store Brand Eggs 12","Dairy & Bakery","Store Brand","Store Brand","Own label",110,.8,10),
 ("Store Brand Curd 400g","Dairy & Bakery","Store Brand","Store Brand","Own label",40,.7,5),
 ("Red Label Tea 500g","Beverages","Red Label","HUL","Big FMCG",290,.78,0),
 ("Bru Instant Coffee 100g","Beverages","Bru","HUL","Big FMCG",330,.78,0),
 ("Tata Tea Gold 500g","Beverages","Tata Tea","Tata Consumer","Big FMCG",310,.79,0),
 ("Real Fruit Juice 1L","Beverages","Real","Dabur","Big FMCG",115,.77,0),
 ("Store Brand Tea 500g","Beverages","Store Brand","Store Brand","Own label",235,.66,0),
 ("Bingo Mad Angles 80g","Snacks","Bingo","ITC","Big FMCG",20,.76,0),
 ("Kurkure Masala Munch 90g","Snacks","Kurkure","PepsiCo","Big FMCG",20,.76,0),
 ("Lays Classic Salted 52g","Snacks","Lays","PepsiCo","Big FMCG",20,.76,0),
 ("Haldiram Bhujia 400g","Snacks","Haldiram","Haldiram's","Big FMCG",110,.75,0),
 ("Store Brand Namkeen 400g","Snacks","Store Brand","Store Brand","Own label",85,.6,0),
 ("Banana 1 dozen","Fruits & Vegetables","Store Brand","Store Brand","Own label",69,.62,3),
 ("Tomato 500g","Fruits & Vegetables","Store Brand","Store Brand","Own label",35,.6,3),
 ("Onion 1kg","Fruits & Vegetables","Store Brand","Store Brand","Own label",45,.65,10),
 ("Potato 1kg","Fruits & Vegetables","Store Brand","Store Brand","Own label",40,.65,10),
 ("Apple 4 pcs","Fruits & Vegetables","Store Brand","Store Brand","Own label",120,.66,6),
 ("Coriander Bunch","Fruits & Vegetables","Store Brand","Store Brand","Own label",15,.55,2),
]
prod = pd.DataFrame(P, columns=["product_name","category","brand","company","brand_type","mrp",
                                "cost_pct","shelf_life_days"])
prod.insert(0, "sku_id", np.arange(1, len(prod)+1))
prod["is_perishable"] = prod.shelf_life_days.between(1, 10)
prod["unit_cost"] = (prod.mrp * prod.cost_pct).round(2)
NP = len(prod)
# popularity: staples & perishables sell more
pop = rng.lognormal(0, .7, NP)
pop[prod.is_perishable.values] *= 2.2
pop[prod.category.isin(["Snacks"]).values] *= 1.4
pop[(prod.mrp > 250).values] *= .45
# realism tweaks: everyday staples sell most; premium / seasonal items sell less
tweak = {"Amul Taaza Milk 1L": 3.0, "Banana 1 dozen": 1.8, "Britannia Bread 400g": 1.6, "Store Brand Eggs 12": 1.6,
         "Tomato 500g": 1.4, "Onion 1kg": 1.4, "Apple 4 pcs": .35, "Mortein Mosquito Spray 425ml": .3,
         "Amul Cheese Slices 200g": .5, "Head & Shoulders Shampoo 340ml": .6, "Saffola Gold Oil 1L": .6,
         "Maggi Noodles 12-pack": 1.8, "Lays Classic Salted 52g": 1.8, "Kurkure Masala Munch 90g": 1.6}
pop = pop * prod.product_name.map(tweak).fillna(1.0).to_numpy()
pop = pop / pop.sum()

# ---------------------------------------------------------------- customers
NC = 9000
city_names = list(city_stores)
city_w = np.array([.33, .27, .22, .1, .08])
cust_city = rng.choice(len(city_names), NC, p=city_w)
store_ids_by_city = [stores.index[stores.city == c].to_numpy() for c in city_names]
home_store = np.array([rng.choice(store_ids_by_city[c]) for c in cust_city])
is_new = rng.random(NC) < .30
first_day = np.where(is_new, np.minimum((rng.beta(1.0, 1.7, NC) * DAYS).astype(int), DAYS-1), -1)
joined = np.where(is_new,
                  (START + pd.to_timedelta(first_day, unit="D")).values,
                  (pd.Timestamp("2026-01-01") + pd.to_timedelta(rng.integers(0, 242, NC), unit="D")).values)
channel = rng.choice(["Organic", "Paid ads", "Referral"], NC, p=[.5, .35, .15])
promo_group = np.where(is_new, np.where(rng.random(NC) < .7, "first_order_offer", "no_offer"), "")
lam = rng.lognormal(math.log(.075), .65, NC)             # orders per day
lam = np.where(promo_group == "first_order_offer", lam * .8, lam)  # offer-driven buyers repeat less
dow_f = np.array([.95, .9, .92, .95, 1.05, 1.25, 1.2])    # Mon..Sun
rate = lam[:, None] * dow_f[(np.arange(DAYS)) % 7][None, :] * (1 + .004*np.arange(DAYS))[None, :]
cnt = rng.poisson(rate)
for i in np.where(is_new)[0]:
    cnt[i, :first_day[i]] = 0
    cnt[i, first_day[i]] = 1
cust = pd.DataFrame(dict(customer_id=np.arange(1, NC+1), city=[city_names[c] for c in cust_city],
                         joined_date=pd.to_datetime(joined).date, acquisition_channel=channel))
cust["_home"] = home_store
cust["_promo"] = promo_group

# ---------------------------------------------------------------- orders
ci, di = np.nonzero(cnt)
reps = cnt[ci, di]
ci = np.repeat(ci, reps); di = np.repeat(di, reps)
NO = len(ci)
hours = np.arange(6, 24)
hw = np.array([.8,1.5,2.4,2.2,1.6,1.4,1.5,1.6,1.4,1.3,1.5,2.0,2.8,3.4,3.3,2.5,1.5,.8]); hw /= hw.sum()
hr = rng.choice(hours, NO, p=hw)
mn = rng.integers(0, 60, NO)
order_ts = START + pd.to_timedelta(di, unit="D") + pd.to_timedelta(hr, unit="h") + pd.to_timedelta(mn, unit="m")
st_idx = cust["_home"].to_numpy()[ci]
peak = np.isin(hr, [8, 9, 19, 20, 21, 22])
weekend = (di % 7) >= 5
mins = rng.lognormal(math.log(8.8), .33, NO) * speed_f[st_idx] * np.where(peak, 1.18, 1) * np.where(weekend, 1.08, 1)
mins = np.clip(mins, 3.5, 45)
cancel = rng.random(NO) < (0.02 * speed_f[st_idx])
orders = pd.DataFrame(dict(order_id=np.arange(1, NO+1), customer_id=ci+1, store_id=st_idx+1,
                           order_ts=order_ts, status=np.where(cancel, "Cancelled", "Delivered")))
orders["delivered_ts"] = (order_ts + pd.to_timedelta(mins, unit="m")).round("s")
orders.loc[cancel, "delivered_ts"] = pd.NaT
orders["_day"] = di
orders["_week"] = di // 7
orders["_city"] = cust["city"].to_numpy()[ci]
first_mask = np.zeros(NO, bool)
firsts = pd.Series(np.arange(NO)).groupby(ci).first()
first_mask[firsts.values] = True
orders["is_first_order"] = first_mask & is_new[ci]      # first-ever order only for customers new in window

# ---------------------------------------------------------------- SKU-week discounts
disc = np.zeros((WEEKS, NP))
mask = rng.random((WEEKS, NP)) < .28
vals = rng.choice([5, 10, 15, 20, 25], size=(WEEKS, NP), p=[.3, .3, .2, .15, .05])
disc[mask] = vals[mask]
disc[:, prod.brand_type.eq("Own label").values] *= .5      # own label discounts less
disc = np.round(disc / 5) * 5
# ---------------------------------------------------------------- order items
rows = []
is_reckitt = prod.company.eq("Reckitt").to_numpy()
for w in range(WEEKS):
    for c in city_names:
        idx = np.where((orders._week == w) & (orders._city == c))[0]
        if len(idx) == 0:
            continue
        wgt = pop * np.exp(.05 * disc[w])                    # demand rises with discount (built-in elasticity)
        if w in PILOT_WEEKS and c in TEST_CITIES:
            wgt = np.where(is_reckitt, wgt * 1.22, wgt)      # built-in effect of the Reckitt search-ad pilot
        wgt = wgt / wgt.sum()
        k = np.clip(1 + rng.poisson(2.6, len(idx)), 1, 12)
        oid = np.repeat(orders.order_id.to_numpy()[idx], k)
        sku = rng.choice(np.arange(1, NP+1), len(oid), p=wgt)
        qty = rng.choice([1, 2, 3], len(oid), p=[.78, .18, .04])
        rows.append(pd.DataFrame(dict(order_id=oid, sku_id=sku, quantity=qty, _w=w)))
oi = pd.concat(rows, ignore_index=True)
oi = oi.groupby(["order_id", "sku_id", "_w"], as_index=False).quantity.sum()
oi["discount_pct"] = disc[oi._w.to_numpy(), oi.sku_id.to_numpy()-1].astype(int)
mrp = prod.set_index("sku_id").mrp
oi["unit_price"] = (oi.sku_id.map(mrp) * (1 - oi.discount_pct/100)).round(2)
oi["unit_cost"] = oi.sku_id.map(prod.set_index("sku_id").unit_cost)
oi = oi.sort_values(["order_id", "sku_id"]).reset_index(drop=True)
oi.insert(0, "item_id", np.arange(1, len(oi)+1))
oi = oi.drop(columns="_w")

# order-level money columns
tot = (oi.unit_price * oi.quantity).groupby(oi.order_id).sum()
orders["items_total"] = orders.order_id.map(tot).round(2)
orders["delivery_fee"] = np.where(orders.items_total >= 199, 0, 25).astype(float)
offer = (cust["_promo"].to_numpy()[ci] == "first_order_offer") & first_mask & (orders.items_total.to_numpy() >= 299)
orders["order_discount"] = np.where(offer, 100.0, 0.0)
orders["promo_code"] = np.where(offer, "FIRST100", None)
# a first-order offer also bumps the first basket
orders["customer_offer_group"] = cust["_promo"].to_numpy()[ci]

# ---------------------------------------------------------------- inventory
ok = orders.status.eq("Delivered")
oi_o = oi.merge(orders[["order_id", "store_id", "_day"]][ok], on="order_id")
sold = oi_o.groupby(["store_id", "sku_id", "_day"]).quantity.sum()
full = pd.MultiIndex.from_product([range(1, NS+1), range(1, NP+1), range(DAYS)], names=["store_id", "sku_id", "_day"])
inv = sold.reindex(full, fill_value=0).rename("units_sold").reset_index()
n = len(inv)
perish = prod.is_perishable.to_numpy()[inv.sku_id.to_numpy()-1]
wf = waste_f[inv.store_id.to_numpy()-1]; sf = stock_f[inv.store_id.to_numpy()-1]
waste_rate = np.where(perish, rng.uniform(.03, .11, n) * wf, 0)
inv["units_wasted"] = rng.binomial(np.maximum(inv.units_sold.to_numpy(), 1) + 2, np.clip(waste_rate, 0, .6))
inv.loc[~perish, "units_wasted"] = rng.binomial(1, .004 * wf[~perish])
top = pop[inv.sku_id.to_numpy()-1] > np.quantile(pop, .8)
p_out = np.clip(.045 * sf * np.where(top, 1.7, 1), 0, .5)
out = rng.random(n) < p_out
inv["stockout_hours"] = np.where(out, rng.integers(1, 11, n), 0)
inv["units_stocked"] = inv.units_sold + inv.units_wasted + rng.integers(0, 4, n) + (inv.units_sold * .15).round().astype(int)
inv["stock_date"] = (START + pd.to_timedelta(inv._day, unit="D")).dt.date
inv = inv[["stock_date", "store_id", "sku_id", "units_stocked", "units_sold", "units_wasted", "stockout_hours"]]

# ---------------------------------------------------------------- ads
camp = []
ad_rows = []
cid = 1
company_sales = (oi_o.assign(sales=oi_o.quantity*oi_o.unit_price)
                 .merge(prod[["sku_id", "company"]], on="sku_id")
                 .merge(stores[["store_id", "city"]], on="store_id")
                 .groupby(["company", "city", "_day"]).sales.sum())
adv = ["HUL", "Reckitt", "ITC", "Nestle India", "Dabur", "P&G", "Marico", "Tata Consumer", "Britannia", "PepsiCo"]
roas_base = {"Search": (4.2, 7.0), "Banner": (1.6, 3.2)}
for comp in adv:
    for typ in ["Search", "Banner"]:
        lo, hi = roas_base[typ]
        r = rng.uniform(lo, hi)
        camp.append(dict(campaign_id=cid, company=comp, ad_type=typ, campaign_name=f"{comp} {typ} Always-on"))
        cpc = rng.uniform(6, 13) if typ == "Search" else rng.uniform(2.5, 5)
        ctr = rng.uniform(.03, .05) if typ == "Search" else rng.uniform(.006, .012)
        for c in city_names:
            for d in range(DAYS):
                s = company_sales.get((comp, c, d), 0)
                if s <= 0: continue
                ads = s * rng.uniform(.10, .22) * (1 if typ == "Search" else .6)
                rr = r * rng.uniform(.85, 1.15)
                spend = ads / rr
                clicks = int(spend / cpc)
                ad_rows.append((cid, START + pd.Timedelta(days=d), c, int(clicks/ctr), clicks, round(spend, 2),
                                int(clicks*rng.uniform(.06, .12)), round(ads, 2)))
        cid += 1
# Reckitt Search pilot (test cities only, weeks 5-8)
camp.append(dict(campaign_id=cid, company="Reckitt", ad_type="Search", campaign_name="Reckitt Dettol Search Pilot"))
for c in TEST_CITIES:
    for d in range(PILOT_WEEKS.start*7, (PILOT_WEEKS.stop)*7):
        s = company_sales.get(("Reckitt", c, d), 0)
        ads = s * .16; spend = ads / 5.8; clicks = int(spend / 9.5)
        ad_rows.append((cid, START + pd.Timedelta(days=d), c, int(clicks/.04), clicks, round(spend, 2),
                        int(clicks*.1), round(ads, 2)))
camp = pd.DataFrame(camp)
camp["start_date"] = START.date(); camp["end_date"] = (START + pd.Timedelta(days=DAYS-1)).date()
ad = pd.DataFrame(ad_rows, columns=["campaign_id", "ad_date", "city", "impressions", "clicks", "spend", "ad_orders", "ad_sales"])
ad["ad_date"] = ad.ad_date.dt.date

# ---------------------------------------------------------------- write
orders_out = orders[["order_id", "customer_id", "store_id", "order_ts", "delivered_ts", "status",
                     "items_total", "delivery_fee", "order_discount", "promo_code", "is_first_order"]].copy()
orders_out["order_ts"] = orders_out.order_ts.dt.strftime("%Y-%m-%d %H:%M:%S")
orders_out["delivered_ts"] = orders_out.delivered_ts.dt.strftime("%Y-%m-%d %H:%M:%S")
prod_out = prod[["sku_id", "product_name", "category", "brand", "company", "brand_type", "mrp",
                 "unit_cost", "shelf_life_days", "is_perishable"]]
cust_out = cust[["customer_id", "city", "joined_date", "acquisition_channel"]]
cust_out = cust_out.assign(offer_group=np.where(promo_group == "", None, promo_group))
stores_out = stores[["store_id", "store_name", "city", "area", "opened_date", "size_sqft"]]
for name, df in dict(dark_stores=stores_out, products=prod_out, customers=cust_out, orders=orders_out,
                     order_items=oi, inventory_daily=inv, ad_campaigns=camp, ad_daily=ad).items():
    df.to_csv(os.path.join(OUT, f"{name}.csv"), index=False)
    print(f"{name:16s} {len(df):>8,d} rows")
