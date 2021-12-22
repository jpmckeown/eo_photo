# 4th step relies on df3 from get_photo_data_3.R
#  relies on complete InfoURL and ImageName columns
library(jsonlite)

pixabay_ID_to_fileURL <- function(imgName) {
  Pixabay_API <- 'https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&'
  this_API <- paste0(Pixabay_API, 'id=', imgName)
  this_JSON <- jsonlite::fromJSON(this_API)
  unlisted <- unlist(this_JSON)
  web_URL <- unlisted[ grepl('webFormatURL', names(unlisted)) ]
  url <- unname(web_URL)
  return(url)
}

# If run in small batches need to keep changed df4, avoid restarting
df4 <- readRDS('data/df3.rds')

df4['OriginURL'] <- as.character(NA)

# extra column so can see where 640URL added
df4['w640_URL'] <- as.character(NA)

df4 <- df4[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'OriginURL', 'FileURL', 'folder', 'CreditHTML', 'Format', 'iso2c', 'w640_URL')]

# where folder (and FileURL) missing from Wikimedia
# use Wikimedia API to get folder for FileURL construction
# also get artist, artistURL, license, and licenseURL
already <- 0
found <- 0

# temp code to avoid looping all
i <- 0
while (found < 9) {
  incr(i)

# loopEnd <- nrow(df4) #
# for (i in seq_len(loopEnd)) { 
  
  if (df4$Provider[i] == 'Wikimedia') {
    
    if (is.na(df4$folder[i])) {
      incr(found)

      # first get original image URL (maximum size) from Wiki API
      # construct API get
      imgName <- df4$ImageName[i]
      common <- 'https://commons.wikimedia.org/w/api.php?action=query&titles=File:'
      original_API <- paste0(common, imgName, '&prop=imageinfo&iiprop=url&format=json')
      
      original_JSON <- jsonlite::fromJSON(original_API)
      original <- unlist(original_JSON)
      original_URL <- original[ grepl('imageinfo.url', names(original)) ]
      original_URL <- unname(original_URL)
      df4$OriginURL[i] <- original_URL
      
      # get double folder where versions of image file stored
      folder <- originalURL_to_folder(original_URL)
      df4$folder[i] <- folder
      
      # FileURL can be derived from imageName and folder (for any width) 
      # but fill in missing FileURL so that no one adds it manually
      
      # construct URL of version 640 pixels width
      URL640 <- paste0('https://upload.wikimedia.org/wikipedia/commons/thumb/', folder, imgName, '/640px-', imgName)
      
      print(paste(i, URL640))
      df4$w640_URL[i] <- URL640

#} # prevent API calls
    } else {  
      incr(already)
      # unsure if this needed, is it used?
      folder <- df4$folder[i]
      print(paste(i, folder))

    } # ends folder absent or present ?
  } # end if Wikimedia

  # if API other Providers can get FileURL or InfoURL
  
  if (df4$Provider[i] == 'Pixabay') {
    
    imgName <- df4$ImageName[i]
    # plan here to call function containing below
    Pixabay_API <- 'https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&'
    this_API <- paste0(Pixabay_API, 'id=', imgName)
    this_JSON <- jsonlite::fromJSON(this_API, simplifyVector = TRUE)
    unlisted <- unlist(this_JSON)
    web_URL <- unlisted[ grepl('hits.webFormatURL', names(unlisted)) ]
    url <- unname(web_URL)
  }
  
  # Pixabay 24587231-d8363fed1919782211f48ccc6
  # https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&
  # Pixabay uses ID number {5or6} instead of ImgName
  # JSON wrapped in 'hits'
  # webformatURL = w640; largeImageURL = w1280?
  # Replace '_640' in any webformatURL value to access other image sizes # No this fails, but the 2nd URL works and is width 1280 despite JSON saying its 2560.

  
  # Pixnio lacks API
  
}

print(paste(found, 'need API to get folder from InfoURL'))
print(paste(already, 'already have folder derived from FileURL'))

saveRDS(df4, file='data/df4.rds')
