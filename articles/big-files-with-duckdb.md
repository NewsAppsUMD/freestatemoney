# Working with Large Files via DuckDB

Full-cycle CRIS transaction files are large — a single year of
contributions runs to hundreds of megabytes — and multi-year analyses
multiply that. The
[`md_db()`](https://newsappsumd.github.io/freestatemoney/reference/md_db.md)
family ingests bulk data into a persistent [DuckDB](https://duckdb.org/)
database instead of an in-memory tibble: you download and parse once,
query lazily with dplyr, and only your results ever come into R.

These functions need the suggested packages duckdb and DBI
(`install.packages(c("duckdb", "DBI"))`).

``` r

library(freestatemoney)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Building a database

[`md_db()`](https://newsappsumd.github.io/freestatemoney/reference/md_db.md)
opens (or creates) a database file;
[`md_db_load()`](https://newsappsumd.github.io/freestatemoney/reference/md_db_load.md)
downloads a dataset and ingests it. Different years accumulate;
re-ingesting a year replaces it, so refreshes are idempotent:

``` r

con <- md_db("maryland.duckdb")

md_db_load(con, "committees")
md_db_load(con, "contributions", year = 2024)
md_db_load(con, "contributions", year = 2025)
md_db_load(con, "expenditures", year = 2025)
```

Because the database file persists, later sessions just reopen it — no
re-downloading:

``` r

con <- md_db("maryland.duckdb")
md_db_tables(con)
```

For this vignette we build a throwaway database from the sample data
shipped with the package:

``` r

sample_file <- function(name) {
  system.file("extdata", name, package = "freestatemoney")
}

con <- md_db(tempfile(fileext = ".duckdb"))
#> duckdb: caching downloaded extensions in the package library:
#> ℹ /home/runner/work/_temp/Library/duckdb/extensions
#> ℹ This is removed when the package is re-installed; see `?duckdb_storage` to choose a different location.
md_db_load(con, "committees", file = sample_file("committees_sample.csv"))
md_db_load(con, "contributions", file = sample_file("contributions_sample.csv"))
md_db_tables(con)
#> # A tibble: 2 × 5
#>   dataset       filing_year n_rows download_date       ingested_at        
#>   <chr>         <chr>        <dbl> <dttm>              <dttm>             
#> 1 committees    current          8 2026-06-14 01:00:00 2026-07-10 11:14:56
#> 2 contributions current          8 2026-07-06 01:00:00 2026-07-10 11:14:56
```

## Querying with dplyr

[`dplyr::tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) gives a
lazy table: filters, joins, and aggregations compile to SQL and run
inside DuckDB. Data only enters R when you
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html):

``` r

contributions <- tbl(con, "contributions")

contributions |>
  group_by(contributor_type) |>
  summarize(
    total = sum(transaction_amount, na.rm = TRUE),
    n = n()
  ) |>
  arrange(desc(total)) |>
  collect()
#> # A tibble: 2 × 3
#>   contributor_type             total     n
#>   <chr>                        <dbl> <dbl>
#> 1 Business/Group/Organization 3000       1
#> 2 Individual                    42.2     7
```

Joins across datasets work the same way, entirely inside the database
(the two sample files happen to cover different committees, so this join
is empty here; with real full-year downloads every committee matches):

``` r

tbl(con, "contributions") |>
  inner_join(
    tbl(con, "committees") |> select(filing_entity_id, office_sought),
    by = "filing_entity_id"
  ) |>
  count(office_sought) |>
  collect()
#> # A tibble: 0 × 2
#> # ℹ 2 variables: office_sought <chr>, n <dbl>
```

The `filing_year` column added at ingest lets multi-year analyses group
by year:

``` r

tbl(con, "contributions") |>
  group_by(filing_year) |>
  summarize(total_raised = sum(transaction_amount, na.rm = TRUE)) |>
  collect()
```

## Parsing parity with the loaders

Ingestion applies the same treatment as
[`md_contributions()`](https://newsappsumd.github.io/freestatemoney/reference/md_contributions.md)
and friends: the metadata line is skipped, names are cleaned to
snake_case, dates and dollar amounts are typed, Excel armor is stripped,
and CRIS export defects (bare line breaks inside fields, Windows-1252
bytes, truncated or over-long records) are repaired identically. A query
against the database returns the same values a tibble would:

``` r

tbl(con, "contributions") |>
  select(transaction_date, transaction_amount, contributor_zip_code) |>
  head(3) |>
  collect()
#> # A tibble: 3 × 3
#>   transaction_date transaction_amount contributor_zip_code
#>   <date>                        <dbl> <chr>               
#> 1 2024-11-20                      3.6 21228               
#> 2 2024-06-25                     10   21044               
#> 3 2025-05-16                   3000   21044
```

## Cleaning up

``` r

DBI::dbDisconnect(con)
```

The `.duckdb` file remains on disk for next time (delete it like any
file if you’re done with it).
