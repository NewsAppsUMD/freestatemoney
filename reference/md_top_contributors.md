# Rank contributors by total amount given

Aggregates contributions by contributor. Organizations are identified by
their company name; individuals by "Last, First". Lump-sum rows with no
contributor details are dropped.

## Usage

``` r
md_top_contributors(contributions, n = 25)
```

## Arguments

- contributions:

  Tibble from \[md_contributions()\]

- n:

  Maximum number of contributors to return (default 25)

## Value

A tibble with \`contributor\`, \`contributor_type\`, \`total\`, and
\`n_contributions\`, sorted by \`total\` descending.

## Details

Contributors are grouped by name as reported, so the same person
reported under different spellings appears as separate rows.

## Examples

``` r
contributions <- md_contributions(
  system.file("extdata", "contributions_sample.csv", package = "freestatemoney")
)
md_top_contributors(contributions, n = 10)
#> # A tibble: 5 × 4
#>   contributor                 contributor_type             total n_contributions
#>   <chr>                       <chr>                        <dbl>           <int>
#> 1 Friends of Jessica Feldmark Business/Group/Organization 3000                 1
#> 2 Feldmark, Joshua            Individual                    20.5               2
#> 3 Maroshek, Agnes             Individual                    10                 1
#> 4 GRUNDY, JOSEPH              Individual                     8.1               3
#> 5 HEATH, JAN                  Individual                     3.6               1
```
