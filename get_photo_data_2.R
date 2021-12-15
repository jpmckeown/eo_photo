# 2nd step after get_photo_data_1.R and relies on df created there

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

freeimages_fileURL_to_infoURL <- function(fileAddr) {
  imgName <- fileURL_to_imgName(fileURL)
  infoURL <- paste0('https://commons.wikimedia.org/wiki/File:', imgName)
  return(infoURL)
}

# sub('', '', testFileAddr)
photoCount <- 0

# cannot filter because need to keep spreadsheet whole
# order by Provider desc then process Wikimedia_count rows only
wikimedia_count <- sum(df$Provider == 'Wikimedia')
df2 <- df[order(df$Provider, decreasing=TRUE), ]

loopEnd <- wikimedia_count # nrow(df2)

for (i in 1:loopEnd) {
  #if (df2[i, 'Provider'] == 'Wikimedia') { # not needed, only Wiki rows
  
  fileURL <- as.character(df2[i, 'FileURL'])
  infoURL <- as.character(df2[i, 'InfoURL'])
  
  if (fileURL != '' && infoURL == '') {
    
    imgName <- fileURL_to_imgName(fileURL)
    infoURL <- imgName_to_infoURL(imgName)
    print(paste(i, infoURL))
    
    df2[i, 'ImageName'] <- imgName
    df2[i, 'InfoURL'] <- infoURL
  }
}

write_tsv(df2, 'data/photo_step_2.tsv')
