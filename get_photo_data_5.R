# 5th step relies on df4 from get_photo_data_4.R
#  requires ImageName
# Sadly impossible to extract Artist separately from ArtistURL
#  because sometimes Artist string is divided, and may have 2 links e.g.
# <a href='https://en.wikipedia.org/wiki/User:Khaufle' class='extiw' title='wikipedia:User:Khaufle'>Khaufle</a> at <a href='https://en.wikipedia.org/wiki/' class='extiw' title='wikipedia:'>English Wikipedia</a>
# Therefore go back to old way of using ArtistLine as a whole.

df4 <- readRDS('data/df4.rds')
df5 <- df4

# extra column so can see where 640URL added
df5['ArtistHTML'] <- as.character(NA)

df5 <- df5[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'ArtistHTML', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'OriginURL', 'FileURL', 'folder', 'CreditHTML', 'Format', 'Width', 'Height', 'iso2c', 'w640_URL')]

# artist_vector <- rep(NA, nrow(df5))
# artistURL_vector <- rep(NA, nrow(df5))
artistLine_vector <- rep(NA, nrow(df5))
license_vector <- rep(NA, nrow(df5))
licenseURL_vector <- rep(NA, nrow(df5))
creditline_vector <- rep(NA, nrow(df5))

# loop all rows
loopEnd <- 9
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

    # if link flagged invalid just use Artist name
    # if (grepl('page does not exist', artistLine)) {
    #   artist <- sub('<.*">', '', artistLine)
    #   artist <- sub('</a>', '', artist)
    #   df5$Artist[i] <- artist
    # } else {
    #   df5$ArtistHTML[i] <- artistLine
    # }
    artistLine_vector[i] <- artistLine
    df5$ArtistHTML[i] <- artistLine
    
    # where artist's URL is provided, the artistLine is 
    # a complete Anchor tag containing href with \" quotes
    # Examples
    # <a href='//commons.wikimedia.org/wiki/User:Alexxx1979' title='User:Alexxx1979'>Alexxx1979</a>
    # AL1 "<a href=\"//commons.wikimedia.org/wiki/User:Albinfo\" title=\"User:Albinfo\">Albinfo</a>"
    # AG3 <a rel='nofollow' class='external text' href='https://www.flickr.com/people/21187388@N06'>University of the Fraser Valley</a>
    
    # get artist and URL
    # if (!grepl('<a', artistLine)) {
    #   artist <- artistLine
    # } else {
    #   artist <- sub('<.*">', '', artistLine)
    #   artist <- sub('</a>', '', artist)
    #   
    #   artist_URL <- sub("^<a .*href=(.)+>.*", "\\1", artistLine)
    #   # artist_URL <- sub("^<a .*href=(\"|')(.+)(\"|')>.*", "\\1", artistLine)
    # }
    
    # get artist_URL and check if valid and isn't missing at Provider
print(paste(i, df5$iso3c[i], df5$ID[i]))
# print(paste('artist', artist))
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
    licens_vector[i] <- licens

    # get URL describing license from wikimedia API
    licenseURL_API <- paste0(
      'https://commons.wikimedia.org/w/api.php?action=query&titles=File:',
      imgName,
      '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=LicenseUrl&format=json')

    licenseURL_JSON <- jsonlite::fromJSON(licenseURL_API)
    licenseURL_here <- unlist(licenseURL_JSON)
    licenseURL_line <- licenseURL_here[ grepl('LicenseUrl.value', names(licenseURL_here)) ]
    licenseURL_line2 <- unname(licenseURL_line1)
    licenseURL_line <- gsub('\n', '', license_line2)
    
    df5$LicenseURL[i] <- licenseURL_line
    licenseURL_vector[i] <- licenseURL_line
    #licens <- gsub('.*"(/w*)"', '\\1', licenseURL_line)
    
  } # end Wikimedia with ImageName
}