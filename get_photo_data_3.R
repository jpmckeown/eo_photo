# 3rd step after get_photo_data_1.R and relies on df2 created there
# currently skipping 2nd step

# from FileURL reconstruct missing InfoURL
# for Wikimedia, FreeImages

fileURL_to_infoURL <- function(fileURL) {
  imgName <- fileURL_to_imgName(fileURL)
  infoURL <- paste0('https://commons.wikimedia.org/wiki/File:', imgName)
  return(infoURL)
}

imgName_to_infoURL <- function(imgName) {
  infoURL <- paste0('https://commons.wikimedia.org/wiki/File:', imgName)
  return(infoURL)
}

fileURL_to_imgName <- function(fileURL) {
  # keeping extension as part of imgName
  # imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/[A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+/([A-Z|a-z|0-9|-|_|%]+[.jpg|.JPG|.jpeg|.JPEG|.png|.PNG]+)/.*', '\\1', fileURL)
  imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/[A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+/([A-Z|a-z|0-9|_|%|Ä|Å|‡|.|-]+)/.*', '\\1', fileURL)
  return(imgName)
}

infoURL_to_imgName <- function(infoURL) {
  imgName <- sub('https://commons.wikimedia.org/wiki/File:(.*)', '\\1', uploadURL)
  return(imgName)
}

fileURL_to_folder <- function(fileURL) {
  folder <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/([A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+)/.*', '\\1', fileURL)
  return(paste0(folder, '/'))
}

# https://images.freeimages.com/images/large-previews/e0c/kuwait-tower-1451754.jpg
# https://www.freeimages.com/photo/kuwait-tower-1451754
freeimages_fileURL_to_imgName <- function(fileURL) {
  imgName <- sub('https://images.freeimages.com/images/large-previews/[a-z|0-9]+/(.*)[.]+[a-z|A-Z]+', '\\1', fileURL)
  return(imgName)
}
freeimages_imgName_to_infoURL <- function(imgName) {
  infoURL <- paste0('https://www.freeimages.com/photo/', imgName)
  return(infoURL)
}

# sub('', '', testFileAddr)
photoCount <- 0

# cannot filter because need to keep spreadsheet whole

# order by Provider desc then process Wikimedia_count rows only
# wikimedia_count <- sum(df$Provider == 'Wikimedia')
# df2 <- df[order(df$Provider, decreasing=TRUE), ]

df3 <- df
# Wikimedia image name includes extension; FreeImages does not.

loopEnd <- nrow(df3) # wikimedia_count # 

for (i in 1:loopEnd) {
  
  fileURL <- as.character(df3[i, 'FileURL'])
  infoURL <- as.character(df3[i, 'InfoURL'])
  
  if (df3[i, 'Provider'] == 'Wikimedia') { 
    
    if (fileURL != '' && infoURL == '') {
      
      imgName <- fileURL_to_imgName(fileURL)
      infoURL <- imgName_to_infoURL(imgName)
      print(paste(i, infoURL))
      
      df3[i, 'ImageName'] <- imgName
      df3[i, 'InfoURL'] <- infoURL
      
    } # where InfoURL missing
  } # end Wikimedia
  
  if (df3[i, 'Provider'] == 'FreeImages') {
    
    if (fileURL != '' && infoURL == '') {
      
      imgName <- freeimages_fileURL_to_imgName(fileURL)
      infoURL <- freeimages_imgName_to_infoURL(imgName)
      print(paste(i, infoURL))
      
      df3[i, 'ImageName'] <- imgName
      df3[i, 'InfoURL'] <- infoURL
      
    } # where InfoURL missing
    
  } # end FreeImages
  
} # loop df3 rows

# freeimages_count <- sum(df$Provider == '')
# df3 <- df[order(df3$Provider), ]
# loopEnd <- freeimages_count 
  
# write_tsv(df3, 'data/photo_step_2.tsv')
