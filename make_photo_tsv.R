# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address

library(readr)
library(stringr)
library(stringi)
library(countrycode)
# library(Hmisc)
incr <- function(x) {eval.parent(substitute(x <- x + 1))}

cleanCaption <- function(line) {
  caption <- stri_encode(line, '', 'UTF-8')
  caption <- sub('#', '', caption)
  caption <- capitalize(caption)
  # remove trailing spaces
  caption <- trimws(caption, which = "right", whitespace = "[ \t\r\n]")
  # add final period if missing
  if (!str_sub(caption, -1) == '.') {
    caption <- paste0(caption, '.')
  }
  return(caption)
}

# how many from each photo platform/provider
provider <- c('wikimedia', 'unsplash', 'pixnio', 'pixabay', 'freeimages', 'other')
numSource <- rep(0, length(provider))
names(numSource) <- provider

country_count <- 0
p <- 0 # photoCount
country_found <- vector()
iso3c_found <- vector()

df <- data.frame(iso3c = character(),
                 ID = numeric(),
                 Caption = character(),
                 CreditHTML = character(),
                 Artist = character(),
                 ArtistURL = character(),
                 License = character(),
                 LicenseURL = character(),
                 InfoURL = character(),
                 FileURL = character(),
                 Format = character(),
                 Width = numeric(),
                 Height = numeric(),
                 stringsAsFactors=FALSE) 

infile <- 'data/fromGoogleDoc.txt'
con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 20 && country_count < 5) {
    
    if (grepl('^[*][*][*]', line)) {
      
      # get country
      country <- sub("^[*][*][*][ ]*([A-Z|a-z| ]*)[-|:| ]*", "\\1", line)
      
      # clean upperCase 
      country <- str_to_title(country)
      grepl('Guineabissau', 'Guinea-Bissau', country)
      grepl('Republic Of The Congo', 'Republic of the Congo', country)
      grepl('Democratic Republic Of The Congo', 'Democratic Republic of the Congo', country)
      
      incr(country_count)
      country_found[country_count] <- country

      iso3c <- countrycode(country, origin = 'country.name', destination = 'iso3c')
      iso3c_found[country_count] <- iso3c
      
      # print(paste(iso3c, country))
      # ready to count photos in this country      
      photoID <- 0
      
    } # country label 
    
    # photo
    if (expectPhoto && grepl('https', line)) {
      
      incr(p)
      photoID <- photoID + 1
      imageFileAddr <- ''
      landingPageAddr <- ''
      credit <- ''
      
      if (grepl('wikimedia.org', line)) {
        if (grepl('commons.wikimedia', line)) {
          landingPageAddr <- line
        } else if (grepl('upload.wikimedia', line)) {
          imageFileAddr <- line
        }
        incr(numSource['wikimedia'])
      } 

      else if (grepl('unsplash.com', line)) {
        if (grepl('images.unsplash.com/photo', line)) {
          imageFileAddr <- line
          credit <- 'Photo from <a href="https://unsplash.com/">Unsplash.com</a>'
        } else {
          landingPageAddr <- line
        }
        incr(numSource['unsplash'])
      }
      
      else if (grepl('pixnio.com', line)) {
        landingPageAddr <- line
        license <- 'CC0'
        licenseURL <- 'https://pixnio.com/creative-commons-license'
        # creditHTML <- 'Pixnio <a href="https://pixnio.com/">free images</a>'
        incr(numSource['pixnio'])
      }
      
      else if (grepl('pixabay.com', line)) {
        landingPageAddr <- line
        licenseURL <- 'https://pixabay.com/service/license/'
        incr(numSource['pixabay'])
      }
      
      else if (grepl('freeimages.com', line)) {
        landingPageAddr <- line
        licenseURL <- 'https://www.freeimages.com/license'
        incr(numSource['freeimages'])
      }
      
      else {
        landingPageAddr <- line
        incr(numSource['other'])
      }
      
      # identify format
      # ext <- grepl('[jpg|png|svg]$', line)
      # if (grepl('jpg'))
      
      row <- c(iso3c, as.numeric(photoID), imageFileAddr, landingPageAddr)
      # print(row)
      # rbind(df, rowVector)
      df[p, 'iso3c'] <- iso3c
      df[p, 'ID'] <- photoID
      df[p, 'Caption'] <- caption
      df[p, 'CreditHTML'] <- credit
      df[p, 'FileURL'] <- imageFileAddr
      df[p, 'InfoURL'] <- landingPageAddr
      
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
print(numSource)
print(paste('Total photos =', sum(numSource)))