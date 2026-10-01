with

s_listings as (select * from {{ ref('listings') }}),


base as (

    select
        try_cast(id as integer) as listing_id,
        name as listing_name,
        try_cast(host_id as integer) as host_id,
        host_name,
        try_cast(host_since as timestamp) as host_since,
        host_location,
        {{ parse_json_array('host_verifications') }} as host_verifications,
        neighborhood,
        property_type,
        room_type,
        try_cast(accommodates as integer) as accommodates,
        bathrooms_text,
        try_cast(bedrooms as integer) as bedrooms,
        try_cast(beds as integer) as beds,
        {{ parse_json_array('lower(amenities)') }} as amenities,
        try_cast(replace(replace(price, '$', ''), ',', '') as decimal(10, 2)) as listing_price,
        try_cast(number_of_reviews as integer) as number_of_reviews,
        try_cast(first_review as date) as first_review,
        try_cast(last_review as date) as last_review,
        try_cast(review_scores_rating as decimal(3, 2)) as review_scores_rating

    from s_listings
    where id is not null

)

select * from base
