"""Load the original Olist CSV files into a new SQLite database."""

import argparse
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TABLES = {
    "customers": "olist_customers_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
}


def load(raw_dir, database):
    if database.exists():
        raise FileExistsError(f"{database} already exists. Choose a new --db path.")
    missing = [name for name in TABLES.values() if not (raw_dir / name).is_file()]
    if missing:
        raise FileNotFoundError("Missing source CSVs: " + ", ".join(missing))
    database.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(database) as connection:
        connection.executescript((ROOT / "sql/schema.sql").read_text())
        for table, filename in TABLES.items():
            path = raw_dir / filename
            columns = [row[1] for row in connection.execute(f"PRAGMA table_info({table})")]
            if table == "reviews":
                columns.remove("source_row")
            placeholders = ",".join("?" for _ in columns)
            with path.open(encoding="utf-8-sig", newline="") as source:
                reader = csv.DictReader(source)
                if not set(columns) <= set(reader.fieldnames or []):
                    raise ValueError(f"Unexpected headers in {filename}")
                rows = ([row[column] or None for column in columns] for row in reader)
                connection.executemany(
                    f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders})", rows
                )
            count = connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"{table}: {count:,} rows")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--raw", type=Path, default=ROOT / "data/raw")
    parser.add_argument("--db", type=Path, default=ROOT / "data/olist.sqlite")
    args = parser.parse_args()
    load(args.raw, args.db)
