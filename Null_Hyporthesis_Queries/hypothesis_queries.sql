create table full_table as
	select w.date, w.avg_avg_temp, w.avg_max_temp, w.avg_min_temp, w.avg_precip, w.avg_snow, w.avg_snow_depth, w.avg_wind_speed, m.subways, m.buses, m.LIRR, t.count as taxi_count, c.count as citibike_count 
	from weather w
	join taxi t on t.date = w.date
	join mta m on m.date = w.date
	join citibike c on c.date = w.date
	order by w.date;

-- total riders per month (across all modes)
select extract(year from ft.date) as year, extract(month from ft.date) as month, 
	sum(ft.subways + ft.buses + ft.lirr + ft.taxi_count + ft.citibike_count) as total_ridership
from full_table ft
group by extract(year from ft.date), extract(month from ft.date)
order by year, month;

-- total riders per month per mode of transport
select extract(year from ft.date) as year, extract(month from ft.date) as month, 
	sum(ft.subways) as total_monthly_subway_riders, 
	sum(ft.buses) as total_monthly_bus_riders, 
	sum(ft.lirr) as total_monthly_lirr_riders, 
	sum(ft.taxi_count) as total_montly_taxi_users, 
	sum(ft.citibike_count) as total_monthly_citibike_riders
from full_table ft
group by extract(year from ft.date), extract(month from ft.date)
order by year, month;

-- avg mean temp vs. ridership
select ft.avg_avg_temp, ft.subways, ft.buses, ft.lirr, ft.taxi_count, ft.citibike_count
from full_table ft
order by ft.avg_avg_temp;

-- avg precipitation vs. ridership
select ft.avg_precip, ft.subways, ft.buses, ft.lirr, ft.taxi_count, ft.citibike_count
from full_table ft
order by ft.avg_precip;

-- avg snowfall vs. ridership
select ft.avg_snow, ft.subways, ft.buses, ft.lirr, ft.taxi_count, ft.citibike_count
from full_table ft
order by ft.avg_snow;

-- total riders per season per mode of transport
select 
  	case
    	when extract(month from ft.date) in (12, 1, 2) then 'Winter'
    	when extract(month from ft.date) in (3, 4, 5) then 'Spring'
    	when extract(month from ft.date) in (6, 7, 8) then 'Summer'
    	else 'Fall'
  	end as season,
	sum(ft.subways) as total_monthly_subway_riders, 
	sum(ft.buses) as total_monthly_bus_riders, 
	sum(ft.lirr) as total_monthly_lirr_riders, 
	sum(ft.taxi_count) as total_montly_taxi_users, 
	sum(ft.citibike_count) as total_monthly_citibike_riders
from full_table ft
group by season;

  -- binned mean temp vs. ridership
select floor(ft.avg_avg_temp / 5.0) * 5 as temp_bin, 
	avg(ft.avg_avg_temp) as avg_temp_in_bin, 
	sum(ft.subways) as total_subways, 
	sum(ft.buses) as total_buses, 
	sum(ft.lirr) as total_lirr, 
	sum(ft.taxi_count) as total_taxi, 
	sum(ft.citibike_count) as total_citibike
from full_table ft
group by temp_bin
order by temp_bin;

  -- binned mean precipitation vs. ridership
select floor(ft.avg_precip / 0.1) * 0.1 AS precip_bin,
	avg(ft.avg_precip) as avg_precip_in_bin, 
	sum(ft.subways) as total_subways, 
	sum(ft.buses) as total_buses, 
	sum(ft.lirr) as total_lirr, 
	sum(ft.taxi_count) as total_taxi, 
	sum(ft.citibike_count) as total_citibike
from full_table ft
group by precip_bin
order by precip_bin;

  -- binned mean snowfall vs. ridership
select floor(ft.avg_snow / 0.1) * 0.1 AS snow_bin,
	avg(ft.avg_snow) as avg_snow_in_bin, 
	sum(ft.subways) as total_subways, 
	sum(ft.buses) as total_buses, 
	sum(ft.lirr) as total_lirr, 
	sum(ft.taxi_count) as total_taxi, 
	sum(ft.citibike_count) as total_citibike
from full_table ft
group by snow_bin
order by snow_bin;
