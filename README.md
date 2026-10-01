# Rental analytics (dbt)

A dbt project modelling rental listings, a daily calendar and an amenities changelog into a listing/day
mart for revenue, occupancy and amenity analysis. Built on DuckDB; the JSON-array handling is behind
adapter-dispatched macros with DuckDB and Snowflake implementations.

## Running it

```bash
python -m venv .venv
source .venv/Scripts/activate        # Windows Git Bash; use .venv/bin/activate on macOS/Linux
pip install -r requirements.txt
dbt deps                             # once, and again after dbt clean or a packages.yml change
pre-commit install                   # once, enables the SQLFluff hook on commit
dbt build                            # loads seeds, builds models, runs tests
```

`profiles.yml` lives in the project root and writes to a local `dev.duckdb`. Each layer builds into its own
schema (`raw`, `stg`, `int`, `marts`). Optionally, set the `USER` environment variable to prefix those schemas
with `dbt_<USER>_` on non-prod targets (see `macros/generate_schema_name.sql`), so developers sharing a warehouse
don't overwrite each other's models; without it the schemas are unprefixed.

DuckDB allows one writer at a time: close any other connection to `dev.duckdb` before running `dbt build`, `sqlfluff` or committing, as the SQLFluff dbt templater also opens the database.

Run the business-problem queries with:

```bash
dbt show -s amenity_revenue
```

```bash
dbt show -s neighbours
```

```bash
dbt show -s long_stay
```

Linting: SQLFluff (`.sqlfluff`) runs as a pre-commit hook on `models/` and `analyses/`.

## Project structure

```
seeds/                raw CSVs -> schema raw
models/
  staging/            one view per source: rename, type, parse JSON, dedupe -> schema stg
  intermediate/       reusable logic (e.g. amenities history as a type 2 SCD) -> schema int
  marts/              analyst-facing tables at a defined grain -> schema marts
  */unit_tests/       dbt unit tests for the models in that layer
  catalogue.md        shared column descriptions, referenced with doc()
analyses/             queries for business problems 1-3
macros/               cross-database helpers and schema naming
tests/                singular data tests
```

## Documentation

Model and column descriptions, tests and lineage are documented in dbt (`schema.yml` files and
`models/catalogue.md`). To browse them:

```bash
dbt docs generate
```

```bash
dbt docs serve
```

## Business problems

| # | Analysis | Approach | Check against brief       |
|---|---|---|---------------------------|
| 1 | `amenity_revenue` | Monthly revenue split by whether the listing had air conditioning *on that day* | July 2022: 21.2% without AC |
| 2 | `neighbours` | Price on 2022-07-11 minus 2021-07-12 per listing, averaged per neighborhood | Back Bay: $44 |
| 3 | `long_stay` | Islands of consecutive free days with a lockbox + first aid kit; every day is tried as a check-in, limited by the days left in the island and that day's `maximum_nights` | Listing 1303261: 159 |

## Data quality findings

- **Listing 276450** has calendar and changelog rows but its listings row has no ID, so it has no name or
  neighborhood. Its days are kept (revenue would be understated otherwise). The `relationships` test on
  `stg_calendar.listing_id` is set to `warn` to keep the gap visible.
- **Test listing**: the listings file contains a fake row ("TESTING LISTING", host -99999, 99 guests, 60 baths,
  $999.99, reviews dated 2025). It also has no ID, so it is removed by the same no-ID filter in `stg_listings`.
- **Duplicate calendar rows**: listing 1303261 on 2022-07-07 appears three times, identical in every column.
  Deduplicated in `stg_calendar`.
- **Availability vs reservations**: every unavailable day has a reservation and no available day has one,
  so `not is_available` and `reservation_id is not null` agree in this data.
- **Partial months**: July 2021 and July 2022 are partial, so their totals are not comparable to full months.
- **Calendar prices** are plain integers, unlike `listings.price` (`$1,234.00` strings).
- **Amenity strings** are lowercased on parse so matching doesn't depend on casing.

## Testing

Tests sit at three levels, each run by `dbt build`:

- **Keys and grain** (generic tests in `schema.yml`): primary keys are unique and not null, the fact is unique
  per listing and day, and each listing has one current amenities version and at most one per day. These
  fail the build: if they break, the output is wrong.
- **Business rules** (singular tests in `tests/`): rules checked on the real data, e.g. no revenue on an
  unoccupied day.
- **Transformation logic** (unit tests in `*/unit_tests/`): fixed inputs with expected outputs for the
  logic most likely to break, such as the SCD validity windows and the point-in-time amenities join.

Known, accepted source gaps use `severity: warn` instead of failing, so they stay visible without stopping
the build (e.g. calendar listings missing from the listings file). `not_null` is only applied where the model
guarantees it (keys and grain), not to source values that could legitimately be null.

## Design decisions and trade-offs

- **Listing/day grain, amenities as of each day.** A listing's current amenities don't describe it on past
  days; the grain supports day, month and year aggregation.
- **Amenities history as a type 2 SCD in intermediate.** One reusable point-in-time lookup for any model; it
  could become incremental if the source exposed a load timestamp.
- **Amenities as an array, not a bridge table.** There are 81 amenities and no basis yet for choosing flag
  columns. A bridge (listing x amenity x validity) would multiply each day about 23x when joined to the fact;
  I'd add one, filtered to a single amenity per join, if per-amenity history were needed.
- **Listing 276450 kept but not patched.** Its days are kept so revenue isn't understated. The listings row
  with no ID is very likely this listing, but a hardcoded fix would hide a source defect, so I'd raise it with
  the source owner instead.
- **Exact duplicates removed in staging.** They're a source defect rather than a business rule; duplicates
  with conflicting values would need a rule and would be resolved in intermediate.
- **`cast`, not `try_cast`, in staging.** A value that can't be converted fails the run instead of silently
  becoming null, and `cast` behaves the same on DuckDB and Snowflake. The literal `'NULL'` strings in
  `reservation_id` are turned into real nulls with `nullif` before casting.
- **Seeds instead of sources**, so the project runs anywhere; in production a loader (e.g. Fivetran) would
  land these as sources. `PRICE` and `RESERVATION_ID` are loaded as text because dbt's type inference fails on
  `$125.00` and literal `'NULL'` values.
- **Explicit output columns in marts.** Calculations happen in a CTE and the final `select` lists the columns,
  so upstream changes only reach analysts when they're added deliberately.
- **Materializations:** views for staging and intermediate, tables for marts; adjustable per model.

## Assumptions and known limitations

### Assumptions

- **Revenue** is the calendar `price` on days with a reservation.
- **Occupancy** uses `is_occupied` (`not is_available`). In this data it matches the brief's "has a
  reservation" exactly, and a singular test keeps revenue and occupancy consistent. If owner-blocked days
  appeared, occupancy should come from the reservation instead.
- **Amenity versions** apply from the change date through the day before the next change (both inclusive),
  assuming at most one change per listing per day (enforced by a test). Days before a listing's first
  change fall back to its current amenities; this doesn't occur in the data.
- **Problem 2** is the per-listing price change between 2021-07-12 and 2022-07-11, averaged per neighborhood
  including unchanged and reduced prices. Listings with no neighborhood (currently only 276450) are excluded.
- **Problem 3** uses the check-in day's `maximum_nights`, and needs both amenities on every night of the stay.

### Known limitations

- **`long_stay`** can understate stays that run past the end of the calendar (2022-07-11), and doesn't apply
  `minimum_nights` (no effect on the results here).
- **Partial months:** July 2021 and July 2022 are partial, so compare them per day rather than by total.
- **Full rebuilds only:** incremental loading would need a load timestamp from the source.

## AI usage

I used AI as I would professionally: as a pair programmer to speed up setup, explore alternatives and review my
work. The modelling decisions are mine, I wrote or directed all of the SQL in the models and analyses, and I
reviewed and verified everything before committing it.

| Area | What I did | How AI helped |
|---|---|---|
| Setup and conventions | Chose DuckDB and seeds so the project runs anywhere; set the conventions: a schema per layer, the optional `dbt_<USER>_` prefix (and simplified its macro), one `schema.yml` per folder and a shared `catalogue.md`. | Installed dbt and DuckDB and set up the initial project config to my conventions. |
| Design | Made the decisions in this README: the grain, the SCD in intermediate and its inclusive end dates, array vs bridge table, deduplicating in staging, keeping 276450, explicit mart columns, and `dim_listings` for quick lookups. | Talked through alternatives with me: snapshot vs SCD, bridge table, star schema vs one wide table, incremental models. |
| Data exploration | Investigated the source data, confirmed each finding with my own queries and decided how to handle it. | Ran profiling queries that helped surface the duplicate calendar rows, listing 276450, the test listing and how availability lines up with reservations. |
| Models and analyses | Wrote the staging, intermediate and fact models and the three analyses; specified `dim_listings` and the later changes (the end-date switch, explicit final selects); fixed the issues found in review, keeping changes targeted. | Reviewed my drafts and flagged bugs, e.g. the revenue condition, the SCD boundary and current-version logic, the Q2 filter and booked periods counted in Q3; implemented changes I specified. |
| Portability | Set Snowflake as the target, checked Snowflake's `try_cast` documentation, and chose dispatch macros over amenity flag columns. | Identified the DuckDB-only SQL and drafted the `parse_json_array` and `array_contains_value` macros to my design. |
| Documentation | Wrote the explanations; required the brief's wording for source columns, descriptive names for shared docs, and user-facing docs without implementation details. | Expanded my notes into model and column descriptions. |
| Tests | Defined what to test and the edge cases, limited `not_null` to keys and grain, set the warn-vs-fail policy and the test naming and layout. | Drafted the unit tests and singular test from my specifications, and showed each fails when the bug it covers is reintroduced. |
| Tooling | Chose SQLFluff with the dbt templater, the rules and fix-on-commit. | Set up the `.sqlfluff`, `.sqlfluffignore` and pre-commit configuration to my choices. |

**How I checked it**
- Every analysis reproduces the example answers in the brief (21.2%, $44, 159).
- `dbt build` runs all data tests and unit tests; SQLFluff lints every model and analysis on commit.
- Data findings were confirmed with my own queries against the source data.
