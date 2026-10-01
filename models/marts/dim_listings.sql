with

s_listings as (select * from {{ ref('stg_listings') }}),

s_current_amenities as (

    select *
    from {{ ref('int_amenities_history') }}
    where is_current

),


current_listing_state as (

    select
        s_listings.listing_id,
        s_listings.listing_name,
        s_listings.host_id,
        s_listings.host_name,
        s_listings.host_location,
        s_listings.host_verifications,
        s_listings.neighborhood,
        s_listings.property_type,
        s_listings.room_type,
        s_listings.accommodates,
        s_listings.bathrooms_text,
        s_listings.bedrooms,
        s_listings.beds,
        coalesce(s_current_amenities.amenities, s_listings.amenities) as amenities,
        s_listings.listing_price,
        s_listings.number_of_reviews,
        s_listings.last_review,
        s_listings.review_scores_rating

    from s_listings
    left join s_current_amenities
        on s_listings.listing_id = s_current_amenities.listing_id

)

select * from current_listing_state
