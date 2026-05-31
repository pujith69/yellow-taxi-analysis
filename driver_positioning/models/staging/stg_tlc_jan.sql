select
    cast(tpep_pickup_datetime as timestamp) as pickup_at,
    cast(PULocationID as integer)           as zone_id,
    cast(trip_distance as double)           as trip_distance_km,
    cast(fare_amount as double)             as fare_amount_usd,
    cast(total_amount as double)            as total_amount_usd
from read_parquet('data/yellow_tripdata_2025-01.parquet')
