with

s_listings as (select * from {{ ref('listings') }}),


base as (

    select
        cast(id as integer) as listing_id,
        name as listing_name,
        cast(host_id as integer) as host_id,
        host_name as host_name,
        cast(host_since as timestamp) as host_since,
        host_location as host_location,
        {{ parse_json_array('host_verifications') }} as host_verifications,
        neighborhood as neighborhood,
        property_type as property_type,
        room_type as room_type,
        cast(accommodates as integer) as accommodates,
        bathrooms_text as bathrooms_text,
        cast(bedrooms as integer) as bedrooms,
        cast(beds as integer) as beds,
        {{ parse_json_array('lower(amenities)') }} as amenities,
        cast(replace(replace(price, '$', ''), ',', '') as decimal(10, 2)) as listing_price,
        cast(number_of_reviews as integer) as number_of_reviews,
        cast(first_review as date) as first_review,
        cast(last_review as date) as last_review,
        cast(review_scores_rating as decimal(3, 2)) as review_scores_rating

    from s_listings
    where id is not null

)

select * from base
