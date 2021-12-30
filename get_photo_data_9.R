# Step 9 download photos other platforms and new Wikimedia

#df9 <- readRDS('data/df8.rds')

# switch helpful sheet remarks back to NA
# remarks <- grepl('not available; JM downloaded manually', df9$FileURL)
# df9$FileURL[remarks] <- NA

# column records if image downloaded already Y/N
#df9['file'] <- as.character(NA) 

missing <- 0
new_folder <- 'w640/'
temp_folder <- 'w640d/'
#dir.create(temp_folder)
new_photos <- list.files(new_folder)

# count/identify missing FileURL
loopEnd <- nrow(df9)
for (i in 101:loopEnd) {
  
  provider <- df9$Provider[i]
  iso3c <- df9$iso3c[i]
  img_id <- df9$ID[i]
  info_url <- df9$InfoURL[i]
  file_url <- df9$FileURL[i]
  country <- df9$Country[i]
  
  # if image not already stored, try download
  fn <- paste0(iso3c, '_', img_id)
  stored <- grep(fn, new_photos)
  
  if (length(stored) == 1) {
    # print(paste(i, 'Photo already stored', fn, stored, length(stored)))
    df9$file[i] <- 'Y'
  } 
  else if (length(stored) == 0) {
    df9$file[i] <- 'N'
    if (is.na(file_url))  {
      incr(missing)
      #print(paste(i, 'Photo not stored but lack FileURL to download', fn, stored, length(stored)))
      print(paste(i, iso3c, img_id, country, info_url))
    } else {
      # download
      if (provider == 'Unsplash') {
        suffix <- 'jpg'
      } else {
        suffix <- sub('(.*)?\\.(.*)', '\\2', file_url)        
      }
      dest <- paste0(temp_folder, iso3c, '_', img_id, '.', suffix)
      print(paste(i, 'download', fn, dest))
      download.file(file_url, dest, quiet = FALSE)
      
    }
    
  } # end test if stored
} # end new df loop

# test if any weird stored?
table(df9$file)

#saveRDS(df9, 'data/df9.rds')


# only 5 Unsplash showing as missing FileURL, why are Pixnio gaps not being flagged? because of helpful remarks instead of NA
# AUT 3 Austria
# FIN 1 Finland
# IND 2 India
# MDG 1 Madagascar
# SGP 2 Singapore

# df8_missing <- df8 %>%
#   filter(is.na(FileURL)) %>%
#   filter(is.na(w640_URL)) %>%
#   select(iso3c, ID, Provider, Country)
# 
# print(paste('Missing', missing))
# Wikimedia, Pixabay
