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

# test 2 versions Wikimedia FileURL
fileURL_to_folder('https://upload.wikimedia.org/wikipedia/commons/8/8e/Fidel_Castro_2012.jpg')
fileURL_to_folder('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Lesotho_class.jpg/640px-Lesotho_class.jpg')
