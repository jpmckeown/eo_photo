# 2nd step, relies on df1 created by get_photo_data_1

# get Wikimedia FileURL from early run API data
load('data/imgdata.Rda')

# remember that in imgdata Namibia iso2c is 'NB'
# imgdata[imgdata$Country=='Namibia',]$iso2c

# add iso3c column to imgdata
imgdata$iso3c <- countrycode(imgdata$Country, origin = 'country.name', destination = 'iso3c')
# imgdata[imgdata$Country=='Namibia',]$iso3c  # check is fixed

# cannot match Attribution until FileURL reconstructed like in imgdata
df2 <- readRDS('data/df1.rds')
# temporarily reduce columns to make checking easier
df2 <- df2 %>% 
  select('iso3c', 'ID', 'InfoURL', 'FileURL')

imgdata_earlyFileURL <- imgdata %>% 
  select(iso3c, ID, Info_address, File_address)
names(imgdata_earlyFileURL) <- c('iso3c', 'ID', 'InfoURL', 'EarlyFileURL')

df2_earlyFileURL <- left_join(df2, imgdata_earlyFileURL)

# can get Attribution HTML now all the earlier FileURL ready
imgdata <- imgdata %>% 
  select(iso3c, ID, Info_address, File_address, Attribution)
names(imgdata) <- c('iso3c', 'ID', 'InfoURL', 'FileURL', 'Attribution')

# mresult <- merge(x=df1, y=imgdata, by=c('iso3c'='iso3c', 'ID'='ID', 'InfoURL'='Info_address', 'FileURL'='File_address'), all.x=TRUE)
jresult <- left_join(df1, imgdata)

loopEnd <- 1 # nrow(imgdata)

for (oldRun  in 1:loopEnd) {
  
  iso_2c <- imgdata$iso2c[oldRun]
  photo_id <- imgdata$ID[oldRun]
  
  row <- df[df$iso2c==iso_2c,]
  print(row)

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
}

saveRDS(df2, 'data/df2.rds')
#write_tsv(df2, 'data/photo_step_2.tsv')
