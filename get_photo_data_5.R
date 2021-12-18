# 5th step relies on df4 from get_photo_data_4.R
#  requires ImageName and original_URL
df5 <- df4

# pasted all below from old make_attribution.R

attrib_vector <- rep(NA, nrow(df5))
artistline_vector <- rep(NA, nrow(df5))
creditline_vector <- rep(NA, nrow(df5))
licens_vector <- rep(NA, nrow(df5))
licenseURL_vector <- rep(NA, nrow(df5))

# loop all rows, act if lack File_address but have Info_address ???
#for (i in 1:nrow(df5)) {
for (i in 108:108) {
  
  imgName <- df5$ImageName[i]
  
  # get Artist name from wikimedia API
  artist_API <- paste0(
    'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
    imgName, 
    '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=Artist&format=json')
  
  artist_JSON <- jsonlite::fromJSON(artist_API)
  artist_here <- unlist(artist_JSON)
  artist_line <- artist_here[ grepl('Artist.value', names(artist_here)) ]
  artist_line <- unname(artist_line)
  artist_line <- gsub('\"', "'", artist_line)
  # avoid \n errors when uploading to spreadsheet
  artist_line <- gsub('\n', '', artist_line) 
  artistline_vector[i] <- artist_line
  
  artist <- gsub('<.*">', '', artist_line)
  artist <- gsub('</a>', '', artist)
  artist_vector[i] <- artist
  
  # get artist_URL and check if valid and isn't missing at Provider
  
  # credit_API <- paste0(
  #   'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
  #   img_name, 
  #   '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=Artist&format=json')
  # 
  # credit_JSON <- jsonlite::fromJSON(credit_API)
  # credit_here <- unlist(credit_JSON)
  # credit_line <- credit_here[ grepl('Credit.value', names(credit_here)) ]
  # credit_line <- unname(credit_line)
  # credit_line <- gsub('\"', "'", credit_line)
  # creditline_vector[i] <- credit_line
  
  # get license from wikimedia API
  license_API <- paste0(
    'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
    img_name, 
    '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=LicenseShortName&format=json')
  
  license_JSON <- jsonlite::fromJSON(license_API)
  license_here <- unlist(license_JSON)
  license_line <- license_here[ grepl('LicenseShortName.value', names(license_here)) ]
  license_line <- unname(license_line)
  licens <- gsub('.*"(/w*)"', '\\1', license_line)
  licens_vector[i] <- licens
  
  # get URL describing license from wikimedia API
  licenseURL_API <- paste0(
    'https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
    img_name, 
    '&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=LicenseUrl&format=json')
  
  licenseURL_JSON <- jsonlite::fromJSON(licenseURL_API)
  licenseURL_here <- unlist(licenseURL_JSON)
  licenseURL_line <- licenseURL_here[ grepl('LicenseUrl.value', names(licenseURL_here)) ]
  licenseURL_line <- unname(licenseURL_line)
  licenseURL_vector[i] <- licenseURL_line
  #licens <- gsub('.*"(/w*)"', '\\1', licenseURL_line)
  
  linkLicense <- paste0("<a href='", licenseURL_line, "'>", licens, "</a>")
  
  img_url <- filenameToCommons(img_name)
  linkImage <- paste0("<a href='", img_url, "'>", img_name, "</a>")
  
  # construct attribution with links
  attribution <- paste0(artist_line, ', ', linkImage, '; ', linkLicense, ', via Wikimedia Commons')
  attrib_vector[i] <- attribution
  print(attribution)