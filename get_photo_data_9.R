# Step 9 download photos other platforms and new Wikimedia

df9 <- readRDS('data/df8.rds')
# column records if image downloaded already Y/N
df9['file'] <- as.character(NA) 

missing <- 0
#df9$file[i] <- 'Y'

# count/identify missing FileURL
loopEnd <- nrow(df9)
for (i in 1:loopEnd) {
  
  provider <- df9$Provider[i]
  iso3c <- df9$iso3c[i]
  img_id <- df9$ID[i]
  info_url <- df9$InfoURL[i]
  file_url <- df9$FileURL[i]
  
  print(paste(iso3c, img_id))
  
  # if (is.na(df8$FileURL[i]) && is.na(df8$w640_URL[i])) {
  #   incr(missing)
  # }
}

# df8_missing <- df8 %>%
#   filter(is.na(FileURL)) %>%
#   filter(is.na(w640_URL)) %>%
#   select(iso3c, ID, Provider, Country)
# 
# print(paste('Missing', missing))
# Wikimedia, Pixabay
