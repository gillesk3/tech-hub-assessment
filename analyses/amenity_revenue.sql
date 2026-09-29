with ac as (

    select
        date_trunc('month', listing_date) as revenue_month,
        list_contains(amenities, 'air conditioning') as has_ac,
        sum(revenue) as revenue

    from {{ ref('fact_listing') }}
    group by all

)


select
    revenue_month,
    sum(revenue) as total_revenue,
    sum(case when has_ac then revenue else 0 end) as ac_revenue,
    sum(case when not has_ac then revenue else 0 end) as no_ac_revenue,
    round(100 * no_ac_revenue / nullif(total_revenue, 0), 1) as no_ac_pct
from ac
group by revenue_month
order by revenue_month
