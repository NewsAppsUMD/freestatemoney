# Find bare line breaks inside fields

CRIS records are terminated by CRLF; a bare LF (not preceded by CR) is
field content — typically a multi-line address — that breaks the row for
every CSV parser. Returns positions of such LF bytes in \`chunk\`. Quote
state is deliberately not tracked: CRIS data contains stray literal
quotes in unquoted fields, which make quote-parity unreliable, and legal
quoted line breaks in a CRLF file use CRLF (which this leaves alone).

## Usage

``` r
bare_lf_positions(chunk, prev_byte)
```

## Arguments

- chunk:

  Raw vector of file bytes

- prev_byte:

  Last byte of the preceding chunk

## Value

Integer positions within \`chunk\`
