with

    source as (select * from {{ref('listings')}}),


    base as (

        select
            try_cast(id as integer) as listing_id,
            name as listing_name,
            try_cast(host_id as integer) as host_id,
            host_name as host_name,
            try_cast(host_since as timestamp) as host_since,
            host_location as host_location,
            from_json(host_verifications, '["VARCHAR"]') as host_verifications,
            neighborhood as neighborhood,
            property_type as property_type,
            room_type as room_type,
            try_cast(accommodates as integer) as accommodates,
            bathrooms_text as bathrooms_text,
            try_cast(bedrooms as integer) as bedrooms,
            try_cast(beds as integer) as beds,
            from_json(amenities, '["VARCHAR"]') as amenities,
            try_cast(replace(replace(price, '$', ''), ',', '') as decimal(10,2)) as listing_price,
            try_cast(number_of_reviews as integer) as number_of_reviews,
            try_cast(first_review as date) as first_review,
            try_cast(last_review as date) as last_review,
            try_cast(review_scores_rating as decimal(3,2)) as review_scores_rating

        from source
        -- two source rows have no ID: a test listing (host_id -99999) and a listing
        -- that looks like 276450 (see calendar). Without an ID they can't be joined.
        where listing_id is not null
    )

    select * from base
