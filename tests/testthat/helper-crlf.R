# On Windows, writeLines(x, path, sep = "\r\n") opens a text-mode connection
# that *also* translates embedded "\n" to "\r\n", doubling the CR ("\r\r\n")
# and corrupting any literal "\r\n" already in the content (e.g. a quoted
# multi-line field). A binary connection performs no such translation.
write_crlf_lines <- function(lines, path) {
  con <- file(path, "wb")
  on.exit(close(con))
  writeLines(lines, con, sep = "\r\n")
}
