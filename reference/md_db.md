# Open a DuckDB database for Maryland campaign finance data

Creates (or reopens) a persistent DuckDB database to hold CRIS bulk
data. Use this when files are too large to work with comfortably in
memory — full-cycle contribution files run to hundreds of megabytes, and
multi-year analyses multiply that. Ingest data once with
\[md_db_load()\], then query lazily with \`dplyr::tbl()\`; only your
results ever come into R.

## Usage

``` r
md_db(path = "freestatemoney.duckdb")
```

## Arguments

- path:

  Path for the DuckDB database file (default \`"freestatemoney.duckdb"\`
  in the working directory). Created if it does not exist; reopened with
  previously ingested data intact otherwise.

## Value

A DBI connection to the database. Close it with \`DBI::dbDisconnect()\`
when finished.

## Details

Requires the suggested packages duckdb and DBI:
\`install.packages(c("duckdb", "DBI"))\`.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- md_db("maryland.duckdb")
md_db_load(con, "contributions", year = 2024)
md_db_load(con, "contributions", year = 2025)

dplyr::tbl(con, "contributions") |>
  dplyr::filter(transaction_amount >= 1000) |>
  dplyr::collect()

DBI::dbDisconnect(con)
} # }
```
