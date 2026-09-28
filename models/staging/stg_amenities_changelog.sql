with

    source as (select * from {{ref('amenities_changelog')}}),


    base as (

        select
            try_cast(listing_id as integer) as listing_id,
            try_cast(change_at as timestamp) as changed_at,
            from_json(amenities, '["VARCHAR"]') as amenities

        from source
    )

    select
        {{ dbt_utils.generate_surrogate_key(['listing_id', 'changed_at']) }} as amenities_changelog_id,
        *
    from base
