# Makefile for EO photo processing
rm(list = ls())

# from Country Data spreadsheet
eo <- readRDS('data/eo.rds')
# until home lack script to refresh eo from Country Data sheet
# visual inspection finds 186 rows and Guadeloupe gone (as recommended)
# eo <- eo %>% 
#   filter(iso3c != 'GLP')
# saveRDS(eo, 'data/eo.rds')

# libraries and helper functions
source('get_photo_functions.R')

# check data from Photos Doc
source('verify_photo.R')
# keep functions but clear variables
rm(list = setdiff(ls(), lsf.str()))

# old photos recycle 640
source('old_photo_use.R')

# get id, caption, URL from Photo gdoc
source('get_photo_data_1.R')

rm(list = setdiff(ls(), lsf.str()))
df1 <- readRDS('data/df1.rds')

# merge previously acquired Wikimedia data
# CreditHTML, FileURL (from InfoURL)
# where iso2c + ID + imgName all match
source('get_photo_data_2.R')
saveRDS(df2, file='data/df2.rds')
rm(list = setdiff(ls(), lsf.str()))

# reconstruct missing Info_URL, from FileURL get ImageName and folder
source('get_photo_data_3.R')
saveRDS(df3, file='data/df3.rds')
rm(list = setdiff(ls(), lsf.str()))
   
# 4. where missing File_URL, use API to get ImageName and folder and URL
# not done many yet
source('get_photo_data_4.R')
saveRDS(df4, file='data/df4.rds')
rm(list = setdiff(ls(), lsf.str()))

# use API to get ArtistHTML and Licence from ImageName
source('get_photo_data_5.R')
saveRDS(df5, file='data/df5.rds')
rm(list = setdiff(ls(), lsf.str()))

# extract Artist and ArtistURL, where possible
source('get_photo_data_6.R')
saveRDS(df6, file='data/df6.rds')
rm(list = setdiff(ls(), lsf.str()))

# Prepare for sharing
# merge w640 into FileURL, then delete w640
# what others type in? no FileURL for Pixnio & cannot find Unsplash 
# colour cell background; Gsheets allows Protected Ranges
# could use gsheet API to automate this as a Step

df7 <- df6
for (i in 1:nrow(df7)) {
  if(is.na(df7$FileURL[i])) {
    print(paste(i, 'FileURL missing'))
    if (!is.na(df7$w640_URL[i])) {
      print('sub')
      df7$FileURL[i] <- df7$w640_URL[i]
    }
  }  
}
df7 <- df7[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'Artist', 'ArtistExtra', 'ArtistURL', 'Artist2ndURL', 'ArtistHTML', 'License', 'LicenseURL', 'InfoURL', 'FileURL', 'folder', 'iso2c', 'ImageName', 'OriginURL', 'Attribution')]
# only reorder just before exporting TSV for web
df_by_provider <- df7[order(df7$Provider), ]
write_tsv(df_by_provider, 'data/photos_by_provider.tsv')

for (i in 1: nrow(df7)) {
  if(df7$Provider[i] == 'Pixabay') {
    if(is.na(df7$FileURL[i])) {
      dfp <- pixabay_ID_to_df(df7$ImageName[i])
      
      print(paste(i, df7$ImageName[i], dfp$webformatURL))
    }
  }  
}

# rename photo files with iso3c, outside Steps
# maybe Step 2 could helpful start?

# 7 - download photo files

# 8 - get width and height, for separate table

# 9 - assemble CreditHTML for all Providers

# 10 - screenshot InfoURL pages, and store
#   name iso3c_photoID_info.jpg

source('get_photo_data_7.R')
saveRDS(df7, file='data/df7.rds')
rm(list = setdiff(ls(), lsf.str()))

df7 <- readRDS('data/df7.rds')
source('get_photo_data_8.R')
saveRDS(df8, file='data/df8.rds')
rm(list = setdiff(ls(), lsf.str()))


# Pixnio = Artist, License, LicenseURL   
# (no ArtistURL, that offered when downloading is just InfoURL) 

# Pixabay = Artist, ArtistURL (link from circle photo)  [no ImgName; standard license]

# FreeImages = Artist, ArtistURL (link from name)   [no ImageName; standard license]

# Unsplash = Artist, ArtistURL (link from name)
# Photo by 2Photo Pots on Unsplash
# https://unsplash.com/@2photopots
# https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText (site)

# small 640w, medium 1920w

# ask Sara for data using a form rather than spreadsheet

# Pixabay: "Giving credit to the artist or Pixabay is not necessary but is always appreciated by our community."
# Don't portray identifiable people in a bad light or in a way that is offensive.

# FreeImages: if you are using content for editorial purposes, you must include the following credit adjacent to the content or in audio/visual production credits: “FreeImages.com/Artist’s Member Name.”

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
