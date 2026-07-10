# Read a Maryland CRIS bulk download CSV

Shared reader for the three CRIS datasets. Validates that the file is
the expected dataset, skips the "... Download as of" metadata line,
repairs CRIS export defects (see \[prepare_md_csv()\]), reads all
columns as character, strips Excel formula armor, converts date and
amount columns, and optionally cleans column names.

## Usage

``` r
read_md_csv(file_path, dataset, clean_names = TRUE)
```

## Arguments

- file_path:

  Path to the downloaded CSV file

- dataset:

  One of "committees", "contributions", "expenditures"

- clean_names:

  Logical; convert names to snake_case

## Value

A tibble with a \`download_date\` attribute (POSIXct, or NA if the
metadata line was absent)
