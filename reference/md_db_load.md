# Ingest a Maryland dataset into a DuckDB database

Loads a CRIS bulk CSV into a table in a database opened with
\[md_db()\], applying the same parsing as the in-memory loaders — the
metadata line is skipped, column names are cleaned to snake_case, dates
and dollar amounts are typed, and Excel armor (\`="21228"\`) is stripped
— but inside DuckDB, so the file never has to fit in R's memory.

## Usage

``` r
md_db_load(
  con,
  type = c("committees", "contributions", "expenditures"),
  year = NULL,
  file = NULL,
  quiet = FALSE
)
```

## Arguments

- con:

  Connection from \[md_db()\]

- type:

  Which dataset: "committees", "contributions", or "expenditures". Used
  as the table name.

- year:

  Optional four-digit filing year, passed to \[md_download()\] when
  downloading and used as the \`filing_year\` tag.

- file:

  Optional path to an already-downloaded CSV. If NULL, the data is
  downloaded via \[md_download()\] to a temporary file.

- quiet:

  Logical. If FALSE (default), shows a download progress bar.

## Value

The lazy table (\`dplyr::tbl(con, type)\`), invisibly.

## Details

Each ingest is tagged with a \`filing_year\` column (\`"current"\` when
\`year\` is NULL). Ingesting the same dataset and year again replaces
that year's rows, so refreshes are idempotent; different years
accumulate. Provenance (row counts, the file's "as of" timestamp) is
recorded and visible via \[md_db_tables()\].

## Examples

``` r
if (FALSE) { # \dontrun{
con <- md_db()
md_db_load(con, "expenditures", year = 2025)
md_db_load(con, "expenditures", file = "already_downloaded.csv")
} # }
```
