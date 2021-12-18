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
dfo <- subset(dfo, select = -c(Attribution))
names(dfo) <- c("Country", "iso2c", "ID", "Caption", "FileURL", "InfoURL")
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
column_order <- c('Country', 'iso3c', 'ID', 'Caption', 'Artist', 'ArtistURL', 'License', 'LicenseURL', 'ImageName', 'InfoURL', 'FileURL', 'Format', 'Width', 'Height', 'CreditHTML', 'iso2c')
dfo <- dfo[, column_order]

# old photos stored in web make folder
# dir <- '../eo_html/photo/'

# maybe use imgdata ID list instead
# old_photo <- list.files(dir)
# yy <- image_read(paste0(dir, xx))
# print(image_info(yy)$width)

# loop imgdata
for (o in seq_along(1:nrow(imgdata))) {
  
}