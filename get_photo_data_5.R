# 5th step relies on df4 from get_photo_data_4.R requires ImageName
#  only do API, leave extraction attempt for next step

df4 <- readRDS('data/df4.rds')
df5 <- df4

# retreated to old way using ArtistLine as a whole, instead of finding Artist & URL
#  because of problems trying to extract them. 
df5['ArtistHTML'] <- as.character(NA)


df5 <- df5[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'ArtistHTML', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'FileURL', 'OriginURL', 'folder', 'CreditHTML', 'Format', 'iso2c', 'w640_URL')]
# eliminate columns width & height
# df5 <- df5[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'ArtistHTML', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'OriginURL', 'FileURL', 'folder', 'CreditHTML', 'Format', 'Width', 'Height', 'iso2c', 'w640_URL')]

artistLine_vector <- rep(NA, nrow(df5))
license_vector <- rep(NA, nrow(df5))
licenseURL_vector <- rep(NA, nrow(df5))

# loop all rows
loopEnd <- 7 # nrow(df5)
for (i in 1:loopEnd) {
  changed <- 0
# i <- 0
# while (changed < 3) {
  # incr(i)
  
  if (df5$Provider[i] == 'Wikimedia' && !is.na(df5$ImageName[i])) {
    
    imgName <- df5$ImageName[i]
    artist <- NA
    artistLine <- NA
    
    incr(changed)
    
    # get Artist name from wikimedia API
    artist_API <- paste0(
      'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
      imgName, 
      '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=Artist&format=json')
    
    artist_JSON <- jsonlite::fromJSON(artist_API)
    artist_here <- unlist(artist_JSON)
    artistLine1 <- artist_here[ grepl('Artist.value', names(artist_here)) ]
    artistLine2 <- unname(artistLine1)
    
    # harmonise to contain single quotes not double quotes
    #  but what if doublequotes ArtistLine also contains a singlequote?
    artistLine3 <- gsub('\"', "'", artistLine2)
    
    # avoid \n errors when uploading to spreadsheet
    artistLine <- gsub('\n', '', artistLine3) 

    artistLine_vector[i] <- artistLine
    df5$ArtistHTML[i] <- artistLine
    
    print(paste(i, df5$iso3c[i], df5$ID[i]))
    print(paste('artistLine', artistLine))  

    # get license from wikimedia API
    license_API <- paste0(
      'https://commons.wikimedia.org/w/api.php?action=query&titles=File:',
      imgName,
      '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=LicenseShortName&format=json')

    license_JSON <- jsonlite::fromJSON(license_API)
    license_here <- unlist(license_JSON)
    license_line1 <- license_here[ grepl('LicenseShortName.value', names(license_here)) ]
    license_line2 <- unname(license_line1)
    
    # is this needed?
    # license_line3 <- gsub('\"', "'", license_line2)
    # avoid \n errors when uploading to spreadsheet
    license_line <- gsub('\n', '', license_line2)
    
    licens <- gsub('.*"(/w*)"', '\\1', license_line)
    df5$License[i] <- licens
    license_vector[i] <- licens

    # get URL describing license from wikimedia API
    licenseURL_API <- paste0(
      'https://commons.wikimedia.org/w/api.php?action=query&titles=File:',
      imgName,
      '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=LicenseUrl&format=json')

    licenseURL_JSON <- jsonlite::fromJSON(licenseURL_API)
    licenseURL_here <- unlist(licenseURL_JSON)
    licenseURL_line1 <- licenseURL_here[ grepl('LicenseUrl.value', names(licenseURL_here)) ]
    licenseURL_line2 <- unname(licenseURL_line1)
    
    if (!identical(licenseURL_line2, character(0))) {
      licenseURL_line2 <- unname(licenseURL_line1)
      licenseURL_line <- gsub('\n', '', licenseURL_line2)
      df5$LicenseURL[i] <- licenseURL_line
      licenseURL_vector[i] <- licenseURL_line
      print(paste('licenseURL', licenseURL_line)) 
    }

    print(paste('license', licens))
    
  } # end Wikimedia with ImageName
  
  # if API other Providers can get Artist or License, it goes here
  
  if (df5$Provider[i] == 'Pixabay' && !is.na(df5$ImageName[i])) {
    imgName <- df5$ImageName[i]
    
  }
  # Pixabay 24587231-d8363fed1919782211f48ccc6
  # https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&
  # Pixabay uses ID number {5or6} instead of ImgName
  # "user_id":5475750,"user":"Graham-H"  Yes this matches what InfoURL says
  # https://pixabay.com/users/graham-h-5475750/  so ArtistURL can be constructed.
  
} # end loop image rows

saveRDS(df5, 'data/df5.rds')