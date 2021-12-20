# 3rd step after get_photo_data_1.R and relies on df2 created there
# currently skipping 2nd step

# from FileURL reconstruct missing InfoURL
# for Wikimedia, FreeImages

# FreeImages = Provider
# https://images.freeimages.com/images/large-previews/e0c/kuwait-tower-1451754.jpg
# https://www.freeimages.com/photo/kuwait-tower-1451754

freeimages_fileURL_to_imgName <- function(fileURL) {
  imgName <- sub('https://images.freeimages.com/images/large-previews/[a-z|0-9]+/(.*)[.]+[a-z|A-Z]+', '\\1', fileURL)
  return(imgName)
}

freeimages_infoURL_to_imgName <- function(infoURL) {
  imgName <- sub('https://www.freeimages.com/photo/(.*)', '\\1', infoURL)
  return(imgName)
}

freeimages_imgName_to_infoURL <- function(imgName) {
  infoURL <- paste0('https://www.freeimages.com/photo/', imgName)
  return(infoURL)
}

photoCount <- 0
# cannot filter because need to keep spreadsheet whole
# use rows ordered with non-Wikimedia first
df1 <- readRDS('data/df1.rds')
df3 <- df1
# Wikimedia image name includes extension; FreeImages does not.

loopEnd <- nrow(df3) # wikimedia_count # 

for (i in 1:loopEnd) {
  
  fileURL <- df3[i, 'FileURL']
  infoURL <- df3[i, 'InfoURL']
  
  if (df3[i, 'Provider'] == 'Wikimedia') { 
    
    # InfoURL present
    if (!is.na(infoURL)) {
      
      imgName <- infoURL_to_imgName(infoURL)
      print(paste(i, imgName))
      
      df3[i, 'ImageName'] <- imgName
      
    } # end InfoURL present

    # InfoURL missing
    if (!is.na(fileURL) && is.na(infoURL)) {
      
      imgName <- fileURL_to_imgName(fileURL)
      infoURL <- imgName_to_infoURL(imgName)
      # print(paste(i, infoURL))
      
      df3[i, 'ImageName'] <- imgName
      df3[i, 'InfoURL'] <- infoURL
      
    } # end InfoURL missing
    
    # from FileURL can extract folders
    if (!is.na(fileURL)) {
      
      # function copes with a FileURL not including "/thumb/"
      folder <- fileURL_to_folder(fileURL)
      df3[i, 'folder'] <- folder
    }
    
  } # end Wikimedia
  
  if (df3[i, 'Provider'] == 'FreeImages') {
    
    # InfoURL present
    if (!is.na(infoURL)) {
      
      imgName <- freeimages_infoURL_to_imgName(infoURL)
      print(paste(i, imgName))
      
      df3[i, 'ImageName'] <- imgName
      
    } # end InfoURL present
    
    if (!is.na(fileURL) && is.na(infoURL)) {
      
      imgName <- freeimages_fileURL_to_imgName(fileURL)
      infoURL <- freeimages_imgName_to_infoURL(imgName)
      # print(paste(i, infoURL))
      
      df3[i, 'ImageName'] <- imgName
      df3[i, 'InfoURL'] <- infoURL
      
    } # end InfoURL missing
    
  } # end FreeImages
  
} # loop df3 rows

# count missing InfoURL, all providers
sum(is.na(df3$InfoURL))

# test if all Wikimedia now have InfoURL
infos <- df3 %>% 
  filter(Provider == 'Wikimedia') %>% 
  select(InfoURL)
sum(is.na(infos))

# test if all Wikimedia now have ImageName
inames <- df3 %>% 
  filter(Provider == 'Wikimedia') %>% 
  select(ImageName)
sum(is.na(inames))

# test if Wikimedia with FileURL now have folder
folds <- df3 %>% 
  filter(Provider == 'Wikimedia' && !is.na('FileUrl')) %>% 
  select(folder)
sum(is.na(folds))

saveRDS(df3, file='data/df3.rds')

# write_tsv(df3, 'data/photo_step_3.tsv')
