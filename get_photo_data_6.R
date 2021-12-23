# 6th step, relies on df5 and ArtistHTML

df6 <- readRDS('data/df5.rds')

# Conditions needing attention
# link is Wikimedia flagged as not existing
# link not valid

# DONE Look at ArtistHTML column, categorise & find targeted cases
# easier to test after column populated by step 5

# Earlier efforts failed to extract Artist and ArtistURL due to varying formats:

# Artist has affiliation, and a 2nd link
# <a href='https://en.wikipedia.org/wiki/User:Khaufle' class='extiw' title='wikipedia:User:Khaufle'>Khaufle</a> at <a href='https://en.wikipedia.org/wiki/' class='extiw' title='wikipedia:'>English Wikipedia</a>

# 2nd link to personal website
# <a href='//commons.wikimedia.org/wiki/User:JJ_Harrison' title='User:JJ Harrison'>JJ Harrison</a> (<a rel='nofollow' class='external free' href='https://www.jjharrison.com.au/'>https://www.jjharrison.com.au/</a>)

# Artist all inside anchor; 1 link; missing https 
# <a href='//commons.wikimedia.org/wiki/User:Albinfo' title='User:Albinfo'>Albinfo</a> AL1

# As above but Artist continues after anchor
# <a href='//commons.wikimedia.org/wiki/User:Liveon001' title='User:Liveon001'>Liveon001</a> © Travis K. Witt
# <a href='//commons.wikimedia.org/wiki/User:Serouj' title='User:Serouj'>Serouj</a> (courtesy of Ani Vardanyan)

# Flagged URL; redlink? Artist clean inside anchor
# <a href='//commons.wikimedia.org/w/index.php?title=User:Goodfaith17&amp;action=edit&amp;redlink=1' class='new' title='User:Goodfaith17 (page does not exist)'>Goodfaith17</a>

# Superfluous class and nofollow; Artist continues after anchor
# <a rel='nofollow' class='external text' href='https://www.flickr.com/people/41000732@N04'>Adam Jones</a> from Kelowna, BC, Canada

# As above but artist inside anchor.
# <a rel='nofollow' class='external text' href='https://www.flickr.com/people/21187388@N06'>University of the Fraser Valley</a> AG3

# no link, only Artist; wouldnt matter as ArtistHTML is simply Artist
# Paulo César Santos

artist_vector <- rep(NA, nrow(df6))
artistURL_vector <- rep(NA, nrow(df6))

loopEnd <- nrow(df6)
for (i in 1:loopEnd) {
  changed <- 0
  
  artist_html <- df6$ArtistHTML[i]
  
  if (df6$Provider[i] == 'Wikimedia' && !is.na(artist_html)) {
    
    if (grepl('page does not exist', artist_html)) {
      artist <- sub("^<a (.+)>(.+)<\\/a>", "\\2", artist_html)
    }
  
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
  
  } # end Wikimedia with ArtistHTML

# "Unsplash photographers appreciate it as it provides exposure to their work and encourages them to continue sharing.
  # if (df6$Provider == 'Unsplash') {
  #   df6$LicenseURL <- 'https://unsplash.com/license'
  # }
  # 
  # if (df6$Provider == 'Pixabay') {
  #   df6$License <- 'Pixabay License'
  #   df6$LicenseURL <- 'https://pixabay.com/service/license/' # longer https://pixabay.com/service/terms/#license
  # }
  # 
  # if (df6$Provider == 'Pixnio') {
  #   df6$License <- 'CC0'
  #   df6$LicenseURL <- 'https://pixnio.com/creative-commons-license'
  # }
  # 
  # # if you are using content for editorial purposes, you must include the following credit adjacent to the content or in audio/visual production credits: “FreeImages.com/Artist’s Member Name.”
  # if (df6$Provider == 'FreeImages') {
  #   df6$License <- 'FreeImages.com'
  #   df6$LicenseURL <- 'https://www.freeimages.com/license'
  # }

} # photo loop

saveRDS(df6, 'data/df6.rds')

# from step 2
# if (!grepl('href', artist_html)) {
#   artist <-  artist_html
# } 
# artist <- sub("^(.*), <a .*", "\\1", attrib)
# artist_url <- sub("^(.*), <a .*", "\\1", attrib)

