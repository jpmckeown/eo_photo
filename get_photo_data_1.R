# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Steps 2-6 in other files
# 1. do all possible without API call or download
# 2. get file URL
# 3. download and name with iso3c and photoID
# 4. get dimensions
# 5. get artist and licence with API
# 6. write credit HTML

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address

library(readr)
library(stringr)
library(stringi)
library(countrycode)
library(tools)
# library(Hmisc)
incr <- function(x) {eval.parent(substitute(x <- x + 1))}

cleanCaption <- function(line) {
  # stops odd characters
  caption <- stri_encode(line, '', 'UTF-8')
  # remove prefix
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

cleanURL <- function(url) {
  # remove any characters before http
  line <- gsub('.*http', 'http', line)
  # remove any trailing space
  url <- trimws(line, which = "right", whitespace = "[ \t\r\n]")
  return(url)
}

# how many from each photo platform/provider
provider <- c('wikimedia', 'unsplash', 'pixnio', 'pixabay', 'freeimages', 'other')
numSource <- rep(0, length(provider))
names(numSource) <- provider

country_count <- 0
p <- 0 # photoCount
country_found <- vector()
iso3c_found <- vector()

df <- data.frame(Country = character(),
                 iso3c = character(),
                 ID = numeric(),
                 Caption = character(),
                 Provider = character(),
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
  if (line != '' && i > 20 && country_count < 199) {
    
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
      
      url <- cleanURL(line)
      incr(p)
      incr(photoID)
    
      imageFileAddr <- ''
      landingPageAddr <- ''
      creditHTML <- ''
      artist <- ''
      artistURL <- ''
      license <- ''
      licenseURL <- ''
      ext <- ''
      width <- 0
      height <- 0
      
      if (grepl('wikimedia.org', url)) {
        if (grepl('commons.wikimedia', url)) {
          landingPageAddr <- url
        } else if (grepl('upload.wikimedia', url)) {
          imageFileAddr <- url
        }
        provider <- 'Wikimedia'
        incr(numSource['wikimedia'])
      } 

      else if (grepl('unsplash.com', url)) {
        if (grepl('images.unsplash.com', url)) {
          imageFileAddr <- url
          #creditHTML <- 'Photo from <a href="https://unsplash.com/">Unsplash.com</a>'
        } else if (grepl('unsplash.com/photos', url)) {
          landingPageAddr <- url
        }
        provider <- 'Unsplash'
        incr(numSource['unsplash'])
      }
      
      else if (grepl('pixnio.com', url)) {
        # Pixnio only offers Info page, no file address
        landingPageAddr <- url
        # apparently all on Pixnio are CC0
        license <- 'CC0'
        licenseURL <- 'https://pixnio.com/creative-commons-license'
        # creditHTML <- 'Pixnio <a href="https://pixnio.com/">free images</a>'
        provider <- 'Pixnio'
        incr(numSource['pixnio'])
      }
      
      else if (grepl('pixabay.com', url)) {
        if (grepl('cdn.pixabay', url)) {
          imageFileAddr <- url
        } else {
          landingPageAddr <- url 
        }
        licenseURL <- 'https://pixabay.com/service/license/'
        provider <- 'Pixabay'
        incr(numSource['pixabay'])
      }
      
      else if (grepl('freeimages.com', url)) {
        if (grepl('www.freeimages', url)) {
          landingPageAddr <- url 
        } else if (grepl('images.freeimages', url)) {
          imageFileAddr <- url
        }
        licenseURL <- 'https://www.freeimages.com/license'
        provider <- 'FreeImages'
        incr(numSource['freeimages'])
      }
      
      else {
        landingPageAddr <- url
        provider <- 'Other'
        incr(numSource['other'])
      }
      
      # identify photo format jpg png svg
      ext <- tolower(file_ext(line))
      if (ext == 'jpeg') { ext <- 'jpg'}
      
      df[p, 'Country'] <- country
      df[p, 'iso3c'] <- iso3c
      df[p, 'ID'] <- photoID
      df[p, 'Caption'] <- caption
      df[p, 'CreditHTML'] <- creditHTML
      df[p, 'Artist'] <- artist
      df[p, 'ArtistURL'] <- artistURL
      df[p, 'License'] <- license
      df[p, 'LicenseURL'] <- licenseURL
      df[p, 'FileURL'] <- imageFileAddr
      df[p, 'InfoURL'] <- landingPageAddr
      df[p, 'Format'] <- ext
      df[p, 'Width'] <- width
      df[p, 'Height'] <- height
      df[p, 'Provider'] <- provider
      
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

write_tsv(df, 'data/photo_step_1.tsv')
