# 8th step, assemble CreditHTML for all Providers
#  no API call so can be run across whole df repeatedly
# Why have rows changed index? e.g. 247 now at 244
# library(tidyverse)

# df8 <- read_tsv('data/EO_photo_providers_edited.tsv')
# df8$Artist[which(df8$Artist == '<copy paste>')] <- as.character(NA)
# df8$ArtistURL[which(df8$ArtistURL == '<right-click username; Copy link address>')] <- as.character(NA)
# df8$ArtistURL[which(df8$ArtistURL == '<not available>')] <- as.character(NA)
# 
# df8 <- df8[with(df8, order(Country, ID)), ]
# 
# df8['CreditHTML'] <- as.character(NA)

# df8$LicenseURL[which(is.na(df8$LicenseURL))] <- 'https://en.wikipedia.org/wiki/Public_domain'

loopEnd <- nrow(df8)

# for (i in 1:loopEnd) {}
for (i in 1:10) {

  provider <- df8$Provider[i]  
  artist <- df8$Artist[i]
  artist_url <- df8$ArtistURL[i]
  license <- df8$License[i]
  license_url <- df8$LicenseURL[i]
  info_url <- df8$InfoURL[i]
  file_url <- df8$FileURL[i]
  credit_html <- ''

  # Artist, ArtistURL, License, LicenseURL, ImageName, InfoURL
  #  also provider prefix and suffix, or special way of assembling?
  # https://creativecommons.org/licenses/publicdomain/
  
  if (provider == 'Wikimedia') {
    
    # Artist: ; License: ; Image:
    # always Artist, License, ImageName, InfoURL
    # optional fields ArtistURL, ArtistInfo, LicenseURL
    if ( !is.na(artist_url) && !is.na(artist)) {
      credit_html <- paste0('<a href="', artist_url, '">', artist, '</a>', '; License <a href="', license_url, '">', license, '</a>', '; Image ', '<a href="', info_url, '">', info_url, '</a> via Wikimedia Commons.')
    } else if ( !is.na(artist) ) {
        credit_html <- paste0(artist, '; License <a href="', license_url, '">', license, '</a>', '; Image ', '<a href="', info_url, '">', info_url, '</a> via Wikimedia Commons.')
    } else {
      credit_html <- paste0('License <a href="', license_url, '">', license, '</a>', '; Image ', 'a href="', info_url, '">', info_url, '</a> via Wikimedia Commons.')
    }
  }
  
  if (provider == 'Unsplash') {
    if ( !is.na(info_url) ) {
      credit_html <- paste0('<a href="', license_url, '">Unsplash License</a> Image: ', info_url)
    } else if ( !is.na(file_url) ) {
      credit_html <- paste0('<a href="', license_url, '">Unsplash License</a> Image: ', file_url)
    }
  }
  
  # Photo by Artist on Pixnio
  if (provider == 'Pixnio') {
    credit_html <- paste0('Photo by <a href="', info_url, '">', artist, '</a> on Pixnio <a href="https://pixnio.com/">free images</a> license <a href="', license_url, '">', license, '</a>')
  }
  
  if (provider == 'Pixabay') {
    if ( !is.na(artist_url) ) {
      credit_html <- paste0('<a href="', artist_url, '">', artist, '</a>', 'License: <a href="', license_url, '">Pixabay</a>', ' Image: ', 'a href="', info_url, '">', info_url, '</a>')
    } else {
      credit_html <- paste0(artist, '; License; <a href="', license_url, '">Pixabay</a>', '; Image ', 'a href="', info_url, '">', info_url, '</a>')
    }
  }
  
  # if you are using content for editorial purposes, you must include the following credit adjacent to the content: “FreeImages.com/Artist’s Member Name.”
  if (provider == 'FreeImages') {
    if ( !is.na(artist_url) && !is.na(artist) ) {
      credit_html <- paste0('<a href="', license_url, '">', license, '</a> / Artist: <a href="', artist_url, '">', artist, '</a>')
    } else if ( !is.na(artist) ) {
      credit_html <- paste0('<a href="', license_url, '">', license, '</a> / Artist: ' , df8$Artist[i], '</a>')
    } else {
      credit_html <- paste0('<a href="', license_url, '">', license, '</a>')
    }
  }
  print(paste(i, credit_html))
  df8$CreditHTML[i] <- credit_html 
}

# Test!
# which(is.na(df8$CreditHTML)) # no NA
# 
# saveRDS(df8, 'data/df8.rds')
# 
#   # # if CreditHTML exists we use that
#   # if (!is.na(df8$CreditHTML[i])) {
# 
# artist_remove_photoby <- function(artist) {
#   result <- sub('[P|p]hoto by[:]*[ ]*(.*)', '\\1', artist)
#   return(result)
# }
# # May prefix 'Photo by: ' on all credits.
# 
# artist_remove_user <- function(artist) {
#   result <- sub("[U|u]ser[:]*[ ]*(.*)", '\\1', artist)
#   return(result)
# }

# 59 Rapponi caused API error
# pixabay_ID_to_df <- function(imgName) {
#   Pixabay_API <- 'https://pixabay.com/api/?key=24587231-d8363fed1919782211f48ccc6&'
#   this_API <- paste0(Pixabay_API, 'id=', imgName)
#   this_JSON <- jsonlite::fromJSON(this_API, simplifyVector = TRUE)
#   # returns list, 3rd item is dataframe
#   df <- this_JSON[['hits']]
#   return(df)
# }

# "user_id":5475750,"user":"Graham-H"  Yes this matches what InfoURL says
# https://pixabay.com/users/graham-h-5475750/  so ArtistURL can be constructed.

# for (i in 94:loopEnd) {
#   if ( provider[i] == 'Pixabay' && !is.na(df8$Artist[i]) ) { #  
#     imgName <- df8$ImageName[i]
#     
#     Pixabay_df <- pixabay_ID_to_df(imgName)
#     artist <- Pixabay_df$user
#     u_id <- Pixabay_df$user_id
#     fileurl <- Pixabay_df$webformatURL
#     artistURL <- paste0('https://pixabay.com/users/', artist, '-', u_id, '/')
#     df8$Artist[i] <- artist
#     df8$ArtistURL[i] <- artistURL
#     #df8$FileURL[i] <- fileurl
#     #df8$ArtistURL[i] <- paste0('https://pixabay.com/users/', df8$Artist[i], '-', df8$ImageName[i], '/')
#     #print(paste(i, df8$Artist[i], df8$ImageName[i], df8$ArtistURL[i]))
#     print(df8$ArtistURL[i])
#   }
# }

#df7a <- readRDS('data/df7.rds')

  # clean up artist
  # if (!is.na(artist )) {
  #   if (grepl('hoto by', artist)) {
  #     artist <- artist_remove_photoby(artist)      
  #   }
  #   if (grep(pattern = 'User|user', x = artist)) {
  #     artist <- artist_remove_user(artist)
  #   }
  # }