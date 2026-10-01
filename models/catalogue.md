# Column catalogue

Shared column definitions. Reference them from any `schema.yml` with
`description: "{{ doc('<name>') }}"` so each definition is written once.

{% docs calendar_id %}
Surrogate primary key for a calendar row, generated from listing_id and listing_date.
{% enddocs %}

{% docs listing_id %}
Unique ID for the listing to which this row applies. Part of the Primary Key.
{% enddocs %}

{% docs listing_date %}
Date of availability this row describes. Part of the Primary Key.
{% enddocs %}

{% docs is_available %}
Contains 't' if this property is available on this date. Contains 'f' if not.
{% enddocs %}

{% docs reservation_id %}
Unique ID for that DATE's reservation. Foreign key. If NULL, there was no reservation on that date.
{% enddocs %}

{% docs calendar_price %}
The USD price to rent this property on DATE.
{% enddocs %}

{% docs minimum_nights %}
The minimum number of nights that must be booked consecutively for this property.
{% enddocs %}

{% docs maximum_nights %}
The maximum number of nights that may be booked consecutively for this property.
{% enddocs %}

{% docs listings_listing_id %}
Unique ID for this listing. Primary Key.
{% enddocs %}

{% docs listing_name %}
Display name of listing.
{% enddocs %}

{% docs host_id %}
Unique ID for the Host who owns this property.
{% enddocs %}

{% docs host_name %}
Display name of Host.
{% enddocs %}

{% docs host_since %}
When the Host signed up.
{% enddocs %}

{% docs host_location %}
Where the Host is based.
{% enddocs %}

{% docs host_verifications %}
(Parseable as JSON) Array of methods the Host can use to verify.
{% enddocs %}

{% docs neighborhood %}
The neighborhood where this listing is located.
{% enddocs %}

{% docs property_type %}
Description of the type of property.
{% enddocs %}

{% docs room_type %}
Description of the type of room.
{% enddocs %}

{% docs accommodates %}
Number of guests this room can accommodate.
{% enddocs %}

{% docs bathrooms_text %}
Number and types of bathrooms available.
{% enddocs %}

{% docs bedrooms %}
Number of bedrooms available for use.
{% enddocs %}

{% docs beds %}
Number of beds available for use.
{% enddocs %}

{% docs listings_amenities %}
(Parseable as JSON) Array of amenities available for guests.
{% enddocs %}

{% docs listing_price %}
The price of this listing as of the start of the date range in CALENDAR.
{% enddocs %}

{% docs number_of_reviews %}
The number of reviews this listing has ever received.
{% enddocs %}

{% docs first_review %}
The date of the first review this listing received.
{% enddocs %}

{% docs last_review %}
The date of the most recent review this listing received.
{% enddocs %}

{% docs review_scores_rating %}
The average review score of this listing.
{% enddocs %}

{% docs amenities_changelog_id %}
Surrogate primary key for an amenities change, generated from listing_id and changed_at.
{% enddocs %}

{% docs amenities_changed_at %}
When the amenities list changed.
{% enddocs %}

{% docs changelog_amenities %}
(Parseable as JSON) Array of the amenities available as of the change.
{% enddocs %}

{% docs amenities_valid_from %}
Start of the period this amenities version applies to (inclusive). Equal to the changelog's changed_at.
{% enddocs %}

{% docs amenities_valid_to %}
End of the period this amenities version applies to (exclusive): the next change for the same listing,
or 9999-12-31 for the current version. Join with `date >= valid_from and date < valid_to`.
{% enddocs %}

{% docs amenities_is_current %}
True for the latest amenities version of each listing (valid_to = 9999-12-31).
{% enddocs %}

{% docs is_occupied %}
True if the listing was not available on this date. In this data every unavailable day has a reservation,
so this is the occupancy flag: average it over days to get the occupancy rate.
{% enddocs %}

{% docs calendar_revenue %}
Price earned on this date: the calendar price when the day has a reservation, otherwise 0.
Sum this for revenue. Do not sum `price`, which is set on every day whether it was booked.
{% enddocs %}

{% docs fact_amenities %}
Amenities the listing had on this date. Taken from the amenities changelog version valid on that day;
a listing is not guaranteed to have changelog history, so where no version covers the day this falls
back to the listing's current amenities from the listings table. Values are lowercase, e.g. 'air conditioning'.
{% enddocs %}
