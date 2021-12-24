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

##### can get Attribution HTML now all the earlier FileURL ready #####

# What to match on? remember that df2 now has FileURL gaps filled

imgdata_Credit <- imgdata %>%
  select(iso3c, ID, Info_address, File_address, Attribution)
names(imgdata_Credit) <- c('iso3c', 'ID', 'InfoURL', 'FileURL', 'Attribution')

# mresult <- merge(x=df1, y=imgdata, by=c('iso3c'='iso3c', 'ID'='ID', 'InfoURL'='Info_address', 'FileURL'='File_address'), all.x=TRUE)
df2_Attrib <- left_join(df2, imgdata_Credit)

#saveRDS(df2_Attrib, 'data/df2.rds')

# extract ArtistHTML, License, and LicenseURL from earlier Attribution html #####

# add new columns for artist and license
df2 <- df2_Attrib 
df2['ArtistHTML'] <- as.character(NA)
# df2['Artist'] <- as.character(NA)   # ArtistHTML processed in Step 6 
# df2['ArtistURL'] <- as.character(NA)
df2['License'] <- as.character(NA)
df2['LicenseURL'] <- as.character(NA)

df2 <- df2[, c('Country', 'iso3c', 'ID', 'Caption', 'Provider', 'ArtistHTML', 'License', 'LicenseURL', 'InfoURL', 'FileURL', 'iso2c', 'Attribution')]

for (i in 1:nrow(df2)) {
  attrib <- df2$Attribution[i]
  if (!is.na(attrib)) {  #  && df2$Provider == 'Wikimedia'
    
    artist_html <- sub("^(.*), <a .*", "\\1", attrib)
    license_html <- sub("^.*, <a .*; (<a .*), via Wikimedia Commons", "\\1", attrib)
    license <- sub("^<a href='.*'>(.*)<.*", "\\1", license_html)
    license_url <- sub("^<a href='(.*)'.*", "\\1", license_html)
    
    df2$ArtistHTML[i] <- artist_html
    df2$License[i] <- license
    df2$LicenseURL[i] <- license_url
  }
}

# visual inspection ITA1 KWT1 PNG2 License=‘Attribution’ & url empty no NA
 
# df2_ <- df2 %>% mutate(License = replace(License, License == 'Attribution' && iso2c == 'PG'), 'Ok Tedi Mine CMCA Review') # Fails
df2$License[419] <- 'Ok Tedi Mine CMCA Review'
df2$LicenseURL[419] <- NA
# European Space Agency, error in Wikimedia data
df2$License[c(279,302)] <- 'CC BY-SA 3.0 igo'
df2$LicenseURL[c(279,302)] <- 'https://creativecommons.org/licenses/by-sa/3.0/igo/deed.en'
df2$ArtistHTML[c(279,302)] <- 'European Space Agency: contains modified Copernicus Sentinel data 2019'

# check any ArtistHTML not string or NA; due to error in step 5
# df2 <- readRDS('data/df2.rds') # dangerous here
sum(is.na(df2$ArtistHTML)) # 221
sum(df2$ArtistHTML == '') # none

saveRDS(df2, 'data/df2.rds')
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