
<!-- README.md is generated from README.Rmd. Please edit that file -->

# freestatemoney

<!-- badges: start -->

[![R-CMD-check](https://github.com/NewsAppsUMD/freestatemoney/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/NewsAppsUMD/freestatemoney/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`freestatemoney` is an R package for downloading, loading, and parsing
campaign finance data from Maryland. It works with data from the
Maryland State Board of Elections Campaign Reporting Information System
(CRIS), returning tidy data frames ready for analysis.

## Installation

You can install the development version of freestatemoney from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("NewsAppsUMD/freestatemoney")
```

## Getting Data

`md_download()` fetches bulk data directly from the SBE’s CRIS API — the
same data the download page at
<https://campaignfinance.maryland.gov/public/cf/downloads> serves:

``` r
library(freestatemoney)

# Current-cycle committee list
committees <- md_committees(md_download("committees"))

# Contributions for a single filing year (full-cycle files can be very large)
contributions <- md_contributions(md_download("contributions", year = 2025))

# Expenditures for a single filing year
expenditures <- md_expenditures(md_download("expenditures", year = 2025))
```

Or grab everything at once:

``` r
md <- md_load_all(year = 2025)
```

You can also download CSV files manually from the SBE website and pass
their paths to the loader functions. See
[DOWNLOAD_INSTRUCTIONS.md](DOWNLOAD_INSTRUCTIONS.md) for details.

## Data Sources

All data comes from the Maryland State Board of Elections Campaign
Reporting Information System (CRIS):
<https://campaignfinance.maryland.gov/public/cf/downloads>

The package provides access to three main datasets:

1.  **Committees**: Registration and metadata for all campaign finance
    committees
2.  **Contributions and Loans**: Individual contribution and loan
    transactions
3.  **Expenditures**: Spending transactions including expenditures,
    outstanding obligations, and independent expenditures

## Usage

### Load Committee Data

``` r
library(freestatemoney)

# Load committee registration data from a downloaded file
committees <- md_committees("CommitteeList.csv")

# View structure
head(committees)
```

### Load Contribution Data

``` r
library(freestatemoney)
library(dplyr)

# Load contributions from a downloaded file
contributions <- md_contributions("ContributionsList.csv")

# Find large contributions
large_contributions <- contributions %>%
  filter(transaction_amount >= 500) %>%
  arrange(desc(transaction_amount))
```

### Load Expenditure Data

``` r
library(freestatemoney)
library(dplyr)

# Load expenditures from a downloaded file
expenditures <- md_expenditures("ExpendituresList.csv")

# Summarize spending by category
spending_summary <- expenditures %>%
  group_by(category) %>%
  summarize(
    total_amount = sum(transaction_amount, na.rm = TRUE),
    transaction_count = n()
  ) %>%
  arrange(desc(total_amount))

# Filter for Independent Expenditures
independent_expenditures <- expenditures %>%
  filter(transaction_type == "Independent Expenditure")
```

### Built-in Analysis Helpers

``` r
md <- md_load_all(year = 2025)

# Fundraising and spending totals per committee
md_committee_summary(md$committees, md$contributions, md$expenditures)

# Largest donors
md_top_contributors(md$contributions, n = 25)

# Independent expenditure / electioneering communication spending
md_independent_expenditures(md$expenditures)
```

### Working with Large Files

Full-cycle transaction files run to hundreds of megabytes. The `md_db()`
family (requires the suggested duckdb and DBI packages) ingests bulk
data into a persistent DuckDB database once, then queries it lazily —
only results come into R:

``` r
con <- md_db("maryland.duckdb")
md_db_load(con, "contributions", year = 2024)
md_db_load(con, "contributions", year = 2025)

dplyr::tbl(con, "contributions") |>
  dplyr::filter(transaction_amount >= 1000) |>
  dplyr::collect()

DBI::dbDisconnect(con)
```

See the “Working with Large Files via DuckDB” vignette for the full
workflow.

### Combining Datasets

``` r
library(freestatemoney)
library(dplyr)

committees <- md_committees(md_download("committees"))
contributions <- md_contributions(md_download("contributions", year = 2025))

# Join to add committee details to contributions
contributions_with_details <- contributions %>%
  left_join(
    committees %>% select(filing_entity_id, election),
    by = "filing_entity_id"
  )

# Analyze contributions by committee type
by_committee_type <- contributions_with_details %>%
  group_by(committee_type) %>%
  summarize(
    total_raised = sum(transaction_amount, na.rm = TRUE),
    avg_contribution = mean(transaction_amount, na.rm = TRUE),
    num_contributions = n()
  )
```

## Key Features

- **Direct downloads**: `md_download()` pulls bulk data straight from
  the CRIS API
- **Tidy Data**: All functions return tibbles with clean column names
- **Type Safety**: Dates are parsed as Date objects, dollar-formatted
  amounts as numeric
- **CRIS quirks handled**: The metadata line before the header is
  skipped (and exposed as the `download_date` attribute), and
  Excel-armored values like `="21228"` are unwrapped
- **Wrong-file detection**: Passing a contributions file to
  `md_committees()` produces a helpful error instead of a broken data
  frame

## Column Naming

By default, all functions convert column names to snake_case (e.g.,
`filing_entity_id`, `transaction_amount`). You can disable this by
setting `clean_names = FALSE`; date and amount columns are still parsed:

``` r
# With clean names (default)
committees <- md_committees("path/to/file.csv", clean_names = TRUE)

# With original column names
committees_raw <- md_committees("path/to/file.csv", clean_names = FALSE)
```

## Development

To set up for development:

``` r
# Install development dependencies
install.packages(c("devtools", "roxygen2", "testthat"))

# Load package for development
devtools::load_all()

# Generate documentation
devtools::document()

# Run tests
devtools::test()

# Check package
devtools::check()
```

## License

MIT License - Copyright (c) 2026 NewsAppsUMD

## Data Notes

- **Filing Entity ID** is the unique identifier that links all three
  datasets
- Some fields may be nullable/NA depending on the transaction or
  committee type
- Lump sum contributions have blank contributor details
- Independent Expenditure transactions have additional fields for
  candidate/ballot issue information
- Date format in source files is MM/DD/YYYY; amounts are
  dollar-formatted (e.g. `$3,000.00`)
- Each raw file begins with a “… Download as of” metadata line; the
  parsed timestamp is available as `attr(df, "download_date")`
