with

s_calendar as (select * from {{ ref('calendar') }}),


base as (

    select
        cast(listing_id as integer) as listing_id,
        cast(date as date) as listing_date,
        cast(available as boolean) as is_available,
        cast(nullif(reservation_id, 'NULL') as integer) as reservation_id,
        cast(price as decimal(10, 2)) as price,
        cast(minimum_nights as integer) as minimum_nights,
        cast(maximum_nights as integer) as maximum_nights

    from s_calendar
    qualify row_number() over (partition by listing_id, date order by listing_id) = 1

)

select
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'listing_date']) }} as calendar_id,
    *
from base
