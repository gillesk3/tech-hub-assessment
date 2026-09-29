with stay as (

    select
        listing_id,
        listing_date,
        is_occupied,
        maximum_nights,
        lag(is_occupied) over (partition by listing_id order by listing_date) as prev_is_occupied

    from {{ ref('fact_listing') }}
    where
        list_contains(amenities, 'lockbox') and list_contains(amenities, 'first aid kit')
),


islands as (
    select
        *,
        sum(case when prev_is_occupied is distinct from is_occupied then 1 else 0 end)
            over (partition by listing_id order by listing_date rows between unbounded preceding and current row)
            as island_id
    from stay

),


listing_stays as (
    select
        listing_id,
        island_id,
        least(count(*), arg_min(maximum_nights, listing_date)) as n_stays
    from islands
    where not is_occupied
    group by 1, 2
)

select
    listing_id,
    max(n_stays) as longest_stay
from listing_stays
group by listing_id
order by listing_id
