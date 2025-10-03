import os
import psycopg2
import pandas as pd
import tempfile

# --- CONFIGURE THIS ---
CSV_FOLDER = "C:\\temp\\project\\raw_data\\citibike"

# --- PostgreSQL connection ---
conn = psycopg2.connect(
    dbname="final_project",
    user="postgres",
    password="----",  # Replace with your actual password
    host="localhost",
    port=5432
)
cur = conn.cursor()

# --- Expected columns in PostgreSQL table ---
expected_columns = [
    "ride_id", "rideable_type", "started_at", "ended_at",
    "start_station_name", "start_station_id", "end_station_name", "end_station_id",
    "start_lat", "start_lng", "end_lat", "end_lng", "member_casual"
]

# --- Process each CSV file ---
for filename in os.listdir(CSV_FOLDER):
    if filename.endswith(".csv"):
        filepath = os.path.join(CSV_FOLDER, filename)
        print(f"\nProcessing {filename}...")

        try:
            # Load CSV into DataFrame
            df = pd.read_csv(filepath)

            # Drop 'Unnamed: 0' if it exists
            if 'Unnamed: 0' in df.columns:
                df = df.drop(columns=['Unnamed: 0'])

            # Convert mixed-type columns to strings
            for col in df.columns:
                if df[col].apply(type).nunique() > 1:
                    print(f'Converting column "{col}" to string due to mixed types.')
                    df[col] = df[col].astype(str)

            # Check for missing expected columns
            missing_cols = set(expected_columns) - set(df.columns)
            if missing_cols:
                raise ValueError(f"Missing columns in {filename}: {missing_cols}")

            # Remove any unexpected columns and reorder correctly
            df = df[expected_columns]

            # Save cleaned DataFrame to a temporary file
            with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, newline='', encoding="utf-8") as tmpfile:
                df.to_csv(tmpfile.name, index=False)
                tmp_csv_path = tmpfile.name

            # Load into PostgreSQL using COPY
            with open(tmp_csv_path, "r", encoding="utf-8") as f:
                cur.copy_expert(
                    sql="""
                    COPY citibike_raw (
                        ride_id, rideable_type, started_at, ended_at,
                        start_station_name, start_station_id, end_station_name, end_station_id,
                        start_lat, start_lng, end_lat, end_lng, member_casual
                    )
                    FROM STDIN WITH CSV HEADER DELIMITER ','
                    """,
                    file=f
                )
            conn.commit()
            print(f"Loaded {filename} successfully.")

        except Exception as e:
            conn.rollback()
            print(f"Failed to load {filename}: {e}")

# --- Clean up ---
print("\nAll files processed.")
cur.close()
conn.close()
