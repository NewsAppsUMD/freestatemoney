# Load Maryland Expenditures, Outstanding Obligations, and IE/EC Data

Parses expenditure transaction data from the Maryland State Board of
Elections. Returns a tidy data frame with payee details, transaction
amounts, purposes, and categories. Includes regular expenditures,
outstanding obligations, independent expenditures (IE), and
electioneering communications (EC).

## Usage

``` r
md_expenditures(file_path, clean_names = TRUE)
```

## Arguments

- file_path:

  Character string. Path to the local expenditures CSV file downloaded
  from Maryland SBE. This parameter is required.

- clean_names:

  Logical. If TRUE (default), converts column names to snake_case. Date
  and amount columns are parsed either way.

## Value

A tibble with expenditure data including:

- filing_entity_id: Committee identifier (links to committees)

- committee_name: Name of spending committee

- committee_type: Type of committee

- transaction_type: Type (Expenditure, Outstanding Obligation, IE, EC)

- payee_type: Type of payee (Business, Self, Candidate, PAC, etc.)

- transaction_date: Date of transaction (Date)

- transaction_amount: Amount of transaction (numeric)

- category: Expenditure category

- purpose: Purpose of expenditure

- fund_type: Fund type (electoral, administrative, compliance)

And additional fields for vendor information, IE-specific fields, etc.
The tibble carries a \`download_date\` attribute with the file's "as of"
timestamp.

## Details

Download the expenditures CSV with
\[md_download("expenditures")\]\[md_download\], or manually from the
Maryland SBE website at
https://campaignfinance.maryland.gov/public/cf/downloads

The raw file has a metadata line ("Expenditure Download as of ...")
before the header; it is skipped automatically and its timestamp is
stored in the \`download_date\` attribute of the result.
Dollar-formatted amounts (\`\$1,320.00\`) are parsed as numeric, and
values wrapped for Excel such as \`="20814"\` (zip codes) are unwrapped
to plain strings.

## Examples

``` r
# Sample data included with the package
expenditures <- md_expenditures(
  system.file("extdata", "expenditures_sample.csv", package = "freestatemoney")
)
head(expenditures)
#> # A tibble: 6 × 37
#>   filing_entity_id committee_name          abbreviated_committe…¹ committee_type
#>   <chr>            <chr>                   <chr>                  <chr>         
#> 1 1014521          Bienenfeld, Paula Frie… NA                     Candidate     
#> 2 13014810         Casa in Action PAC      NA                     Super PAC     
#> 3 13014810         Casa in Action PAC      NA                     Super PAC     
#> 4 13014810         Casa in Action PAC      NA                     Super PAC     
#> 5 13014810         Casa in Action PAC      NA                     Super PAC     
#> 6 1009852          Bhandari, Harry (H.B.)… NA                     Candidate     
#> # ℹ abbreviated name: ¹​abbreviated_committee_name
#> # ℹ 33 more variables: payee_type <chr>, payee_company_name <chr>,
#> #   payee_last_name <chr>, payee_first_name <chr>, payee_middle_name <chr>,
#> #   payee_country <chr>, payee_mailing_address1 <chr>,
#> #   payee_mailing_address2 <chr>, payee_city <chr>, payee_state <chr>,
#> #   payee_zip_code <chr>, vendor_type <chr>, vendor_name <chr>,
#> #   vendor_country <chr>, vendor_mailing_address1 <chr>, …

if (FALSE) { # \dontrun{
# Download a single filing year and load it
expenditures <- md_expenditures(md_download("expenditures", year = 2025))

# Analyze spending by category
library(dplyr)
by_category <- md_expenditures("path/to/expenditures.csv") %>%
  group_by(category) %>%
  summarize(total = sum(transaction_amount, na.rm = TRUE))

# Filter for Independent Expenditures only
ie_only <- md_expenditures("path/to/expenditures.csv") %>%
  filter(transaction_type == "Independent Expenditure")
} # }
```
