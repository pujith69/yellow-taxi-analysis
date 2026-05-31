with all_months as (
    select * from {{ ref('stg_tlc_jan') }}
    union all
    select * from {{ ref('stg_tlc_feb') }}
    union all
    select * from {{ ref('stg_tlc_mar') }}
)
select
    pickup_at,
    zone_id,
    trip_distance_km,
    fare_amount_usd,
    total_amount_usd
from all_months
where
    fare_amount_usd  > 0
    and fare_amount_usd  < 500
    and trip_distance_km > 0
    and trip_distance_km < 120
    and zone_id between 1 and 263
    and pickup_at is not null
