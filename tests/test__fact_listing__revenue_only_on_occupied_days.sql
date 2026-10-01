-- Revenue is earned only on days with a booking: an unoccupied day must have no revenue.
-- Returns the offending rows; the test fails if any are returned.

select
    listing_id,
    listing_date,
    is_occupied,
    revenue
from {{ ref('fact_listing') }}
where
    not is_occupied
    and revenue <> 0
