with

s_amenities as (select * from {{ ref('stg_amenities_changelog') }}),


changes as (

    select
        amenities_changelog_id,
        listing_id,
        amenities,
        changed_at as valid_from,
        coalesce(lead(changed_at) over (partition by listing_id order by changed_at), '9999-12-31') as valid_to

    from s_amenities

)

select
    *,
    valid_to = '9999-12-31' as is_current
from changes
