with

s_listings as (select * from {{ ref('stg_listings') }}),

s_amenities as (select * from {{ ref('int_amenities_history') }}),

s_calendar as (select * from {{ ref('stg_calendar') }}),


listing_days as (

    select
        s_calendar.listing_id,
        s_calendar.listing_date,
        s_listings.listing_name,
        s_listings.neighborhood,
        s_calendar.minimum_nights,
        s_calendar.maximum_nights,
        s_calendar.price,
        not s_calendar.is_available as is_occupied,
        coalesce(s_amenities.amenities, s_listings.amenities) as amenities,
        case when s_calendar.reservation_id is not null then s_calendar.price else 0 end as revenue

    from s_calendar
    left join s_listings
        on s_calendar.listing_id = s_listings.listing_id
    left join s_amenities
        on
            s_calendar.listing_id = s_amenities.listing_id
            and s_calendar.listing_date between s_amenities.valid_from and s_amenities.valid_to

)

select
    listing_id,
    listing_name,
    neighborhood,
    is_occupied,
    minimum_nights,
    maximum_nights,
    amenities,
    price,
    revenue,
    listing_date
from listing_days
