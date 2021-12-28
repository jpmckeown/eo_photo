# rename image files with iso3c
# check ID and ImageName both match

imgdata <- readRDS('data/imgdata.rds')

for (i in 1:nrow(df2_earlyFileURL)) {
  
  infourl <- df2_earlyFileURL$InfoURL[i]
  fileurl <- df2_earlyFileURL$FileURL[i]
  earlier <- df2_earlyFileURL$EarlyFileURL[i]
  #print(paste(i, infourl, fileurl, earlier))
  
  if (!is.na(infourl) && is.na(fileurl) && !is.na(earlier)) {
    df2_fillGaps$FileURL[i] <- earlier
    print(paste(i, earlier))
  }  
}