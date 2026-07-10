# Summarize independent expenditures and electioneering communications

Filters expenditure data to independent expenditure (IE) and
electioneering communication (EC) transactions and totals spending by
committee, target candidate or ballot issue, and position.

## Usage

``` r
md_independent_expenditures(expenditures)
```

## Arguments

- expenditures:

  Tibble from \[md_expenditures()\]

## Value

A tibble with \`committee_name\`, \`candidate_ballot_issue\`,
\`position\`, \`total_spent\`, and \`n_expenditures\`, sorted by
\`total_spent\` descending.

## Details

Note: CRIS reports these with transaction types like "Independent
Expenditure / Electioneering Communication", so matching is by pattern,
not exact equality.

## Examples

``` r
expenditures <- md_expenditures(
  system.file("extdata", "expenditures_sample.csv", package = "freestatemoney")
)
md_independent_expenditures(expenditures)
#> # A tibble: 1 × 5
#>   committee_name     candidate_ballot_issue  position total_spent n_expenditures
#>   <chr>              <chr>                   <chr>          <dbl>          <int>
#> 1 Casa in Action PAC Adams-Stafford, Shayla… Support         7930              2
```
