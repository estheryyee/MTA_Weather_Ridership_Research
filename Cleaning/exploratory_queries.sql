--Checking to see if ternds exist.
with totals as (
	select
		w."date",
		w.avg_avg_temp,
		t.tot_passengers as taxi,
		m.subways,
		m.buses,
		m.lirr,
		--m.bridges_and_tunnels,
		c.count as bike,
		t.tot_passengers + m.subways + m.buses + m.lirr + c.count as total 
	from weather w 
	join taxi t on w."date" = t."date" 
	join mta m on w."date" = m."date" 
	join citibike c on w."date" = c."date" 
),
ratios as(
	select 
		tot."date",
		tot.avg_avg_temp,
		ntile(10) over (order by tot.avg_avg_temp) as percentile,
		tot.taxi::numeric  / tot.total as taxi_passenger_ratio,
		tot.subways::numeric  / tot.total as subways_ratio,
		tot.buses::numeric  / tot.total as buses_ratio,
		tot.lirr::numeric  / tot.total as lirr_ratio,
		--tot.bridges_and_tunnels::numeric  / tot.total as bridges_tunnels_ratio,
		tot.bike::numeric  / tot.total as bike_ratio
	from totals tot
)
select
	avg(r.avg_avg_temp) as avg_avg_avg_temp,
	r.percentile,
	round(avg(r.taxi_passenger_ratio), 2) as avg_taxi_passenger_ratio,
	round(avg(r.subways_ratio), 2) as avg_subways_ratio,
	round(avg(r.buses_ratio), 2) as avg_buses_ratio,
	round(avg(r.lirr_ratio), 2) as avg_lirr_ratio,
	--round(avg(r.bridges_tunnels_ratio), 2) as avg_bridges_tunnels_ratio,
	round(avg(r.bike_ratio), 2) as avg_bike_ratio
from ratios r
group by r.percentile
order by r.percentile;


--checking to see if the dates are all their.
with year_month as (
	select
		extract(year from w.date) as year,
		extract(month from w.date) as month
	from citibike w
	order by year, month
)
select distinct ym.year, ym.month
from year_month ym;












