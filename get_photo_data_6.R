# 6th step, uses df5 ArtistHTML and also Attribution
#  extract Artist and (if available) ArtistURL
#  from old Attribution, otherwise Step 2 was wasted time!

attrib_to_html <- function(attrib) {
  #result <- gsub("^<a (.+)\\>(.+)<\\/a>", "\\1 \\2", attrib)
  #result <- gsub("^<a (.+)>(.+)<\\/a>", c('\\1', '\\2'), attrib)
  result <- sub("^<a (.+)\\>(.+)<\\/a>.*", "\\2", attrib)
  return(result)
}
attrib <- "<a rel='nofollow' class='external text' href='https://www.flickr.com/people/41000732@N04'>Adam Jones</a> from Kelowna, BC, Canada, <a href='https://commons.wikimedia.org/wiki/File:Farmer_in_Field_-_Theth_Village_-_Northern_Albania_(41838452595).jpg'>Farmer_in_Field_-_Theth_Village_-_Northern_Albania_(41838452595).jpg</a>; <a href='https://creativecommons.org/licenses/by-sa/2.0'>CC BY-SA 2.0</a>, via Wikimedia Commons"

attrib_to_html(attrib)

df6 <- readRDS('data/df5.rds')


artist_vector <- rep(NA, nrow(df6))
artistURL_vector <- rep(NA, nrow(df6))

loopEnd <- nrow(df6)
for (i in 1:loopEnd) {
  changed <- 0
  
  attrib <- df6$Attribution[i]
  artist_html <- df6$ArtistHTML[i]
  
  if (df6$Provider[i] == 'Wikimedia') {
    
    if ( !is.na(attrib) ) {
      if (!is.na(artist_html)) {
        print('Attribution but already has ArtistHTML!')
      }
      
      # get ArtistHTML, License, LicenseURL
      
      }
    } # end: old Attribution available

    # Now from ArtistHTML extract Artist and ArtistURL especially if
    # link is Wikimedia flagged as not existing, or detect link invalid

    ##### Earlier effort failed due to varying formats of ArtistHTML #####
    
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
    
  if (grepl('page does not exist', attrib)) {
    artist <- sub("^<a (.+)>(.+)<\\/a>", "\\2", attrib)
    print(paste(i, artist))
  }
    if ( !is.na(artist_html) ) {
    
      if (grepl('page does not exist', artist_html)) {
        artist <- sub("^<a (.+)>(.+)<\\/a>", "\\2", artist_html)
        print(paste(i, artist))
      }
    } # end artist_html
    
  } # end Wikimedia 
  
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

