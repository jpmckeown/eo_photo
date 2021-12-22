# read photo ID, caption, URL from gDoc 

# how many from each photo platform/provider
provider <- c('wikimedia', 'unsplash', 'pixnio', 'pixabay', 'freeimages', 'other')
numSource <- rep(0, length(provider))
names(numSource) <- provider

country_count <- 0
expectPhoto <- FALSE
p <- 0 # photoCount
country_found <- vector()
iso3c_found <- vector()

df <- data.frame(Country = character(),
                 iso3c = character(),
                 ID = numeric(),
                 Caption = character(),
                 Provider = character(),
                 Artist = character(),
                 ArtistURL = character(),
                 License = character(),
                 LicenseURL = character(),
                 ImageName = character(),
                 InfoURL = character(),
                 FileURL = character(),
                 folder = character(),   # only for Wikimedia
                 CreditHTML = character(),
                 Format = character(),
                 iso2c = character(),
                 stringsAsFactors=FALSE) 

infile <- 'data/fromGoogleDoc.txt'
con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 19 && country_count < 199) {
  #if (line != '' && i > 96 && i < 112) {
      
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
      
      # enable referencing old imgdata in step 2
      iso2c <- countrycode(country, origin = 'country.name', destination = 'iso2c')
      
      # print(paste(iso3c, country))
      # ready to count photos in this country      
      photoID <- 0
      
    } # country label 
    
    # photo
    if (expectPhoto && grepl('https', line)) {
      
      url <- cleanURL(line)
      incr(p)
      incr(photoID)
    
      imgName <- NA
      folder <- NA
      imageFileAddr <- NA
      landingPageAddr <- NA
      creditHTML <- NA
      artist <- NA
      artistURL <- NA
      license <- NA
      licenseURL <- NA
      ext <- NA
      
      # store URL in correct column Info or File
      
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
      
      df[p, 'Country'] <- country
      df[p, 'iso3c'] <- iso3c
      df[p, 'ID'] <- photoID
      df[p, 'Caption'] <- caption
      df[p, 'Provider'] <- provider
      df[p, 'Artist'] <- artist
      df[p, 'ArtistURL'] <- artistURL
      df[p, 'License'] <- license
      df[p, 'LicenseURL'] <- licenseURL
      df[p, 'ImageName'] <- imgName
      df[p, 'folder'] <- folder
      df[p, 'FileURL'] <- imageFileAddr
      df[p, 'InfoURL'] <- landingPageAddr
      df[p, 'CreditHTML'] <- creditHTML
      df[p, 'Format'] <- ext
      df[p, 'iso2c'] <- iso2c
      
      expectPhoto <- FALSE
    }
    
    # caption
    if (grepl('^#', line)) {
      caption <- cleanCaption(line)
      expectPhoto <- TRUE
      print(caption)
    }
    
  } # blank line excluder
} # read lines

close(con)
print(numSource)
print(paste('Total photos =', sum(numSource)))

saveRDS(numSource, file='data/providers.rds')
saveRDS(df, file='data/df1.rds')

write_tsv(df, 'data/photo_step_1.tsv', escape = 'none')
