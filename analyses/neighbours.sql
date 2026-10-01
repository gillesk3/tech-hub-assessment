with listings as (

    select
        listing_id,
        listing_date,
        neighborhood,
        price

    from {{ ref('fact_listings') }}
    where listing_date = '2021-07-12' or listing_date = '2022-07-11'

),


listing_price_change as (
    select
        listing_id,
        neighborhood,
        lead(price) over (partition by listing_id order by listing_date) - price as price_change
    from listings
)


select
    neighborhood,
    count(*) as listing_count,
    round(avg(price_change), 2) as avg_price_change
from listing_price_change
where
    price_change is not null
    and neighborhood is not null
group by neighborhood
order by neighborhood
