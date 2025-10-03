import pandas as pd

# Define expected column names
expected_columns = [
    "STATION", "NAME", "DATE", "AWND", "DAPR", "DASF", "MDPR", "MDSF", "PGTM",
    "PRCP", "SNOW", "SNWD", "TAVG", "TMAX", "TMIN", "WESD", "WESF", "WSF2",
    "WT01", "WT02", "WT03", "WT04", "WT05", "WT06", "WT08", "WT09", "WT11"
]

# Load your CSV
df = pd.read_csv("C:\\temp\\project\\raw_data\\weather\\2023_2025.csv")

# Add missing columns as empty
for col in expected_columns:
    if col not in df.columns:
        df[col] = None

# Reorder to match SQL table
df = df[expected_columns]

# Save cleaned CSV
df.to_csv("C:\\temp\\project\\raw_data\\weather\\2023_2025_fixed.csv", index=False)
