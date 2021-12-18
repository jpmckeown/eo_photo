# 4th step relies on df3 from get_photo_data_3.R
#  relies on complete InfoURL and ImageName columns
df4 <- df3

# use Wikimedia API to get 'folders' for FileURL construction
# also get artist and license string and URL
# can get URL of original image file (max size) from Wiki API

original_API <- paste0('https://commons.wikimedia.org/w/api.php?action=query&titles=File:', imgName, '&prop=imageinfo&iiprop=url&format=json')

original_JSON <- jsonlite::fromJSON(original_API)
original <- unlist(original_JSON)
original_URL <- original[ grepl('imageinfo.url', names(original)) ]
original_URL <- unname(original_URL)

# if missing FileURL need API to get folders
# get double folder where versions of image file stored
folders <- originalURL_to_folders(original_URL)