import os
import psycopg2
import pandas as pd
from glob import glob

# Connection info
conn = psycopg2.connect(
    dbname="final_project",
    user="postgres",
    password="---password---",
    host="localhost",
    port=5432
)
cur = conn.cursor()

# Path to your folder with CSV files
csv_folder = "C:\\temp\\project\\raw_data\\taxi\\yellow_taxi_csv"
csv_files = glob(os.path.join(csv_folder, "*.csv"))

# Expected columns based on Taxi_raw table
expected_columns = [
    "VendorID", "tpep_pickup_datetime", "tpep_dropoff_datetime",
    "passenger_count", "trip_distance", "RatecodeID", "store_and_fwd_flag",
    "PULocationID", "DOLocationID", "payment_type", "fare_amount", "extra",
    "mta_tax", "tip_amount", "tolls_amount", "improvement_surcharge",
    "total_amount", "congestion_surcharge", "airport_fee", "cbd_congestion_fee"
]

for csv_file in csv_files:
    print(f"Processing {csv_file}...")

    # Load CSV into DataFrame
    df = pd.read_csv(csv_file)

    # Add missing columns with None
    for col in expected_columns:
        if col not in df.columns:
            df[col] = None

    # Reorder to match table exactly
    df = df[expected_columns]

    # Save to a temporary CSV file
    temp_csv = "temp_fixed.csv"
    df.to_csv(temp_csv, index=False)

    # Import into SQL
    with open(temp_csv, 'r', encoding='utf-8') as f:
        cur.copy_expert(f"""
            COPY Taxi_raw({', '.join(expected_columns)})
            FROM STDIN WITH CSV HEADER
        """, f)
    conn.commit()

cur.close()
conn.close()