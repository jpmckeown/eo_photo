# 2nd step after get_photo_data_1.R and relies on df created there

# for Wikimedia only add InfoURL where missing (will have FileURL) 
fileURL_to_infoURL <- function(fileAddr) {
  imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/([A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+)/.*', '\\1', fileURL)
  return(infoAddr)
}

fileURL_to_imgName <- function(fileURL) {
  imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/[A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+/([A-Z|a-z|0-9|-|_|%]+[.jpg|.JPG|.jpeg|.JPEG|.png|.PNG]+)/.*', '\\1', fileURL)
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
#fileAddr_to_folder(testFileAddr)

# sub('', '', testFileAddr)
photoCount <- 0

# cannot filter because need to keep spreadsheet whole
# order by Provider desc then process Wikimedia_count rows only
wikimedia_count <- sum(df$Provider == 'Wikimedia')
df2 <- df[order(df$Provider, decreasing=TRUE), ]

loopEnd <- wikimedia_count # nrow(df2)

for (i in 1:loopEnd) {
  #if (df2[i, 'Provider'] == 'Wikimedia') {
  
  fileURL <- as.character(df2[i, 'FileURL'])
  infoURL <- as.character(df2[i, 'InfoURL'])
  #print(paste(i, infoURL, fileURL))
  
  if (fileURL != '' && infoURL == '') {
    
    # extract filename to use in API
    imgName <- fileURL_to_imgName(fileURL)
    folder <- fileURL_to_folder(fileURL)
    print(paste(i, imgName, fileURL))
  }
}