# Makefile for EO photo processing
rm(list = ls())

# from Country Data spreadsheet
load('data/eo.Rda')

# libraries and helper functions
source('get_photo_data_0.R')

# check data from Photos Doc
source('verify_photo.R')
# keep functions but clear variables
rm(list = setdiff(ls(), lsf.str()))

# old photos recycle 640
source('old_photo_use.R')

# get id, caption, URL from Photo gdoc
source('get_photo_data_1.R')
rm(list = setdiff(ls(), lsf.str()))
df1 = df
df1 <- readRDS('data/df1.rds')
# only reorder just before exporting TSV for web
df1a <- df1[order(df1$Provider), ]
write_tsv(df1a, 'data/photo_step_1a.tsv')

# merge previously acquired Wikimedia data
source('get_photo_data_2.R')
saveRDS(df2, file='data/df2.rds')
rm(list = setdiff(ls(), lsf.str()))

# reconstruct missing Info_URL, from FileURL get ImageName and folder
# load('data/df2.Rda')
df1 <- readRDS('data/df1.rds')
source('get_photo_data_3.R')
saveRDS(df3, file='data/df3.rds')
rm(list = setdiff(ls(), lsf.str()))
   
# where missing File_URL, use API to get ImageName and folder
df3 <- readRDS('data/df3.rds')
source('get_photo_data_4.R')
saveRDS(df4, file='data/df4.rds')
rm(list = setdiff(ls(), lsf.str()))

# use API to get Artist and Licence from ImageName
df4 <- readRDS('data/df4.rds')
source('get_photo_data_5.R')
saveRDS(df5, file='data/df5.rds')
rm(list = setdiff(ls(), lsf.str()))

# assemble CreditHTML for al Providers
df5 <- readRDS('data/df5.rds')
source('get_photo_data_6.R')
saveRDS(df6, file='data/df6.rds')
rm(list = setdiff(ls(), lsf.str()))

# download photo files
df6 <- readRDS('data/df6.rds')
source('get_photo_data_7.R')
saveRDS(df7, file='data/df7.rds')
rm(list = setdiff(ls(), lsf.str()))

# get width and height
df7 <- readRDS('data/df7.rds')
source('get_photo_data_8.R')
saveRDS(df7, file='data/df8.rds')


#############################################

# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Steps 2-6 in other files
# 1. do all possible without API call or download
# 2. get file URL
# 3. download and name with iso3c and photoID
# 4. get dimensions
# 5. get artist and licence with API
# 6. write credit HTML

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address
