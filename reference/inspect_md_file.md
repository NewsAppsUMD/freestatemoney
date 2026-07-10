# Validate a Maryland CRIS file and read its metadata line

Checks that a file is the expected CRIS dataset (erroring with a pointer
to the right loader when it is another dataset's file), and parses the
"... Download as of" metadata line if present.

## Usage

``` r
inspect_md_file(file_path, dataset)
```

## Arguments

- file_path:

  Path to the downloaded CSV file

- dataset:

  One of "committees", "contributions", "expenditures"

## Value

A list with \`has_metadata\` (logical) and \`download_date\` (POSIXct,
NA if the metadata line was absent)
