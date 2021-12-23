# 2nd step, relies on df1 created by get_photo_data_1

# get Wikimedia FileURL from early run API data
load('data/imgdata.Rda')

# retrospectively fix IDs in imgdata to match Photos doc
# imgdata$ID[114] <- 2  # Fiji
# imgdata$ID[115] <- 3  
# imgdata$ID[214] <- 2  # Mauritania
# imgdata$ID[215] <- 3  
# imgdata$ID[34] <- 4  # was 5 
# saveRDS(imgdata, 'data/imgdata.rds')

# remember that in imgdata Namibia iso2c is 'NB'
# imgdata[imgdata$Country=='Namibia',]$iso2c

# add iso3c to imgdata to avoid Namibia problem
imgdata$iso3c <- countrycode(imgdata$Country, origin = 'country.name', destination = 'iso3c')
# imgdata[imgdata$Country=='Namibia',]$iso3c  # check is fixed

# check if anomalies in ID numbering of imgdata
prev_iso3c = ''
prev_ID <- 0
anomaly_imgdata <- 0
for (i in 1:nrow(imgdata)) {
  iso3c = imgdata$iso3c[i]
  ID <- imgdata$ID[i]
  if (ID != prev_ID + 1 && iso3c == prev_iso3c) {
    incr(anomaly_imgdata)
    print(paste(iso3c, ID))
  }
  prev_ID <- ID
  prev_iso3c <- iso3c
}
print(paste(anomaly_imgdata, 'non-consecutive ID in imgdata'))
# 1st run found 19 non-consecutive IDs

# cannot match Attribution until FileURL reconstructed like in imgdata
df2 <- readRDS('data/df1.rds')
# temporarily reduce columns to make checking easier
# df2 <- df2 %>% 
#   select('iso3c', 'ID', 'InfoURL', 'FileURL')

imgdata_earlyFileURL <- imgdata %>% 
  select(iso3c, ID, Info_address, File_address)
names(imgdata_earlyFileURL) <- c('iso3c', 'ID', 'InfoURL', 'EarlyFileURL')

df2_earlyFileURL <- left_join(df2, imgdata_earlyFileURL)

# check that FileURL == EarlyFileURL where both present
check <- df2_earlyFileURL$FileURL == df2_earlyFileURL$EarlyFileURL
which(check == FALSE)
# 198 199 267 268 354  # was not expecting any, good I did check!
# after Fiji and Iran fixed, only 355
# after Mauritius fixed, none
#  but worrying as MR 1&2 both ID shifted but only id2 flagged

# visual comparison confirms gaps where InfoURL but no early FileAddr are when photo didnt exist in early set.

# copy earlier File_address to fill gaps in FileURL 
#  only trust early where InfoURL present in early run.
df2_fillGaps <- df2_earlyFileURL

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
# remove column of earlier File_address
df2 <- subset(df2_fillGaps, select = -c(EarlyFileURL))

# temporary save before Attribution
saveRDS(df2, 'data/df2.rds')

##### can get Attribution HTML now all the earlier FileURL ready #####

# imgdata <- imgdata %>% 
#   select(iso3c, ID, Info_address, File_address, Attribution)
# names(imgdata) <- c('iso3c', 'ID', 'InfoURL', 'FileURL', 'Attribution')
# 
# # mresult <- merge(x=df1, y=imgdata, by=c('iso3c'='iso3c', 'ID'='ID', 'InfoURL'='Info_address', 'FileURL'='File_address'), all.x=TRUE)
# jresult <- left_join(df1, imgdata)
# 
# loopEnd <- 1 # nrow(imgdata)
# 
# for (oldRun  in 1:loopEnd) {
#   
#   iso_2c <- imgdata$iso2c[oldRun]
#   photo_id <- imgdata$ID[oldRun]
#   
#   row <- df[df$iso2c==iso_2c,]
#   print(row)

  # fileURL <- as.character(df2[i, 'FileURL'])
  # infoURL <- as.character(df2[i, 'InfoURL'])
  # 
  # if (fileURL != '' && infoURL == '') {
  #   
  #   imgName <- fileURL_to_imgName(fileURL)
  #   infoURL <- imgName_to_infoURL(imgName)
  #   print(paste(i, infoURL))
  #   
  #   df2[i, 'ImageName'] <- imgName
  #   df2[i, 'InfoURL'] <- infoURL
  # }
#}

#saveRDS(df2, 'data/df2.rds')
#write_tsv(df2, 'data/photo_step_2.tsv')


# check for anomalous ID numbering in df2
# prev_iso3c = ''
# prev_ID <- 0
# anomaly_df <- 0
# for (i in 1:nrow(df2)) {
#   iso3c = df2$iso3c[i]
#   ID <- df2$ID[i]
#   if (ID != prev_ID + 1 && iso3c == prev_iso3c) {
#     incr(anomaly_df)
#     print(paste(iso3c, ID))
#   }
#   prev_ID <- ID
#   prev_iso3c <- iso3c
# }
# print(paste(anomaly_df, 'non-consecutive ID in df2'))
# Result "0 non-consecutive ID in df2"