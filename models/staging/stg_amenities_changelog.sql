with

s_amenities_changelog as (select * from {{ ref('amenities_changelog') }}),


base as (

    select
        try_cast(listing_id as integer) as listing_id,
        try_cast(change_at as timestamp) as changed_at,
        list_transform(from_json(amenities, '["VARCHAR"]'), lambda x: lower(x)) as amenities
    from s_amenities_changelog

)

select
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'changed_at']) }} as amenities_changelog_id,
    *
from base
