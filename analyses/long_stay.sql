with filtered_listings as (

    select
        listing_id,
        listing_date,
        is_occupied,
        maximum_nights,
        lag(is_occupied) over (partition by listing_id order by listing_date) as prev_is_occupied

    from {{ ref('fact_listing') }}
    where
        {{ array_contains_value('amenities', "'lockbox'") }}
        and {{ array_contains_value('amenities', "'first aid kit'") }}
),


islands_listings as (
    select
        *,
        sum(case when prev_is_occupied is distinct from is_occupied then 1 else 0 end)
            over (partition by listing_id order by listing_date rows between unbounded preceding and current row)
            as island_id
    from filtered_listings

),


unoccupied_listings as (
    select
        listing_id,
        island_id,
        least(count(*), min_by(maximum_nights, listing_date)) as n_stays
    from islands_listings
    where not is_occupied
    group by listing_id, island_id
)

select
    listing_id,
    max(n_stays) as longest_stay
from unoccupied_listings
group by listing_id
order by listing_id
