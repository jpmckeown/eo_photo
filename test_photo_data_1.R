# Verify df1 data from photos
df1 <- readRDS('data/df1.rds')

# assume all Wikimedia FileURL have same format - is it true?

# when Wiki FileURL not NA, is /thumb/ always present ?

df1 %>%
  filter(Provider == 'Wikimedia') %>%
  select(Country, ID, FileURL) %>%
  filter(!is.na(FileURL)) %>%
  filter(!grepl('thumb', FileURL))
  
# manual test shows URL worls, and if /thumb/ inserted it fails
# so step 3 will have to check for these.
