# Olist delivery analysis

SQL project exploring delivery delays, seller performance and customer reviews
using 99,441 orders from the
[Olist e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

**Skills:** SQL, data analysis, relational databases.

## Notebook

[Open the analysis notebook](olist_delivery_analysis.ipynb).

It starts with sample rows from all six tables and a diagram of their
relationships. Each analysis section then follows the same sequence:
question, SQL query, result and a short conclusion. Results and charts are
saved in the notebook, so it can be read on GitHub without running anything.

## Main results

- 6.77% of delivered orders with usable dates arrived late.
- Alagoas had the highest late rate among states with at least 100 eligible
  orders, but São Paulo and Rio de Janeiro accounted for 50.73% of late orders.
- Orders handed to the carrier after the shipping deadline had a 20.86% late
  rate, compared with 5.41% for those dispatched within the deadline.

[Read the findings](reports/findings.md) or browse the
[query results](reports/results/).

## Analysis

The [SQL queries](sql/analysis/) cover delivery performance by month, state
and seller, along with dispatch timing, reviews, freight charges and payment
totals. The [analysis notes](docs/questions.md) explain the calculations;
the [data dictionary](docs/data_dictionary.md) describes the tables.

## Run locally

Use Python 3.10+ and SQLite 3.25+. Install the notebook packages:

```sh
python3 -m pip install -r requirements.txt
```

Python displays query results and draws charts; the calculations are in SQL.

Download the dataset from Kaggle and put these files in `data/raw/`:

```text
olist_customers_dataset.csv
olist_sellers_dataset.csv
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
```

From the project folder, run:

```sh
python3 scripts/load_data.py
jupyter notebook olist_delivery_analysis.ipynb
```

The first command creates `data/olist.sqlite`. Skip it if the database already
exists. The second opens the notebook; run the cells from top to bottom.
The source CSVs and database stay local.

The loader will not overwrite a database. To rebuild it under a new name,
use `python3 scripts/load_data.py --db data/olist-new.sqlite` and change the
database path in the notebook's first code cell.

The original SQL files can also be run in a SQLite editor. To export their
results as CSVs without Jupyter, run `python3 scripts/run_analysis.py`.

## Scope

Late rates include delivered orders with valid dates; they leave out canceled
and unresolved orders. These are historical comparisons, without adjustment
for distance, product mix or delivery promises. They help identify where to
look next, but cannot explain the cause of a delay on their own.
