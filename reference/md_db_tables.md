# List what has been ingested into a Maryland DuckDB database

List what has been ingested into a Maryland DuckDB database

## Usage

``` r
md_db_tables(con)
```

## Arguments

- con:

  Connection from \[md_db()\]

## Value

A tibble with one row per ingested dataset/year: \`dataset\`,
\`filing_year\`, \`n_rows\`, \`download_date\` (the file's "as of"
timestamp), and \`ingested_at\`.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- md_db()
md_db_load(con, "contributions", year = 2025)
md_db_tables(con)
} # }
```
