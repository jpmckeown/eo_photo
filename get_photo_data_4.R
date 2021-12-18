# 4th step relies on df3 from get_photo_data_3.R
#  relies on complete InfoURL and ImageName columns
df4 <- df3

# where folder (and FileURL) missing from Wikimedia
# use Wikimedia API to get folder for FileURL construction
# also get artist, artistURL, license, and licenseURL

# for ( i in 1:) 
# temp code to avoid looping all
found <- 0
i <- 0
while (found < 5) {
  incr(i)
  
  if (df4$Provider[i] == 'Wikimedia') {
    
    if (is.na(df4$folder[i])) {
      incr(found)
      #print(paste(i, found))
      next
      
      # first get URL of original image file (max size) from Wiki API
      
      original_API <- paste0('https://commons.wikimedia.org/w/api.php?action=query&titles=File:', imgName, '&prop=imageinfo&iiprop=url&format=json')
      
      original_JSON <- jsonlite::fromJSON(original_API)
      original <- unlist(original_JSON)
      original_URL <- original[ grepl('imageinfo.url', names(original)) ]
      original_URL <- unname(original_URL)
      
      # get double folder where versions of image file stored
      folder <- originalURL_to_folder(original_URL)
      df3$folder[i] <- folder
      
      # FileURL can be derived from imageName and folder (for any width) 
      # but fill in missing FileURL so that no one adds it manually
      
      # construct URL of version 640 pixels width
      imgName <- df3$ImageName[i]
      URL640 <- paste0('https://upload.wikimedia.org/wikipedia/commons/thumb/', folder, imgName, '/640px-', imgName)
      
      print(paste(i, URL640))
      df3$FileURL[i] <- URL640
      
    } else {  # FileURL and folder were already present
      folder <- df3$folder[i]
    }
  }
  
}
save(df4, file='data/df4.Rda')
