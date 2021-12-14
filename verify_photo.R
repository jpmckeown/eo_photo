# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address

library(readr)
library(stringr)
library(countrycode)
library(Hmisc)

# include('helpers.R')
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

country_count <- 0
goodURL <- 0
badURL <- 0
expectPhoto <- FALSE

country_found <- vector()
iso3c_found <- vector()

infile <- 'data/fromGoogleDoc.txt'
con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 20) {
    
  if (!grepl('[a-zA-Z0-9]+', line)) {
    # print(paste('Exclude', line))
  } else {
    
    # country
    if (grepl('^[*][*][*]', line)) {
      
      # get country name
      country <- sub("^[*][*][*][ ]*([A-Z|a-z| ]*)[-|:| ]*", "\\1", line)
      # not needed while only checking countries included
      # country <- str_to_title(country)
      # if (country == 'Guineabissau') {
      #   country <- 'Guinea-Bissau'
      # }
      
      country_count <- country_count + 1
      country_found[country_count] <- country

      iso3c <- countrycode(country, origin = 'country.name', destination = 'iso3c')
      iso3c_found[country_count] <- iso3c
      
      # ready to count photos in this country      
      photoID <- 0
      
    } # country label
    
    # photo
    if (expectPhoto) {
      photoID <- photoID +1

      if(grepl('https', line)) {
        goodURL <- goodURL + 1
        
      } else if (grepl('https', line) || grepl('jpg', line) || grepl('png', line) || grepl('JPG', line) || grepl('PNG', line) || grepl('svg', line)  || grepl('Photo-', line)) {
        badURL <- badURL + 1
        
      } else {
        print(paste('ID', photoID, country, 'no URL', line, caption))
      }
      expectPhoto <- FALSE
    }
    
    # caption
    if (grepl('^#', line)) {
      caption <- cleanCaption(line)
      expectPhoto <- TRUE
    }
    
    # unspecified
    # if (grepl('pixabay.com/photos/search', line)) {
    #   print(paste(country, 'ID', photoID, line))
    # }

  }
  } # blank line excluder
} # read lines

close(con)

# check for duplicates
# if (length(unique(iso3c_found)) == length(iso3c_found)) {
#   print('Countries appear once each, no duplicates')
# }

# identify missing countries (versus those on data sheet)
# load('data/eo.Rda')

# missing_iso3c <- setdiff(as.vector(eo$iso3c), iso3c_found)
# 
# countrycode(missing_iso3c, origin = 'iso3c', destination = 'country.name')
