# rename image files with iso3c
# check ID and ImageName both match

# loop new df get iso2c and ID, make name, if file exists copy to 640 folder, rename with iso3c
# then check if iso3c+ID matchs ImageName.  No that fails because dont know suffix;
# instead copy all files to new folder and loop; No! because oldest fake photos are still there!

# df8 <- readRDS('data/df8.rds')
# imgdata <- readRDS('data/imgdata.rds')
# dir.create('w640/')

old_folder <- 'photo/'
new_folder <- 'w640/'
oldPhotos <- list.files(old_folder) 

# only act if in imgdata, to eliminate fake photos
for (o in 1:nrow(imgdata)) {
  # info_addr <- imgdata$Info_address[o]
  old_fileurl <- imgdata$File_address[o]
  old_id <- imgdata$ID[o]
  old_iso2c <- imgdata$iso2c[o]
  
  # confirm file exists
  fn <- paste0(old_iso2c, '_', old_id)
  print(paste(o, fn))
  # if (grepl()) {
  #   
  # }
  #print(paste(o, file_addr))
}
# Test, none missing
# which(is.na(imgdata$File_address))

#file.copy(file.path(old_folder,list_files), new_folder)

# test! old and new match
# imgFiles <- list.files(new_folder) 
# length(imgFiles) == length(list_files)

# for (i in 1:length(imgFiles)) {
# }

# for (i in 1:nrow(df8)) {
#   
#   iso2c <- df8$iso2c[i]
#   img_id <- df8$ID[i]
#   info_url <- df8$InfoURL[i]
#   file_url <- df8$FileURL[i]
#   imgName <- df8$ImageName[i]
#   
#   oldPath <- paste0('../eo_html/data/', iso2c, )
# 
# }


# earlier <- df2_earlyFileURL$EarlyFileURL[i]
# #print(paste(i, infourl, fileurl, earlier))
# 
# if (!is.na(infourl) && is.na(fileurl) && !is.na(earlier)) {
#   df2_fillGaps$FileURL[i] <- earlier
#   print(paste(i, earlier))
# }  