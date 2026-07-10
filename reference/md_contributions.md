# Load Maryland Contributions and Loans Data

Parses contribution and loan transaction data from the Maryland State
Board of Elections. Returns a tidy data frame with contributor details,
transaction amounts, and dates.

## Usage

``` r
md_contributions(file_path, clean_names = TRUE)
```

## Arguments

- file_path:

  Character string. Path to the local contributions CSV file downloaded
  from Maryland SBE. This parameter is required.

- clean_names:

  Logical. If TRUE (default), converts column names to snake_case. Date
  and amount columns are parsed either way.

## Value

A tibble with contribution and loan data including:

- filing_entity_id: Committee identifier (links to committees)

- committee_name: Name of receiving committee

- committee_type: Type of committee

- contributor_type: Type of contributor (Individual, Business, PAC,
  etc.)

- transaction_type: Type of transaction (contribution, loan, etc.)

- transaction_date: Date of transaction (Date)

- transaction_amount: Amount of transaction (numeric)

- payment_type: Payment method (Cash, Check, Credit Card, etc.)

- fund_type: Fund type (electoral, administrative, compliance)

And additional fields for contributor address, public funding
eligibility, etc. The tibble carries a \`download_date\` attribute with
the file's "as of" timestamp.

## Details

Download the contributions CSV with
\[md_download("contributions")\]\[md_download\], or manually from the
Maryland SBE website at
https://campaignfinance.maryland.gov/public/cf/downloads

The raw file has a metadata line ("Contributions and Loan Download as of
...") before the header; it is skipped automatically and its timestamp
is stored in the \`download_date\` attribute of the result.
Dollar-formatted amounts (\`\$3,000.00\`) are parsed as numeric, and
values wrapped for Excel such as \`="21228"\` (zip codes) are unwrapped
to plain strings.

## Examples

``` r
# Sample data included with the package
contributions <- md_contributions(
  system.file("extdata", "contributions_sample.csv", package = "freestatemoney")
)
head(contributions)
#> # A tibble: 6 × 28
#>   filing_entity_id committee_name          abbreviated_committe…¹ committee_type
#>   <chr>            <chr>                   <chr>                  <chr>         
#> 1 3007773          MSEA's Fund For Childr… NA                     PAC           
#> 2 1012725          Feldmark, Jessica Frie… NA                     Candidate     
#> 3 8015370          International Brotherh… IBEW PAC               Out-of-State …
#> 4 1012725          Feldmark, Jessica Frie… NA                     Candidate     
#> 5 3007773          MSEA's Fund For Childr… NA                     PAC           
#> 6 3007773          MSEA's Fund For Childr… NA                     PAC           
#> # ℹ abbreviated name: ¹​abbreviated_committee_name
#> # ℹ 24 more variables: contributor_type <chr>, contributor_company_name <chr>,
#> #   contributor_last_name <chr>, contributor_first_name <chr>,
#> #   contributor_middle_name <chr>, contributor_mailing_address1 <chr>,
#> #   contributor_mailing_address2 <chr>, contributor_city <chr>,
#> #   contributor_state <chr>, contributor_zip_code <chr>,
#> #   contributor_county_of_residence <chr>, transaction_type <chr>, …

if (FALSE) { # \dontrun{
# Download a single filing year and load it
contributions <- md_contributions(md_download("contributions", year = 2025))

# Filter for large contributions
library(dplyr)
large_contributions <- md_contributions("path/to/contributions.csv") %>%
  filter(transaction_amount >= 500)
} # }
```
