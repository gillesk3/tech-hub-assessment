with filtered_listings as (

    select
        listing_id,
        listing_date,
        maximum_nights,
        not is_occupied
        and {{ array_contains_value('amenities', "'lockbox'") }}
        and {{ array_contains_value('amenities', "'first aid kit'") }} as is_bookable,
        lag(is_bookable) over (partition by listing_id order by listing_date) as prev_is_bookable

    from {{ ref('fact_listings') }}
),


islands_listings as (
    select
        *,
        sum(case when prev_is_bookable is distinct from is_bookable then 1 else 0 end)
            over (partition by listing_id order by listing_date rows between unbounded preceding and current row)
            as island_id
    from filtered_listings

),


unoccupied_listings as (
    select
        listing_id,
        island_id,
        least(
            count(*) over (
                partition by listing_id, island_id order by listing_date
                rows between current row and unbounded following
            ),
            maximum_nights
        ) as n_stays
    from islands_listings
    where is_bookable
)

select
    listing_id,
    max(n_stays) as longest_stay
from unoccupied_listings
group by listing_id
order by listing_id
