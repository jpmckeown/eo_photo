# 4th step relies on df3 from get_photo_data_3.R
#  relies on complete InfoURL and ImageName columns
df4 <- df3

# where folder (and FileURL) missing from Wikimedia
# use Wikimedia API to get folder for FileURL construction
# also get artist, artistURL, license, and licenseURL

# for ( i in 1:)
found <- 0
i <- 1
while (found < 5) {
  
  if (df4[i, 'Provider']) {
    
    # first get URL of original image file (max size) from Wiki API
    
    original_API <- paste0('https://commons.wikimedia.org/w/api.php?action=query&titles=File:', imgName, '&prop=imageinfo&iiprop=url&format=json')
    
    original_JSON <- jsonlite::fromJSON(original_API)
    original <- unlist(original_JSON)
    original_URL <- original[ grepl('imageinfo.url', names(original)) ]
    original_URL <- unname(original_URL)
    
    # get double folder where versions of image file stored
    folder <- originalURL_to_folders(original_URL)
    
    incr(i)
  }
}
