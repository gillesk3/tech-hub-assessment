with

s_amenities as (select * from {{ ref('stg_amenities_changelog') }}),


changes as (

    select
        amenities_changelog_id,
        listing_id,
        amenities,
        changed_at as valid_from,
        coalesce(
            lead(changed_at) over (partition by listing_id order by changed_at),
            cast('9999-12-31' as timestamp)
        ) as valid_to,
        valid_to = cast('9999-12-31' as timestamp) as is_current

    from s_amenities

)

select *
from changes
