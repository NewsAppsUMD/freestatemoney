# freestatemoney 0.2.0

## New features

* New DuckDB-backed workflow for large and multi-year files: `md_db()` opens
  a persistent database, `md_db_load()` downloads and ingests a dataset/year
  (idempotently — re-ingesting a year replaces it), and `md_db_tables()`
  reports what is loaded, with provenance. Query lazily with `dplyr::tbl()`.
  Requires the suggested duckdb and DBI packages. See the "Working with
  Large Files via DuckDB" vignette.
* Loaders (and the DuckDB ingest) now repair defects found in real CRIS
  exports: bare line breaks inside unquoted fields (which split rows in
  every CSV parser), Windows-1252 bytes appearing beyond encoding-sniffing
  windows, and records with missing or extra fields. Both paths produce
  identical results, verified against full-year files.

* New `md_download()` downloads bulk data directly from the Maryland SBE CRIS
  API — no more manual clicking through the downloads page. Supports the
  current cycle or a specific filing year. `md_load_all()` downloads and
  loads all three datasets in one call.
* New analysis helpers: `md_committee_summary()` totals fundraising and
  spending per committee, `md_top_contributors()` ranks donors, and
  `md_independent_expenditures()` summarizes IE/EC spending by target and
  position.
* New vignette, "Analyzing Maryland Campaign Finance Data", runnable against
  sample CRIS data now included in `inst/extdata`.
* pkgdown site configuration and deploy workflow.
* Loaders now detect when a file from the wrong dataset is passed (e.g. a
  contributions CSV given to `md_committees()`) and error with a pointer to
  the right function.
* The "... Download as of" timestamp from each raw file is exposed as the
  `download_date` attribute on the returned tibble.

## Bug fixes

* Loaders now actually parse real CRIS files. Previously the metadata line
  that precedes the header was treated as the header, column type
  specifications never matched the Title Case headers, and dollar-formatted
  amounts could not be read as numeric. Dates are now returned as `Date` and
  amounts as `numeric`, whether or not `clean_names` is used.
* Excel formula armor on values with leading zeros (e.g. zip codes stored as
  `="21228"`) is stripped.
* Files are read with their detected encoding (CRIS files are typically
  Windows-1252, not UTF-8).

## Housekeeping

* Placeholder tests replaced with a real suite driven by fixture files taken
  from actual CRIS downloads.
* Removed unused dependencies (`dplyr`, `tibble`); `httr` is now used by
  `md_download()`.
* Documentation (`man/`) is now generated; added GitHub Actions R CMD check.

# freestatemoney 0.1.0

* Initial version.
