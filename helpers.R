cleanCaption <- function(line) {
  caption <- sub('#', '', line)
  caption <- capitalize(caption)
  # remove trailing spaces
  caption <- trimws(caption, which = "right", whitespace = "[ \t\r\n]")
  # add final period if missing
  if (!str_sub(caption, -1) == '.') {
    caption <- paste0(caption, '.')
  }
  return(caption)
}