# 5th step relies on df4 from get_photo_data_4.R requires ImageName
#  only do API, leave extraction attempt for next step

# disable while doing incremental run
# df5 <- readRDS('data/df4.rds')
# df5 <- readRDS('data/df5.rds')

API_imgName_to_artistLine <- function(imgName) {
  # get Artist name from wikimedia API
  artist_API <- paste0(
    'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
    imgName, 
    '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=Artist&format=json')
  
  artist_JSON <- jsonlite::fromJSON(artist_API)
  artist_here <- unlist(artist_JSON)
  artistLine1 <- artist_here[ grepl('Artist.value', names(artist_here)) ]
  artistLine2 <- unname(artistLine1)
  
  if (identical(artistLine2, character(0))) { 
    print(paste(i, 'JSON lacks Artist.value'))
    return('') 
  }
  # harmonise to contain single quotes not double quotes
  #  but what if doublequotes ArtistLine also contains a singlequote?
  artistLine3 <- gsub('\"', "'", artistLine2)
  
  # avoid \n errors when uploading to spreadsheet
  artistLine <- gsub('\n', '', artistLine3) 
  return(artistLine)
}

pixabay_ID_to_df <- function(imgName) {
  Pixabay_API <- 'https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&'
  this_API <- paste0(Pixabay_API, 'id=', imgName)
  this_JSON <- jsonlite::fromJSON(this_API, simplifyVector = TRUE)
  # returns list, 3rd item is dataframe
  df <- this_JSON[['hits']]
  return(df)
}

# retreated to old way using ArtistLine as a whole, instead of finding Artist & URL
#  because of problems trying to extract them. 
# df5['ArtistHTML'] <- as.character(NA) # already included by Step 2

# no new column for this step
# df5 <- df5[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'ArtistHTML', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'FileURL', 'folder', 'iso2c', 'OriginURL', 'w640_URL', 'Attribution')]

artistLine_vector <- rep(NA, nrow(df5))
license_vector <- rep(NA, nrow(df5))
licenseURL_vector <- rep(NA, nrow(df5))
# 
# df5 %>% 
#   filter(is.na(ArtistHTML)) %>% 
#   filter(ArtistHTML == '')  # none

# Public domain url '' causing error
# for (i in 1:nrow(df5)) {
#   lurl <- df3$LicenseURL[i]
#   if (!is.na(lurl)) {
#     if (lurl=='') {
#       print(i)
#       #df3$LicenseURL[i] <- NA
#     }
#   }
# }

# special to fix Attributions with missing artist_html (detected in step 6)
missing_artist <- c(51, 78, 163, 211, 241, 242)
for (g in seq_along(missing_artist)) {
  i <- missing_artist[g]
  imgName <- df5$ImageName[i]
  artistLine <- API_imgName_to_artistLine(imgName)
  print(paste(i, artistLine))
  if (identical(artistLine, character(0))) {
    print(paste(i, 'needs attention'))
  } else {
    df5$ArtistHTML[i] <- artistLine
  }
}
# JSON error, which explains why earlier missing artist


# loop all rows
loopEnd <- nrow(df5)
for (i in 393:loopEnd) {
  changed <- 0
# i <- 0
# while (changed < 3) {
  # incr(i)
  imgName <- df5$ImageName[i]
  gotCred <- df5$ArtistHTML[i]
  
  if (df5$Provider[i] == 'Wikimedia' && !is.na(imgName) ) {
    
    # check artistHTML empty since Step 2 may have supplied already.
    if (!is.na(gotCred)) {
      print(paste(i, 'got ArtistHTML from Step 2'))
    } else {
      artist <- NA
      artistLine <- NA
      incr(changed)
      artistLine <- API_imgName_to_artistLine(imgName)
      
      #artistLine_vector[i] <- artistLine
      df5$ArtistHTML[i] <- artistLine
      
      print(paste(i, df5$iso3c[i], df5$ID[i]))
      print(paste(i, 'artistLine', artistLine))  
      
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
      #license_vector[i] <- licens
      print(paste(i, 'license', licens))
      
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
        #licenseURL_vector[i] <- licenseURL_line
        print(paste(i, 'licenseURL', licenseURL_line)) 
      }
    } # end not previously supplied
  } # end Wikimedia with ImageName
  
  # if API other Providers can get Artist or License, it goes here
  
  # Pixabay has nice API
  if (df5$Provider[i] == 'Pixabay' && !is.na(imgName)) {
    Pixabay_df <- pixabay_ID_to_df(imgName)
    artist <- Pixabay_df$user
    u_id <- Pixabay_df$user_id
    fileurl <- Pixabay_df$webformatURL
    artistURL <- paste0('https://pixabay.com/users/', artist, '-', u_id, '/')
    df5$Artist[i] <- artist
    df5$ArtistURL[i] <- artistURL
    df5$FileURL[i] <- fileurl
  }
  # "user_id":5475750,"user":"Graham-H"  Yes this matches what InfoURL says
  # https://pixabay.com/users/graham-h-5475750/  so ArtistURL can be constructed.
  
} # end loop image rows

# API failed for rows 371 = MNE id2
df5$Artist[371] = 'Post of Montenegro'
df5$ArtistURL[371] = 'https://commons.wikimedia.org/wiki/User:Materialscientist' # not in attrib
df5$License[371] = 'Public domain'
df5$Attribution[371] = '<a href="https://commons.wikimedia.org/wiki/File:Svetlana_Kana_Radevi%C4%87_2021_stamp_of_Montenegro.jpg">Post of Montenegro</a>, Public domain, via Wikimedia Commons'
# 392 = NZL id1
df5$Artist[392]='Michal Klajban'
df5$ArtistURL[392]='https://commons.wikimedia.org/wiki/User:Podzemnik'
df5$License[392]='CC BY-SA 4.0'
df5$LicenseURL[392]='https://creativecommons.org/licenses/by-sa/4.0'
df5$Attribution[392] = '<a href="https://commons.wikimedia.org/wiki/File:Red-billed_gull_colony,_Kaik%C5%8Dura,_New_Zealand_08.jpg">Michal Klajban</a>, <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA 4.0</a>, via Wikimedia Commons' # Wikimedia, not constructed

saveRDS(df5, 'data/df5.rds')

write_tsv(df5, 'data/photo_step_5.tsv')
