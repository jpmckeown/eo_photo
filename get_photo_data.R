# Makefile for EO photo processing
rm(list = ls())

# from Country Data spreadsheet
load('data/eo.Rda')

# libraries and helper functions
source('get_photo_data_0.R')
# keep functions but clear variables
rm(list = setdiff(ls(), lsf.str()))

# check data from Photos Doc
source('verify_photo.R')
rm(list = setdiff(ls(), lsf.str()))

# old photos recycle 640
source('old_photo_use.R')

# get id, caption, URL from Photo gdoc
source('get_photo_data_1.R')
source('clean_get_photo_data_1.R')

# merge previously acquired Wikimedia data
source('get_photo_data_2.R')
save(df2, file='data/df2.Rda')
rm(list = setdiff(ls(), lsf.str()))

# reconstruct missing Info_URL, from FileURL get ImageName and folder
# load('data/df2.Rda')
df <- readRDS('data/df1.Rda')
source('get_photo_data_3.R')
save(df3, file='data/df3.Rda')
rm(list = setdiff(ls(), lsf.str()))
   
# where missing File_URL, use API to get ImageName and folder
df3 <- readRDS('data/df3.Rda')
source('get_photo_data_4.R')
save(df4, file='data/df4.Rda')
rm(list = setdiff(ls(), lsf.str()))

# use API to get attribution data, from ImageName
# assemble CreditHTML
load('data/df4.Rda')
source('get_photo_data_5.R')
save(df5, file='data/df5.Rda')
rm(list = setdiff(ls(), lsf.str()))

# download photo files
load('data/d5.Rda')
source('get_photo_data_6.R')
save(df6, file='data/df6.Rda')
rm(list = setdiff(ls(), lsf.str()))

# get width and height
load('data/d6.Rda')
source('get_photo_data_7.R')
save(df7, file='data/df7.Rda')
rm(list = setdiff(ls(), lsf.str()))

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
