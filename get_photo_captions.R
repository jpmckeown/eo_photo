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

# sheet imported lacks final column CreditHTML
# should copy new captions to df10, 
# in case other columns were processed after import.

import <- photo_import %>% 
  arrange(Country, ID)
which(df10[,1] != import[,1])
which(df10[,3] != import[,3]) # 398 was "3.0"

# data types of columns need checking also
str(photo_import) # all char
str(df10) # all chr except ID is numeric

import[398,3] <- "3"
import$ID <- as.numeric(import$ID)
 
which(df9[,4] != photo_import[,4 ]) # unhelpful
which(df10[,4] != import[,4 ]) 
# 7   8  10  25  26  27  35  37 103 125 159 210 211 214 217 220 235 239 243 
# 248 249 250 283 287 288 291 315 390 398 463 567

df10$Caption <- import$Caption
df10$CreditHTML[239] <- "GRAPH from Ouagadougou Partnership/Adapted by J.Bardi/CFR; Terms of use <a href=\"https://www.thinkglobalhealth.org/terms-use\">https://www.thinkglobalhealth.org/terms-use</a>; Image <a href=\"https://www.thinkglobalhealth.org/sites/default/files/2020-03/JF.MB-W.AfricaOP-3.18.20-Graph-2-THREE-TWO.jpg\">https://www.thinkglobalhealth.org/sites/default/files/2020-03/JF.MB-W.AfricaOP-3.18.20-Graph-2-THREE-TWO.jpg</a>."

df10$Caption[239] <- "The country is part of the Ouagadougou Partnership which supports the nine Francophone countries in West Africa† to address the need for modern contraception in the region."
saveRDS(df10, '../eo_html/data/df10.rds')
