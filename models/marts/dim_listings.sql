with

s_listings as (select * from {{ ref('stg_listings') }}),

s_current_amenities as (

    select *
    from {{ ref('int_amenities_history') }}
    where is_current

),


current_listing_state as (

    select
        s_listings.* exclude (amenities),
        coalesce(s_current_amenities.amenities, s_listings.amenities) as amenities

    from s_listings
    left join s_current_amenities
        on s_listings.listing_id = s_current_amenities.listing_id

)

select
    listing_id,
    listing_name,
    host_id,
    host_name,
    host_since,
    host_location,
    host_verifications,
    neighborhood,
    property_type,
    room_type,
    accommodates,
    bathrooms_text,
    bedrooms,
    beds,
    amenities,
    listing_price,
    number_of_reviews,
    first_review,
    last_review,
    review_scores_rating
from current_listing_state
