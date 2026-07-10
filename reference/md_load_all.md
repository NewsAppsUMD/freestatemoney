# Download and load all three Maryland datasets at once

Convenience wrapper that downloads committees, contributions, and
expenditures via \[md_download()\] and loads each with its parser. The
\`year\` applies to contributions and expenditures; committee data is
only available as one complete file.

## Usage

``` r
md_load_all(year = NULL, dir = tempdir(), quiet = FALSE)
```

## Arguments

- year:

  Optional four-digit filing year passed to \[md_download()\] for the
  transaction datasets. If NULL, downloads current-cycle files, which
  can be very large.

- dir:

  Directory to save the downloaded CSVs (default: a temporary
  directory).

- quiet:

  Logical. If FALSE (default), shows download progress bars.

## Value

A named list with \`committees\`, \`contributions\`, and
\`expenditures\` tibbles, ready for joining on \`filing_entity_id\`.

## Examples

``` r
if (FALSE) { # \dontrun{
md <- md_load_all(year = 2025)
summary <- md_committee_summary(md$committees, md$contributions, md$expenditures)
} # }
```
