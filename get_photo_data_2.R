# 2nd step, relies on df1 created by get_photo_data_1
library(tidyverse)

# retrieve Wikimedia attribution HTML and extract components.
# Only used because there was earlier process calling API
load('data/imgdata.Rda')

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
