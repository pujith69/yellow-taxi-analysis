with cleaned as (
    select * from {{ ref('int_tlc_cleaned') }}
),
windowed as (
    select
        zone_id,
        date_trunc('minute', pickup_at)
            - interval (minute(pickup_at) % 15) minute as time_window,
        fare_amount_usd
    from cleaned
)
select
    zone_id,
    time_window,
    count(*)              as trip_count,
    avg(fare_amount_usd)  as avg_fare_usd,
    sum(fare_amount_usd)  as total_fare_usd
from windowed
group by zone_id, time_window
