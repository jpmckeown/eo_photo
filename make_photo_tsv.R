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

country_count <- 0
country_found <- vector()
iso3c_found <- vector()

infile <- 'data/fromGoogleDoc.txt'
con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 20) {
    
    if (grepl('^[*][*][*]', line)) {
      
      # get country
      country <- sub("^[*][*][*][ ]*([A-Z|a-z| ]*)[-|:| ]*", "\\1", line)
      
      # clean upperCase 
      country <- str_to_title(country)
      grepl('Guineabissau', 'Guinea-Bissau', country)
      grepl('Republic Of The Congo', 'Republic of the Congo', country)
      grepl('Democratic Republic Of The Congo', 'Democratic Republic of the Congo', country)
      
      country_count <- country_count + 1
      country_found[country_count] <- country

      iso3c <- countrycode(country, origin = 'country.name', destination = 'iso3c')
      iso3c_found[country_count] <- iso3c
      
      print(paste(iso3c, country))
      
    } # country label 
  } # blank line excluder
} # read lines

close(con)
