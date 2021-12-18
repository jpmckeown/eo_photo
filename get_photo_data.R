# Makefile for EO photo processing
rm(list = ls())

# from Country Data spreadsheet
load('data/eo.Rda')

# libraries and helper functions
source('get_photo_data_0.R')

# check data from Photos Doc
source('verify_photo.R')
source('clean_verify_photo.R')

# get id, caption, URL from Photo gdoc
source('get_photo_data_1.R')
source('clean_get_photo_data_1.R')

# merge previously acquired Wikimedia data
source('get_photo_data_2.R')

# reconstruct missing Info_URL where possible
source('get_photo_data_3.R')



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
