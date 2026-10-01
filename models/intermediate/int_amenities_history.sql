with

s_amenities as (select * from {{ ref('stg_amenities_changelog') }}),


changes as (

    select
        amenities_changelog_id,
        listing_id,
        amenities,
        cast(changed_at as date) as valid_from,
        coalesce(
            cast(lead(changed_at) over (partition by listing_id order by changed_at) as date) - 1,
            cast('9999-12-31' as date)
        ) as valid_to,
        valid_to = cast('9999-12-31' as date) as is_current

    from s_amenities

)

select *
from changes
