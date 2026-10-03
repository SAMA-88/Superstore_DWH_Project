import duckdb
import pandas as pd
import os

# 1. Configure paths dynamically so the script works on any machine
# Get the project's root directory (one level up from the scripts folder)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Define the data file and DuckDB database paths
DATA_FILE = os.path.join(BASE_DIR, 'data', 'Superstore.xlsx')
DB_FILE = os.path.join(BASE_DIR, 'dbt_project1', 'dev.duckdb')


def main():
    print("Starting the data extraction process...")

    # 2. Read the data
    print(f"📂 Reading the file from: {DATA_FILE}")

    try:
        df = pd.read_excel(DATA_FILE)
    except FileNotFoundError:
        print("❌ Error: Superstore.xlsx was not found in the data folder!")
        return

    # Clean column names:
    # Remove spaces and hyphens and convert names to lowercase
    # to make them easier to use later with dbt.
    df.columns = (
        df.columns
        .str.replace(' ', '_')
        .str.replace('-', '_')
        .str.lower()
    )

    print("Creating the database and loading the data...")

    # 3. Connect to DuckDB and create the table
    # DuckDB is very fast and can query a Pandas DataFrame
    # directly as if it were a SQL table.
    conn = duckdb.connect(DB_FILE)

    # Create or replace the ODS table with the data from the DataFrame
    conn.execute(
        "CREATE OR REPLACE TABLE ods_superstore AS SELECT * FROM df"
    )

    # Verify the number of rows loaded
    result = conn.execute(
        "SELECT COUNT(*) FROM ods_superstore"
    ).fetchone()

    print(
        f"✅ Process completed successfully! "
        f"{result[0]} rows were loaded into the 'ods_superstore' table."
    )

    conn.close()


if __name__ == "__main__":
    main()
