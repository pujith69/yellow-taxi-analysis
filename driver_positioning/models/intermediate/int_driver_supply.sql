with agg as (
    select * from {{ ref('int_demand_agg') }}
)
select
    zone_id,
    time_window,
    trip_count,
    avg_fare_usd,
    total_fare_usd,
    greatest(ceil(trip_count / 0.75), 1) as est_drivers,
    (trip_count * avg_fare_usd) / greatest(ceil(trip_count / 0.75), 1)
        as per_driver_revenue_usd
from agg
