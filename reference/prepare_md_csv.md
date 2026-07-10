# Repair CRIS CSV defects before parsing

Streams a file in chunks looking for two defects real CRIS exports have:
bare LF line breaks inside unquoted fields (which split rows), and
Windows-1252 bytes (which appear megabytes in, past encoding-sniffing
windows, and break UTF-8 parsers). Clean files are returned untouched;
defective ones are rewritten to a temporary file with bare LFs replaced
by spaces and text transcoded to UTF-8. CRLF line breaks inside quoted
fields are legal CSV and are left alone.

## Usage

``` r
prepare_md_csv(file_path)
```

## Arguments

- file_path:

  Path to the downloaded CSV file

## Value

A list with \`path\` (the file to parse), \`repaired\` (number of line
breaks fixed), and \`reencoded\` (logical)
