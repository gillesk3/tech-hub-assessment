with

s_calendar as (select * from {{ ref('calendar') }}),


base as (

    select
        try_cast(listing_id as integer) as listing_id,
        try_cast(date as date) as listing_date,
        try_cast(available as boolean) as is_available,
        try_cast(reservation_id as integer) as reservation_id,
        try_cast(price as decimal(10, 2)) as price,
        try_cast(minimum_nights as integer) as minimum_nights,
        try_cast(maximum_nights as integer) as maximum_nights

    from s_calendar
    qualify row_number() over (partition by listing_id, date order by listing_id) = 1

)

select
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'listing_date']) }} as calendar_id,
    *
from base
