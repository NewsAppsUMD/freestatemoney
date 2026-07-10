# Load Maryland Committee Data

Parses committee registration data from the Maryland State Board of
Elections. Returns a tidy data frame with committee metadata including
registration information, officers, and contact details.

## Usage

``` r
md_committees(file_path, clean_names = TRUE)
```

## Arguments

- file_path:

  Character string. Path to the local committee CSV file downloaded from
  Maryland SBE. This parameter is required.

- clean_names:

  Logical. If TRUE (default), converts column names to snake_case. Date
  columns are parsed either way.

## Value

A tibble with committee data including:

- filing_entity_id: Unique committee identifier

- committee_name: Full committee name

- committee_type: Type (Candidate, PAC, Party, etc.)

- election: Assigned election(s)

- registration_submission_date: Date registration submitted

- registration_approval_date: Date registration approved

- registration_dissolved_date: Date committee dissolved (if applicable)

And many additional fields for officers, candidates, and contact
information. The tibble carries a \`download_date\` attribute with the
file's "as of" timestamp.

## Details

Download the committee CSV with
\[md_download("committees")\]\[md_download\], or manually from the
Maryland SBE website at
https://campaignfinance.maryland.gov/public/cf/downloads

The raw file has a metadata line ("Committee Download as of ...") before
the header; it is skipped automatically and its timestamp is stored in
the \`download_date\` attribute of the result. Values wrapped for Excel
such as \`="21085"\` (zip codes) are unwrapped to plain strings.

## Examples

``` r
# Sample data included with the package
committees <- md_committees(
  system.file("extdata", "committees_sample.csv", package = "freestatemoney")
)
head(committees)
#> # A tibble: 6 × 62
#>   filing_entity_id committee_name abbreviated_committe…¹ committee_type election
#>   <chr>            <chr>          <chr>                  <chr>          <chr>   
#> 1 1000012          Guthrie, Dion… NA                     Candidate Com… Guberna…
#> 2 1000076          Rosapepe, Jim… NA                     Candidate Com… Guberna…
#> 3 1000450          Washington, M… NA                     Candidate Com… Preside…
#> 4 1000561          Kearney, Regi… NA                     Candidate Com… Guberna…
#> 5 1000598          Lee, Cereta A… NA                     Candidate Com… Guberna…
#> 6 1000626          Franchot, Pet… NA                     Candidate Com… Preside…
#> # ℹ abbreviated name: ¹​abbreviated_committee_name
#> # ℹ 57 more variables: treasurer_authorized_agent_name <chr>,
#> #   treasurer_authorized_agent_public_address1 <chr>,
#> #   treasurer_authorized_agent_address2 <chr>,
#> #   treasurer_authorized_agent_city <chr>,
#> #   treasurer_authorized_agent_state <chr>,
#> #   treasurer_authorized_agent_zip_code <chr>, …

if (FALSE) { # \dontrun{
# Download and load in one go
committees <- md_committees(md_download("committees"))

# With original column names (not snake_case)
committees <- md_committees("path/to/committees.csv", clean_names = FALSE)
} # }
```
