with supply as (
    select * from {{ ref('int_driver_supply') }}
),
time_features as (
    select
        zone_id, time_window, trip_count, avg_fare_usd,
        per_driver_revenue_usd, est_drivers,
        sin(2 * pi() * extract(hour from time_window) / 24)  as hour_sin,
        cos(2 * pi() * extract(hour from time_window) / 24)  as hour_cos,
        sin(2 * pi() * extract(dow  from time_window) / 7)   as weekday_sin,
        cos(2 * pi() * extract(dow  from time_window) / 7)   as weekday_cos,
        sin(2 * pi() * extract(month from time_window) / 12) as month_sin,
        cos(2 * pi() * extract(month from time_window) / 12) as month_cos
    from supply
),
with_lags as (
    select *,
        lag(trip_count, 1)  over (partition by zone_id order by time_window) as lag_1,
        lag(trip_count, 2)  over (partition by zone_id order by time_window) as lag_2,
        lag(trip_count, 4)  over (partition by zone_id order by time_window) as lag_4,
        lag(trip_count, 8)  over (partition by zone_id order by time_window) as lag_8,
        lag(trip_count, 96) over (partition by zone_id order by time_window) as lag_96
    from time_features
),
with_rolling as (
    select *,
        avg(lag_1) over (partition by zone_id order by time_window
            rows between 3 preceding and current row)  as rolling_mean_4,
        stddev(lag_1) over (partition by zone_id order by time_window
            rows between 3 preceding and current row)  as rolling_std_4,
        avg(lag_1) over (partition by zone_id order by time_window
            rows between 95 preceding and current row) as rolling_mean_96
    from with_lags
)
select
    trip_count,
    zone_id           as "PULocationID",
    time_window,
    avg_fare_usd,
    per_driver_revenue_usd,
    est_drivers,
    hour_sin, hour_cos,
    weekday_sin, weekday_cos,
    month_sin, month_cos,
    lag_1, lag_2, lag_4, lag_8, lag_96,
    rolling_mean_4, rolling_std_4, rolling_mean_96
from with_rolling
where
    lag_1          is not null
    and lag_96         is not null
    and rolling_mean_4  is not null
    and rolling_mean_96 is not null
