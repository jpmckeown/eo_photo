# 6th step, relies on df5 and ArtistHTML

df5 <- readRDS('data/df5.rds')
df6 <- df5

# Earlier efforts failed to extract Artist separately from ArtistURL
#  because sometimes Artist string is divided, and may have 2 links e.g.
# <a href='https://en.wikipedia.org/wiki/User:Khaufle' class='extiw' title='wikipedia:User:Khaufle'>Khaufle</a> at <a href='https://en.wikipedia.org/wiki/' class='extiw' title='wikipedia:'>English Wikipedia</a>
# When not separable go back to old way of using ArtistLine as a whole.

# Conditions = no link provided
# link is Wikimedia flagged doesnt exist
# link not valid

artist_vector <- rep(NA, nrow(df6))
artistURL_vector <- rep(NA, nrow(df6))

if (df6$Provider == 'Unsplash') {
  
# if link flagged invalid just use Artist name
# if (grepl('page does not exist', artistLine)) {
#   artist <- sub('<.*">', '', artistLine)
#   artist <- sub('</a>', '', artist)
#   df6$Artist[i] <- artist
# } else {
#   df6$ArtistHTML[i] <- artistLine
# }

# where artist's URL is provided, the artistLine is 
# a complete Anchor tag containing href with \" quotes
# Examples
# <a href='//commons.wikimedia.org/wiki/User:Alexxx1979' title='User:Alexxx1979'>Alexxx1979</a>
# AL1 "<a href=\"//commons.wikimedia.org/wiki/User:Albinfo\" title=\"User:Albinfo\">Albinfo</a>"
# AG3 <a rel='nofollow' class='external text' href='https://www.flickr.com/people/21187388@N06'>University of the Fraser Valley</a>

# get artist and URL
# if (!grepl('<a', artistLine)) {
#   artist <- artistLine
# } else {
#   artist <- sub('<.*">', '', artistLine)
#   artist <- sub('</a>', '', artist)
#   
#   artist_URL <- sub("^<a .*href=(.)+>.*", "\\1", artistLine)
#   # artist_URL <- sub("^<a .*href=(\"|')(.+)(\"|')>.*", "\\1", artistLine)
# }

# get artist_URL and check if valid and isn't missing at Provider
# print(paste('artist', artist))
} # end Wikimedia

# "Unsplash photographers appreciate it as it provides exposure to their work and encourages them to continue sharing.
if (df6$Provider == 'Unsplash') {
  df6$LicenseURL <- 'https://unsplash.com/license'
}

if (df6$Provider == 'Pixabay') {
  df6$License <- 'Pixabay License'
  df6$LicenseURL <- 'https://pixabay.com/service/license/' # longer https://pixabay.com/service/terms/#license
}

if (df6$Provider == 'Pixnio') {
  df6$License <- 'CC0'
  df6$LicenseURL <- 'https://pixnio.com/creative-commons-license'
}

# if you are using content for editorial purposes, you must include the following credit adjacent to the content or in audio/visual production credits: “FreeImages.com/Artist’s Member Name.”
if (df6$Provider == 'FreeImages') {
  df6$License <- 'FreeImages.com'
  df6$LicenseURL <- 'https://www.freeimages.com/license'
}