"""Execute every analysis query and save its result as a CSV."""

import argparse
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(database, output):
    if not database.is_file():
        raise FileNotFoundError(f"Load the source data first: {database}")
    output.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(f"{database.resolve().as_uri()}?mode=ro", uri=True) as connection:
        for query in sorted((ROOT / "sql/analysis").glob("*.sql")):
            result = connection.execute(query.read_text())
            rows = result.fetchall()
            with (output / f"{query.stem}.csv").open("w", newline="") as target:
                writer = csv.writer(target)
                writer.writerow(column[0] for column in result.description)
                writer.writerows(rows)
            print(f"{query.name}: {len(rows)} result rows")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", type=Path, default=ROOT / "data/olist.sqlite")
    parser.add_argument("--output", type=Path, default=ROOT / "reports/results")
    args = parser.parse_args()
    run(args.db, args.output)
