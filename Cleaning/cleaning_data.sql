--create clean mta table
 create table mta (
 	date date primary key,
	Subways int,
	Buses int,
	LIRR int,
	Metro_North int,
	Access_A_Ride int,
	Bridges_and_Tunnels int,
	Staten_Island_Railway int
 );

--fill it with relevant information
insert into mta (date, Subways, Buses, LIRR, Metro_North, Access_A_Ride, Bridges_and_Tunnels, Staten_Island_Railway)
select
	cast(mr."date" as date) as date,
	cast(mr.subways as int),
	cast(mr.buses as int),
	cast(mr.lirr as int),
	cast(mr.metro_north as int),
	cast(mr.access_a_ride as int),
	cast(mr.bridges_and_tunnels as int),
	cast(mr.staten_island_railway as int)
from mta_raw mr; 

-----------------------------------------------------------------
--create clean taxi table
create table taxi (
	date date primary key,
	count int,
	tot_passengers int,
	tot_distance float,
	tot_amount float
);

--fill it with relevant information
with trip_data as (
	select 
		date(tr.tpep_pickup_datetime) as date,
		CAST(CAST(passenger_count AS float) AS int) as passengers,
		cast(tr.trip_distance as float) as distance,
		cast(tr.total_amount as float) as amount
	from taxi_raw tr 
)
insert into taxi (date, count, tot_passengers, tot_distance, tot_amount)
select
	td.date as date,
	count(*) as count,
	sum(td.passengers) as tot_passengers,
	sum(td.distance) as tot_distance,
	sum(td.amount) as tot_amount
from trip_data td 
group by td.date
order by td.date;

-----------------------------------------------------------------
--create clean weather
create table weather(
	date date primary key,
	avg_wind_speed float,
	avg_num_days_in_multiday_percip float,
	avg_num_days_in_multiday_snow float,
	avg_multiday_percip float,
	avg_multiday_snow float,
	avg_peak_gust_time float,
	avg_precip float,
	avg_snow float,
	avg_snow_depth float,
	avg_avg_temp float,
	avg_max_temp float,
	avg_min_temp float,
	avg_water_eqiv_snow_on_ground float,
	avg_water_eqiv_snowfall float,
	most_common_wt int
);

--fill it with relevant information
--I had to transform th wt-- colums to condense it into the mode of the weather types 
WITH weather_data AS (
    SELECT
        cast(wr."date" as date),
        avg(cast(wr.awnd as float)) as avg_wind_speed,
        avg(cast(wr.dapr as float)) as avg_num_days_in_multiday_percip,
        avg(cast(wr.dasf as float)) as avg_num_days_in_multiday_snow,
        avg(cast(wr.mdpr as float)) as avg_multiday_percip,
        avg(cast(wr.mdsf as float)) as avg_multiday_snow,
        avg(cast(wr.pgtm as float)) as avg_peak_gust_time,
        avg(cast(wr.prcp as float)) as avg_precip,
        avg(cast(wr.snow as float)) as avg_snow,
        avg(cast(wr.snwd as float)) as avg_snow_depth,
        avg(cast(wr.tavg as float)) as avg_avg_temp,
        avg(cast(wr.tmax as float)) as avg_max_temp,
        avg(cast(wr.tmin as float)) as avg_min_temp,
        avg(cast(wr.wesd as float)) as avg_water_eqiv_snow_on_ground,
        avg(cast(wr.wesf as float)) as avg_water_eqiv_snowfall,
        avg(cast(wr.wsf2 as float)) as avg_fastest_2_min_wind_speed,
        sum(cast(wr.wt01 as float)) as tot_wt01,
        sum(cast(wr.wt02 as float)) as tot_wt02,
        sum(cast(wr.wt03 as float)) as tot_wt03,
        sum(cast(wr.wt04 as float)) as tot_wt04,
        sum(cast(wr.wt05 as float)) as tot_wt05,
        sum(cast(wr.wt06 as float)) as tot_wt06,
        sum(cast(wr.wt08 as float)) as tot_wt08,
        sum(cast(wr.wt09 as float)) as tot_wt09,
        sum(cast(wr.wt11 as float)) as tot_wt11
    FROM weather_raw wr
    GROUP BY wr."date"
)
insert into weather(date, 
					avg_wind_speed,
					avg_num_days_in_multiday_percip,
					avg_num_days_in_multiday_snow,
					avg_multiday_percip,
					avg_multiday_snow,
					avg_peak_gust_time,
					avg_precip,
					avg_snow,
					avg_snow_depth,
					avg_avg_temp,
					avg_max_temp,
					avg_min_temp,
					avg_water_eqiv_snow_on_ground,
					avg_water_eqiv_snowfall,
					most_common_wt
					)
select
	wd.date,
	wd.avg_wind_speed,
	wd.avg_num_days_in_multiday_percip,
	wd.avg_num_days_in_multiday_snow,
	wd.avg_multiday_percip,
	wd.avg_multiday_snow,
	wd.avg_peak_gust_time,
	wd.avg_precip,
	wd.avg_snow,
	wd.avg_snow_depth,
	wd.avg_avg_temp,
	wd.avg_max_temp,
	wd.avg_min_temp,
	wd.avg_water_eqiv_snow_on_ground,
	wd.avg_water_eqiv_snowfall,
	wt.most_common_wt
FROM weather_data wd
LEFT JOIN LATERAL (
    SELECT wt_code AS most_common_wt
    FROM (
        VALUES
            (1, wd.tot_wt01),
            (2, wd.tot_wt02),
            (3, wd.tot_wt03),
            (4, wd.tot_wt04),
            (5, wd.tot_wt05),
            (6, wd.tot_wt06),
            (8, wd.tot_wt08),
            (9, wd.tot_wt09),
            (11, wd.tot_wt11)
    ) AS wt(wt_code, wt_total)
    WHERE wt_total IS NOT NULL
    ORDER BY wt_total DESC
    LIMIT 1
) wt ON true;


-----------------------------------------------------------------
--create clean table
create table citibike (
	date date primary key,
	COUNT INT,
	avg_time_interval_min float,
	avg_trip_distance_km float
);


--Insert relevant information by day
WITH citibike_data AS (
	SELECT 
		CAST(TO_TIMESTAMP(TRIM(cr.started_at), 'YYYY-MM-DD HH24:MI:SS.MS') AS date) AS date,
		EXTRACT(EPOCH FROM (
			TO_TIMESTAMP(TRIM(cr.ended_at), 'YYYY-MM-DD HH24:MI:SS.MS') - 
			TO_TIMESTAMP(TRIM(cr.started_at), 'YYYY-MM-DD HH24:MI:SS.MS')
		)) / 60 AS time_interval_min,
		6371 * acos(
	        LEAST(1, GREATEST(-1,
	            cos(radians(CAST(TRIM(cr.start_lat) AS float))) * cos(radians(CAST(TRIM(cr.end_lat) AS float))) * 
	            cos(radians(CAST(TRIM(cr.end_lng) AS float)) - radians(CAST(TRIM(cr.start_lng) AS float))) + 
	            sin(radians(CAST(TRIM(cr.start_lat) AS float))) * sin(radians(CAST(TRIM(cr.end_lat) AS float)))
	        ))
	    ) AS trip_distance_km
	FROM citibike_raw cr
	WHERE 
		-- Make sure timestamps are not null and have correct format
		cr.started_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.\d+)?$'
		AND cr.ended_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.\d+)?$'
		AND TO_TIMESTAMP(TRIM(cr.ended_at), 'YYYY-MM-DD HH24:MI:SS.MS') > TO_TIMESTAMP(TRIM(cr.started_at), 'YYYY-MM-DD HH24:MI:SS.MS')
)
INSERT INTO citibike(date, COUNT, avg_time_interval_min, avg_trip_distance_km)
SELECT
	date,
	count(*) as COUNT,
	AVG(time_interval_min) AS avg_time_interval_min,
	AVG(trip_distance_km) AS avg_trip_distance_km
FROM citibike_data
WHERE time_interval_min BETWEEN 1 AND 180  -- filter out unrealistic values
GROUP BY date
ORDER BY date;


--select only rows that share dates accros all the tables
delete from mta m
where m."date" not in (
    select t."date"
    from taxi t
    inner join mta m on t."date" = m."date"
    inner join weather w on t."date" = w."date"
    inner join citibike c on t."date" = c."date"
);

delete from taxi t
where t."date" not in (
    select t."date"
    from taxi t
    inner join mta m on t."date" = m."date"
    inner join weather w on t."date" = w."date"
    inner join citibike c on t."date" = c."date"
);

delete from weather w
where w."date" not in (
    select t."date"
    from taxi t
    inner join mta m on t."date" = m."date"
    inner join weather w on t."date" = w."date"
    inner join citibike c on t."date" = c."date"
);

delete from citibike c
where c."date" not in (
    select t."date"
    from taxi t
    inner join mta m on t."date" = m."date"
    inner join weather w on t."date" = w."date"
    inner join citibike c on t."date" = c."date"
);