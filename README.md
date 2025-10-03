# SQL Spring 2025 Group Project 
Collaborators: Jacob Tennenbaum, Shana Mandelbaum, Esther Yee

# Phase 1:

Research Question Proposal:
"How does the weather impact the transportation in NYC?"

We seek to understand how different weather conditions impact ridership across various methods of transportation in NYC. The effects of rain, snow, and temperature will be the primary focus.

The datasets we will use are: 
1) MTA Daily Ridership Data: 2020 - 2025  
This dataset covers daily ridership across all modes of MTA transportation (Subways, Buses, LIRR, Metro-North, Access-A-Ride, Bridges and Tunnels, Staten Island Railway).

2) Taxi data  
This dataset covers daily ridership in taxicabs.

3) National Weather Service  
This dataset tracks many weather-related metrics across many weather stations daily.

4) Citi Bike
This dataset tracks Citi Bike usage.


Potential Linkage Keys  
Date/time.

# Phase 2:

**Initial strategy for joining or cross-referencing datasets**
The datasets will be left joined by date. We will join everything onto the weather dataset.
We are using a left join in order to ensure that we maintain all the dates in the weather dataset even if one of the observations in one of our other datasets is null for one day (although this is unexpected).
Initially, we will join important weather attributes along with counts for taxi rides per day, subway riders per day, citibike rides, busgoers per day, and bridges and tunnels taken per day.
In our further analysis, we will look at specific weather attributes in relation to our methods of transportation (taxi, subway, citibike, bus, bridges and tunnels). 
We will merge our transportation datasets with that specific weather attribute. 

**Intermediate merged table with grain definition and justification**
SQL code for merging the tables:
-- merging tables on date
select w.date, w.avg_avg_temp, w.avg_max_temp, w.avg_min_temp, w.avg_precip, w.avg_snow, w.avg_snow_depth, w.avg_wind_speed, m.subways, m.buses, m.bridges_and_tunnels, t.count as taxi_count, c.count as citibike_count 
from weather w
left join taxi t on t.date = w.date
left join mta m on m.date = w.date
left join citibike c on c.date = w.date
order by w.date;

Each row in the merged dataset will respresent one day. Our data ranges from March 1, 2020 to January 9, 2025.
Using each row to represent a day means we will be able to see how specific weather attributes can affect ridership and use of different modes of transportation.

**EDA Through Data Visualization**
Using the merged table, separate SQL queries were written to extract data related to average precipitation, snowfall, and temperature. These subsets were exported and visualized individually in Tableau. Multiple charts were created and combined into an interactive dashboard.

Included are the charts focusing on the relationship between a specific weather attribute and ridership, as well as s seasonal ridership chart.  The seasonal chart showed that extreme weather seasons (particularly winter) had noticeably lower ridership compared to fall and spring.

The dashboard can be viewed here: [Project Dashboard](https://public.tableau.com/app/profile/esther.yee/viz/EDA_Visual/Dashboard1#1)

# Phase 3 & 4

**Tableau Storyline**

**Ridership Overview:** [Ridership Overview Dashboard](https://public.tableau.com/app/profile/esther.yee/viz/Final_Dashboard_Ridership/RidershipOverview#1)

In the Ridership Overview dashboard, I started with a month-by-month time series of total ridership. As shown, there’s a major dip starting in March 2020, which aligns with the onset of COVID-19. From that point until late 2021, ridership grew rapidly, then leveled off into a steadier increase through December 2024. The drop in January 2025 is just due to limited data — we only have records from the first week.

The second graph displays monthly ridership again, this time broken down by transportation mode. This shows that subway riders consistently make up the largest share, followed by bus riders.

Next is a sparklines chart for each transportation mode. Although each mode is scaled differently (with reference lines provided), we can observe that most modes follow similar overall trends in ridership.

The proportion of ridership by mode per month dives deeper, highlighting percent changes in modal share over time. During the 2020–2021 COVID period, we see that a larger share of ridership came from subways and CitiBikes. This could reflect people avoiding enclosed spaces or opting for more physically distant transit options. From 2021 onward, the monthly percentages fluctuate, but we noticed larger shifts tend to align with seasons, suggesting a seasonal effect on ridership. This leads to us creating the dashboard for Ridership vs. Weather.

**Seasonal and Weather Overview:**
[Seasonal and Weather Dashboard](https://public.tableau.com/app/profile/esther.yee/viz/Final_Dashboard_Weather/RidershipvsWeather#1)

In the first graph of this dashboard, we explored the relationship of ridership by season. We clearly see that ridership drops in both summer and winter, hinting that weather, particularly temperature, could be a factor. We further investigate Ridership vs Temperature in a scatterplot, where each data point represents a day and its color by mode.  We also included a linear regression trend line.  We then extended the exploration of ridership vs. weather further, looking into weather conditions such as rain and snowfall. 

**Findings**

The scatterplots reveals that extreme temperatures correspond with lower ridership overall. CitiBike usage increases on warmer days, while subway and bus ridership remains relatively stable across all temperature ranges. 

We suspected that weather conditions such as rain and snow would negatively impact CitiBike ridership, and this was reflected with noticeable drops as precipitation increases. We also observed that subway, bus, and taxi ridership decline modestly in snowy conditions, though not as sharply as bikes which could indicator that these modes are more weather resilience.

While temperature has a clear effect on active modes like biking, it doesn’t fully explain shifts in the other modes, suggesting that other factors that may also play a role.

**Limitations of the Data, Future Research**

Pandemic Effects: Ridership dropped sharply from April to August 2020, which could distort weather-related trends. From that point until late 2022, we see a period of recovery, but behavior during this time may still reflect pandemic-related disruptions rather than weather alone. Mode shares also shifted, so future analysis could benefit from isolating or adjusting for these months.

Multimodal Overlap: Riders often use more than one mode in a day (e.g., subway then bus), and free transfers plus OMNY rollout make this even easier. Because modes aren’t mutually exclusive, the same rider might be counted more than once, which could blur how weather impacts each mode.

Overlapping Weather Conditions: Weather variables aren’t mutually exclusive as well, for example, cold days often coincide with snowfall, and rainy days may also be windy. These overlaps make it harder to isolate the effect of a single weather factor on ridership.

No Demographics or Pricing: We didn’t have data on rider age, income, or fare changes. These likely influence how people respond to weather (e.g., choosing to bike, walk, or take a taxi during storms or heatwaves).

A more in-depth exploration of limitations and future research can be found here: [limitations of our research](https://mamaroneck-my.sharepoint.com/:w:/g/personal/jwilhelm_mamkschools_org/ESnJUztioSZCu4MONKIh24gBzAY6CcJ9Fthu57SwU-wtdA?e=OQdytQ)

# Notes on the data:
1) MTA Daily Ridership Data
This dataset was clean from the get-go. All we did was import it as a ```VARCHAR``` to ensure landing, and then copied it to a cleaned table with the correct types. One thing to note with this table is that this is the limit when it comes to the dates. The other data sets went further back in time, but this one only went to 2020.

2) Taxi data  
This dataset was in the form of many parquet files. To import the data we used a python script to retreave it and ontother one to convert it to CSV format. Then, using a final script, we landed the raw data in a ```VARCHAR``` table to ensure everything landed. At this point, each row of the data represented a single ride, but we were interested in daily data. To solve this, we aggregated the data into a clean table, grouping the relevant information by date.

3) National Weather Service  
To get this data from the National Weather Service, we had to go to their website and request it; however, due to data limitations, we had to ship it in two separate parts. A consequence of this is that the schema has changed between the two tables. We solved this by normalising the schema of the CSVs using a Python script. We could the copy the data into a ```VARCHAR``` table to ensure eveything landed. At this point, each row of the data represented the reading of a single weather station per day, but we were interested in the average daily data. To solve for this, we aggregated the data into a clean table, grouping the relevant information by date. One column of note was a categorical variable, so special code was required to get the mode of the feature.

4) Citi Bike
To import this data, we used a Python script and then unzipped the files using the terminal. Once the files were unzipped, we used a Python script to copy them into a ```VARCHAR``` table to ensure everything landed. At this point, each row of the data represented a single ride, but we were interested in daily data. To solve this, we aggregated the data into a clean table, grouping the relevant information by date.
