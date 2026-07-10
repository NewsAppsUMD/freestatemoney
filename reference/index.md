# Package index

## Get data

Download bulk data from the Maryland SBE CRIS API

- [`md_download()`](https://newsappsumd.github.io/freestatemoney/reference/md_download.md)
  : Download Maryland Campaign Finance Data
- [`md_load_all()`](https://newsappsumd.github.io/freestatemoney/reference/md_load_all.md)
  : Download and load all three Maryland datasets at once

## Load data

Parse downloaded CSV files into tidy tibbles

- [`md_committees()`](https://newsappsumd.github.io/freestatemoney/reference/md_committees.md)
  : Load Maryland Committee Data
- [`md_contributions()`](https://newsappsumd.github.io/freestatemoney/reference/md_contributions.md)
  : Load Maryland Contributions and Loans Data
- [`md_expenditures()`](https://newsappsumd.github.io/freestatemoney/reference/md_expenditures.md)
  : Load Maryland Expenditures, Outstanding Obligations, and IE/EC Data

## Analyze

Common reporting questions

- [`md_committee_summary()`](https://newsappsumd.github.io/freestatemoney/reference/md_committee_summary.md)
  : Summarize fundraising and spending by committee
- [`md_top_contributors()`](https://newsappsumd.github.io/freestatemoney/reference/md_top_contributors.md)
  : Rank contributors by total amount given
- [`md_independent_expenditures()`](https://newsappsumd.github.io/freestatemoney/reference/md_independent_expenditures.md)
  : Summarize independent expenditures and electioneering communications

## Big data

DuckDB-backed workflow for large or multi-year files

- [`md_db()`](https://newsappsumd.github.io/freestatemoney/reference/md_db.md)
  : Open a DuckDB database for Maryland campaign finance data
- [`md_db_load()`](https://newsappsumd.github.io/freestatemoney/reference/md_db_load.md)
  : Ingest a Maryland dataset into a DuckDB database
- [`md_db_tables()`](https://newsappsumd.github.io/freestatemoney/reference/md_db_tables.md)
  : List what has been ingested into a Maryland DuckDB database

## Package

- [`freestatemoney`](https://newsappsumd.github.io/freestatemoney/reference/freestatemoney-package.md)
  [`freestatemoney-package`](https://newsappsumd.github.io/freestatemoney/reference/freestatemoney-package.md)
  : freestatemoney: Load and Parse Maryland Campaign Finance Data
