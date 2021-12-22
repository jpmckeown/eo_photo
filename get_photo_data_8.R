# use API to get URL for download
# No that was done in Step 4, just check if any missing before download

df8 <- readRDS('data/df6.rds')
missing <- 0

# count/identify missing URL
for (i in 1:nrow(df8)) {
  if (is.na(df8$FileURL[i]) && is.na(df8$w640_URL[i])) {
    incr(missing)
  }
}

df8_missing <- df8 %>%
  filter(is.na(FileURL)) %>%
  filter(is.na(w640_URL)) %>%
  select(iso3c, ID, Provider, Country)

print(paste('Missing', missing))
# Wikimedia, Pixabay
