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
for (i in 136:loopEnd) {
  
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
      print(paste(i, iso3c, img_id, country, 'Photo not stored but lack FileURL to download', info_url))
    } else {
      # download
      if (provider == 'Unsplash') {
        suffix <- 'jpg'
      } else {
        suffix <- sub('(.*)?\\.(.*)', '\\2', file_url)        
      }
      dest <- paste0(temp_folder, iso3c, '_', img_id, '.', suffix)
      print(paste(i, 'download', fn, dest))
      if (provider != 'Pixabay') {
        # download.file(file_url, dest, quiet = FALSE)        
      }
    } # end FileURL available and not stored, so download
    
  } # end test if stored
} # end new df loop

# test if any weird stored?
table(df9$file)

saveRDS(df9, 'data/df9.rds')

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

pixabay_ID_to_df <- function(imgName) {
  Pixabay_API <- 'https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&'
  this_API <- paste0(Pixabay_API, 'id=', imgName)
  this_JSON <- jsonlite::fromJSON(this_API, simplifyVector = TRUE)
  # returns list, 3rd item is dataframe
  df <- this_JSON[['hits']]
  return(df)
}

new_photos <- list.files(new_folder)
missing=0; loopEnd <- nrow(df9)
for (i in 1:loopEnd) {
  
  provider <- df9$Provider[i]
  iso3c <- df9$iso3c[i]
  img_id <- df9$ID[i]
  info_url <- df9$InfoURL[i]
  file_url <- df9$FileURL[i]
  country <- df9$Country[i]
  stored <- df9$file[i]
  imgName <- df9$ImageName[i]
  artist <- df9$Artist[i]
  artist_url <- df9$ArtistURL[i]
  
  if (provider == 'Pixabay') {
    
    # if image not already stored, try download
    fn <- paste0(iso3c, '_', img_id)
    stored <- grep(fn, new_photos)
    
    if (length(stored) == 1) {
      print(paste(i, 'Photo already stored', fn, imgName)) #artist, artist_url))
      df9$file[i] <- 'Y'
    } 
    else if (length(stored) == 0) {
      df9$file[i] <- 'N'
        incr(missing)
        print(paste(i, 'Photo download needed', fn, imgName)) # artist, artist_url

        # Pixabay_df <- pixabay_ID_to_df(imgName)
        # # artist <- Pixabay_df$user
        # # u_id <- Pixabay_df$user_id
        # newfileurl <- Pixabay_df$webformatURL
        # df9$FileURL <- newfileurl
        # dest <- paste0(temp_folder, iso3c, '_', img_id, '.', suffix)
        # print(paste(i, 'download', fn, dest))
        # download.file(newfileurl, dest, quiet = FALSE)

    }
  }
}

# test if any zero size images
path <- '../eo_html/w640/'
photos640 <- paste0(path, list.files(path))
fn640 <- list.files(path)
file640 <- substr(fn640, 1, 5)
filesizes <- file.info(photos640)$size

# test if all rows df9 correspond to file
library(tools)
library(stringr)
df9 <- readRDS('../eo_html/data/df9.rds')
head(df9$iso3c)
looper <- 3 # nrow(df9)
for (i in 1:looper) {
  iso3c <- df9$iso3c[i]
  id <- df9$ID[i]
  fname <- paste0(iso3c, '_', id)

  arr <- str_detect(file640, fname)
  if (sum(arr)==1) {
    print(paste(fname, 'Found once among files'))
  } else if (sum(arr)==0) {
    print(paste(iso3c, id, 'Not found among files'))
  } else {
    print(paste(sum(arr), 'found'))
  }
  #if (file.exist
}
