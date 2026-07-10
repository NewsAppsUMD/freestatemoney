# How to Download Maryland Campaign Finance Data

## Option 1: `md_download()` (recommended)

The package can download bulk data directly from the Maryland SBE’s CRIS
API — the same endpoint the website’s download buttons use:

``` r

library(freestatemoney)

# Current-cycle committee list
committees_path <- md_download("committees")

# Contributions or expenditures for a specific filing year
contributions_path <- md_download("contributions", year = 2025)
expenditures_path <- md_download("expenditures", year = 2025)

# Feed the paths straight into the loaders
committees <- md_committees(committees_path)
```

Notes:

- **File size**: full-cycle contribution and expenditure files can run
  to hundreds of megabytes. Passing a `year` keeps downloads manageable.
- **Available years**: the SBE typically offers the most recent several
  filing years (currently back to 2019). Older years return a “No data”
  error.
- **Committees** are only available as one complete file; `year` is
  ignored.

## Option 2: Manual download

1.  **Visit the download page**:
    <https://campaignfinance.maryland.gov/public/cf/downloads>

2.  **Select your data type**:

    - **Committees**: Registration and metadata for all committees
    - **Contributions and Loans**: All contribution transactions
    - **Expenditures**: All spending transactions (includes IE/EC)

3.  **Select time period**: current cycle or a specific filing year

4.  **Click the download button** to save the CSV file

5.  **Pass the file path** to
    [`md_committees()`](https://newsappsumd.github.io/freestatemoney/reference/md_committees.md),
    [`md_contributions()`](https://newsappsumd.github.io/freestatemoney/reference/md_contributions.md),
    or
    [`md_expenditures()`](https://newsappsumd.github.io/freestatemoney/reference/md_expenditures.md)

## About the raw files

- Each file begins with a metadata line like
  `Committee Download as of 06/14/2026 01:00 AM` before the actual
  header. The loaders skip it automatically and expose the timestamp as
  `attr(df, "download_date")`.
- Values with leading zeros (zip codes) are wrapped for Excel as
  `="21228"`; the loaders unwrap them.
- Amounts are dollar-formatted (`$3,000.00`); the loaders parse them as
  numeric.

## Data Freshness

The Maryland State Board of Elections regenerates the bulk files
periodically (roughly daily) as new reports are filed. The
`download_date` attribute tells you exactly when your file was
extracted.
