# Verify df3 data from photos
df3 <- readRDS('data/df3.rds')

# folder should be NA or 5 characters length */**/
nchar(df3$folder)
df3 %>%
  select(Country, iso3c, ID, folder) %>%
  filter(!is.na(folder)) %>%
  filter(nchar(folder) != 5)
