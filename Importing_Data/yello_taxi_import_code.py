import os
import requests
import pandas as pd
from tqdm import tqdm

# Create folders
parquet_folder = "yellow_taxi_parquet"
csv_folder = "yellow_taxi_csv"
#os.makedirs(parquet_folder, exist_ok=True)
#os.makedirs(csv_folder, exist_ok=True)

# Base URL
base_url = "https://d37ci6vzurychx.cloudfront.net/trip-data/"
years = range(2025, 2026)  # Adjust as needed
months = [f"{m:02d}" for m in range(1, 3)]

for year in years:
    for month in months:
        filename = f"yellow_tripdata_{year}-{month}.parquet"
        url = base_url + filename
        parquet_path = os.path.join(parquet_folder, filename)
        csv_filename = filename.replace(".parquet", ".csv")
        csv_path = os.path.join(csv_folder, csv_filename)

        # Skip download if already exists
        if os.path.exists(csv_path):
            print(f"Already exists: {csv_filename}")
            continue

        try:
            # Download .parquet file
            print(f"Downloading: {filename}")
            response = requests.get(url, stream=True, timeout=10)
            if response.status_code == 200:
                with open(parquet_path, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=1024):
                        if chunk:
                            f.write(chunk)

                # Convert to CSV
                print(f"Converting: {filename} -> {csv_filename}")
                df = pd.read_parquet(parquet_path)
                df.to_csv(csv_path, index=False)
            else:
                print(f"Skipped (not found): {filename}")
        except Exception as e:
            print(f"Error processing {filename}: {e}")
