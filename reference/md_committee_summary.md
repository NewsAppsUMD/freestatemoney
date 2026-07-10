# Summarize fundraising and spending by committee

Joins the three CRIS datasets on \`filing_entity_id\` and totals what
each committee raised and spent. Outstanding obligations (unpaid debts)
are excluded from spending totals. Committees with no transactions get
zeros rather than NAs.

## Usage

``` r
md_committee_summary(committees, contributions, expenditures)
```

## Arguments

- committees:

  Tibble from \[md_committees()\]

- contributions:

  Tibble from \[md_contributions()\]

- expenditures:

  Tibble from \[md_expenditures()\]

## Value

A tibble with one row per committee: \`filing_entity_id\`,
\`committee_name\`, \`committee_type\`, \`total_raised\`,
\`n_contributions\`, \`total_spent\`, \`n_expenditures\`, and
\`net_raised\`, sorted by \`total_raised\` descending.

## Details

Note that \`net_raised\` reflects only the transactions in the data you
loaded - it is not the committee's official cash balance, which also
depends on prior balances and non-itemized activity.

## Examples

``` r
sample_file <- function(name) {
  system.file("extdata", name, package = "freestatemoney")
}
committees <- md_committees(sample_file("committees_sample.csv"))
contributions <- md_contributions(sample_file("contributions_sample.csv"))
expenditures <- md_expenditures(sample_file("expenditures_sample.csv"))

md_committee_summary(committees, contributions, expenditures)
#> # A tibble: 8 × 8
#>   filing_entity_id committee_name    committee_type total_raised n_contributions
#>   <chr>            <chr>             <chr>                 <dbl>           <int>
#> 1 1000012          Guthrie, Dion F.… Candidate Com…            0               0
#> 2 1000076          Rosapepe, Jim Fr… Candidate Com…            0               0
#> 3 1000450          Washington, Mary… Candidate Com…            0               0
#> 4 1000561          Kearney, Reginal… Candidate Com…            0               0
#> 5 1000598          Lee, Cereta A. F… Candidate Com…            0               0
#> 6 1000626          Franchot, Peter … Candidate Com…            0               0
#> 7 1000660          Pipkin, E.J. Fri… Candidate Com…            0               0
#> 8 1000674          Madaleno, Richar… Candidate Com…            0               0
#> # ℹ 3 more variables: total_spent <dbl>, n_expenditures <int>, net_raised <dbl>
```
