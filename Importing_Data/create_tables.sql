--Create tables
create table MTA_raw (
	date varchar,
	Subways varchar,
	Buses varchar,
	LIRR varchar,
	Metro_North varchar,
	Access_A_Ride varchar,
	Bridges_and_Tunnels varchar,
	Staten_Island_Railway varchar
);

--Imort raw data manuely for MTA_raw. This is needed becouse we are skipping sertain columbs and are using special mappings.
--data from: https://data.ny.gov/Transportation/MTA-Daily-Ridership-Data-2020-2025/vxuj-8kew/about_data

create table Taxi_raw (
	VendorID varchar,
	tpep_pickup_datetime varchar,
	tpep_dropoff_datetime varchar,
	passenger_count varchar,
	trip_distance varchar,
	RatecodeID varchar,
	store_and_fwd_flag varchar,
	PULocationID varchar,
	DOLocationID varchar,
	payment_type varchar,
	fare_amount varchar,
	extra varchar,
	mta_tax varchar,
	tip_amount varchar,
	tolls_amount varchar,
	improvement_surcharge varchar,
	total_amount varchar,
	congestion_surcharge varchar,
	airport_fee varchar,
	cbd_congestion_fee varchar
);

--Import data from python script
--data from: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

create table Weather_raw (
	STATION varchar,
	NAME varchar,
	DATE varchar,
	AWND varchar,
	DAPR varchar,
	DASF varchar,
	MDPR varchar,
	MDSF varchar,
	PGTM varchar,
	PRCP varchar,
	SNOW varchar,
	SNWD varchar,
	TAVG varchar,
	TMAX varchar,
	TMIN varchar,
	WESD varchar,
	WESF varchar,
	WSF2 varchar,
	WT01 varchar,
	WT02 varchar,
	WT03 varchar,
	WT04 varchar,
	WT05 varchar,
	WT06 varchar,
	WT08 varchar,
	WT09 varchar,
	WT11 varchar
);

COPY Weather_raw from 'C:\temp\project\raw_data\weather\2020_2023.csv' WITH (FORMAT csv, HEADER);
--used python to fix column error
COPY Weather_raw from 'C:\temp\project\raw_data\weather\2023_2025_fixed.csv' WITH (FORMAT csv, HEADER);


create table citibike_raw (
	ride_id varchar,
	rideable_type varchar,
	started_at varchar,
	ended_at varchar,
	start_station_name varchar,
	start_station_id varchar,
	end_station_name varchar,
	end_station_id varchar,
	start_lat varchar,
	start_lng varchar,
	end_lat varchar,
	end_lng varchar,
	member_casual varchar
)

--Imprt with python
