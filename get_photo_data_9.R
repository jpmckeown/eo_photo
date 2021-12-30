# Step 9 download photos other platforms and new Wikimedia

df9 <- readRDS('data/df8.rds')
# column records if image downloaded already Y/N
df9['file'] <- as.character(NA) 

missing <- 0
new_folder <- 'w640/'
new_photos <- list.files(new_folder)

# count/identify missing FileURL
loopEnd <- nrow(df9)
for (i in 1:loopEnd) {
  
  provider <- df9$Provider[i]
  iso3c <- df9$iso3c[i]
  img_id <- df9$ID[i]
  info_url <- df9$InfoURL[i]
  file_url <- df9$FileURL[i]
  
  # if image not already stored, try download
  fn <- paste0(iso3c, '_', img_id)
  stored <- grep(fn, new_photos)
  
  if (length(stored) == 1) {
    print(paste(i, 'Photo already stored', fn, stored, length(stored)))
    df9$file[i] <- 'Y'
  } 
  else if (length(stored) == 0) {
    print(paste(i, 'Photo download needed', fn, stored, length(stored)))
    df9$file[i] <- 'N'
    # if (is.na(df8$FileURL[i]) && is.na(df8$w640_URL[i])) {
    #   incr(missing)
    # }
    
  } # end test if stored
} # end new df loop

# test if any weird stored?
table(df9$file)

saveRDS(df9, 'data/df9.rds')

# df8_missing <- df8 %>%
#   filter(is.na(FileURL)) %>%
#   filter(is.na(w640_URL)) %>%
#   select(iso3c, ID, Provider, Country)
# 
# print(paste('Missing', missing))
# Wikimedia, Pixabay
