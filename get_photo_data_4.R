# 4th step relies on df3 from get_photo_data_3.R
#  relies on complete InfoURL and ImageName columns
library(jsonlite)

# If run in small batches need to keep changed df4
df3 <- readRDS('data/df3.rds')
df4 <- df3
df4['OriginURL'] <- as.character(NA)

# extra column so can see where 640URL added
df4['w640_URL'] <- as.character(NA)

df4 <- df4[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistURL', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'OriginURL', 'FileURL', 'folder', 'CreditHTML', 'Format', 'Width', 'Height', 'iso2c', 'w640_URL')]

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

}

print(paste(found, 'need API to get folder from InfoURL'))
print(paste(already, 'already have folder derived from FileURL'))

saveRDS(df4, file='data/df4.rds')
