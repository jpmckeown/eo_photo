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
source <- c('wikimedia', 'pixnio', 'pixabay', 'unsplash')
# countSource <- as.data.frame(cbind(source, 0))
# names(countSource)[2] <- 'count'

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
      
      # print(paste(iso3c, country))
      # ready to count photos in this country      
      photoID <- 0
      
    } # country label 
    
    # photo
    if (expectPhoto && grepl('https', line)) {
      
      photoID <- photoID +1
      imageFileAddr <- line  # default
      landingPageAddr <- ''
      
      if (grepl('commons.wikimedia', line)) {
        landingPageAddr <- line
      } else if (grepl('upload.wikimedia', line)) {
        imageFileAddr <- line
      }

      if (grepl('pixnio.com', line)) {
        landingPageAddr <- line
      }
      if (grepl('pixabay.com', line)) {
      }
      if (grepl('unsplash.com', line)) {
      }

      # ext <- grepl('[jpg|png|svg]$', line)
      # if (grepl('jpg'))
      expectPhoto <- FALSE
    }
    
    # caption
    if (grepl('^#', line)) {
      caption <- cleanCaption(line)
      expectPhoto <- TRUE
    }
    
    
  } # blank line excluder
} # read lines

close(con)
