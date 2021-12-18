# gather old photo info
# iso3c, ID, format, width, height

library(magick)
library(countrycode)

dfo <- data.frame(Country = character(),
                 iso2c = character(),
                 iso3c = character(),
                 ID = numeric(),
                 Caption = character(),
                 Artist = character(),
                 ArtistURL = character(),
                 License = character(),
                 LicenseURL = character(),
                 ImageName = character(),
                 InfoURL = character(),
                 FileURL = character(),
                 CreditHTML = character(),
                 Format = character(),
                 Width = numeric(),
                 Height = numeric(),
                 stringsAsFactors=FALSE) 

dfo <- imgdata
# dfo <- subset(dfo, select = -c(Attribution))
names(dfo) <- c("Country", "iso2c", "ID", "Caption", 'Attribution', "FileURL", "InfoURL")
dfo$iso3c <- ''
dfo$Artist <- ''
dfo$ArtistURL <- ''
dfo$License <- ''
dfo$LicenseURL <- ''
dfo$ImageName <- ''
dfo$CreditHTML <- ''
dfo$Format <- ''
dfo$Width <- 0
dfo$Height <- 0
# setdiff(names(df), names(dfo)) # check columns present
column_order <- c('Country', 'iso3c', 'ID', 'Caption', 'Artist', 'ArtistURL', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'FileURL', 'Format', 'Width', 'Height', 'CreditHTML', 'iso2c', 'Attribution')
dfo <- dfo[, column_order]

# old photos stored in web make folder
dir <- '../eo_html/photo/'

# loop imgdata # No! file extension is unknown, loop dir instead
loopEnd <- 3 # nrow(dfo)
for (o in seq_along(1:loopEnd)) {
  attrib <- dfo$Attribution[o]
  #print(attrib)
  imgName <- sub("commons.wikimedia.org/wiki/File:([\w\d_]+)'>[.]+", "\\1", attrib)
  print(imgName)
}

old_photos <- list.files(dir)
for (o in 1:length(old_photos)) {
  # print(old_photos[o])
  #img <- image_read(paste0(dir, old_photos[o]))
  #print(image_info(img)$width)

}
