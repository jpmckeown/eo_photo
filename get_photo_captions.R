# get revised photo captions from Gsheet
library(tidyverse)
library(readxl)

df9 <- readRDS('../eo_html/data/df9.rds')

original_xls <- "data/EO_photo_providers.xlsx"
photo_import <- read_excel(original_xls, sheet = "Photos", skip = 0)

# check df9 well sorted by Country and photo ID
# sort photo_import and look for differences

df10 <- df9 %>% 
  arrange(Country, ID)
which(df10[,1] != df9[,1])
# many because 3 countries extra ID 3 are at end of list

