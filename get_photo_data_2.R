# 2nd step after get_photo_data_1.R and relies on df made there
df2 <- df  # FileURL will be added, for Wikimedia only 

# fix where Wikimedia lacks File_address but has Info_address
# cannot filter because need to keep spreadsheet whole
photoCount <- 0

for (i in 1:nrow(df2)) {
  
  if (df2[i, 'Provider'] == 'Wikimedia') {
    
    addr <- as.character(df2[i, 'FileURL'])
    info <- as.character(df2[i, 'InfoURL'])
    
  }
  

  
  if (is.na(addr) && !is.na(info)) {
    
    # extract filename to use in API
    img_name <- commonsToFilename(info)
    
    # can get URL of max size original from wikimedia API
    original_API <- paste0('https://commons.wikimedia.org/w/api.php?action=query&titles=File:', 
                           img_name, '&prop=imageinfo&iiprop=url&format=json')
    original_JSON <- jsonlite::fromJSON(original_API)
    original <- unlist(original_JSON)
    original_URL <- original[ grepl('imageinfo.url', names(original)) ]
    original_URL <- unname(original_URL)
    
    # get double folder where versions of image file stored
    folder <- originalToFolder(original_URL)
    
    # construct URL of version 640 pixels width
    URL640 <- paste0('https://upload.wikimedia.org/wikipedia/commons/thumb/', 
                     folder, img_name, '/640px-', img_name)
    
    # some photos lack a 640px version, if so use base image address
    if (valid_url(URL640)) {
      URL_vector[i] <- URL640 
      df2[i, 'File_address'] <- URL640
      
    } else {
      URL_vector[i] <- original_URL
      df2[i, 'File_address'] <- original_URL
    }
    print(URL_vector[i])
  }
}