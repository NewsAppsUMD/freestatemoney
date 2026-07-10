# Strip Excel formula armor from a character vector

CRIS wraps values with leading zeros (zip codes) as \`="21228"\` so
Excel preserves them. This returns the bare value.

## Usage

``` r
strip_excel_armor(x)
```

## Arguments

- x:

  Character vector

## Value

Character vector without the \`="..."\` wrapper
