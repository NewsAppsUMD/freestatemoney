# Download Maryland Campaign Finance Data

Downloads a bulk data CSV directly from the Maryland State Board of
Elections Campaign Reporting Information System (CRIS) API - the same
endpoint the download page at
https://campaignfinance.maryland.gov/public/cf/downloads uses.

## Usage

``` r
md_download(
  type = c("committees", "contributions", "expenditures"),
  year = NULL,
  path = NULL,
  quiet = FALSE
)
```

## Arguments

- type:

  Which dataset to download: "committees", "contributions", or
  "expenditures".

- year:

  Optional four-digit filing year (e.g. 2025). If NULL (default),
  downloads the current-cycle file. The SBE typically offers the most
  recent several years.

- path:

  Where to save the CSV. Defaults to a file named after the dataset (and
  year, if given) in the current working directory.

- quiet:

  Logical. If FALSE (default), shows a download progress bar.

## Value

The path to the downloaded CSV file, invisibly suitable for passing
straight to \[md_committees()\], \[md_contributions()\], or
\[md_expenditures()\].

## Details

The contributions and expenditures files for a full cycle can be large
(hundreds of megabytes); passing a \`year\` limits the download to a
single filing year. Committee data is only available as a complete file,
so \`year\` is ignored for \`type = "committees"\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Current-cycle committee list
committees <- md_committees(md_download("committees"))

# Contributions for a single filing year
contributions <- md_contributions(md_download("contributions", year = 2025))
} # }
```
