# 7th step, assemble CreditHTML for all Providers
#  no API call so can be run across whole df repeatedly

artist_remove_photoby <- function(artist) {
  result <- sub('[P|p]hoto by[:]*[ ]*(.*)', '\\1', artist)
  return(result)
}
# May prefix 'Photo by: ' on all credits.

artist_remove_user <- function(artist) {
  result <- sub("[U|u]ser[:]*[ ]*(.*)", '\\1', artist)
  return(result)
}

df7 <- readRDS('data/df6.rds')

# ad hoc fix Wikimedia link errors
df7$ArtistInfo[247] <- df7$Artist[247] # Own work
df7$Artist[247] <- 'Loriski' # manually from InfoURL

loopEnd <- nrow(df6)
for (i in 1:loopEnd) {
  
  artist <- df7$Artist[i]
  
  # clean up artist
  if (!is.na(artist)) {
    if (grepl('hoto by', artist)) {
      artist <- artist_remove_photoby(artist)      
    }
    if (grep(pattern = 'User|user', x = artist)) {
      artist <- artist_remove_user(artist)
    }
  }
  
  # if CreditHTML exists we use that 
  if (!is.na(df6$CreditHTML)) {

    # Artist, ArtistURL, License, LicenseURL, ImageName, InfoURL
    #  also provider prefix and suffix, or special way of assembling?
    # https://creativecommons.org/licenses/publicdomain/
    
    if (df6$Provider == 'Wikimedia') {
      
      # Artist: ; License: ; Image:
      # always Artist, License, ImageName, InfoURL
      # optional fields AristURL, ArtistInfo, LicenseURL
      
      credit_html <- paste0('<a href="', df6$ArtistURL[i], '">', df6$Artist[i], '</a>', '<a href="', df6$LicenseURL[i], '">', df6$License[i], '</a>')
    }
    
    if (df6$Provider == 'Unsplash') {
      credit_html <- ''
    }
    
    # Photo by Artist on Pixnio
    if (df6$Provider == 'Pixnio') {
      credit_html <- paste0('Photo by <a href="', df6$InfoURL, '">', df6$Artist[i], '</a> on Pixnio <a href="https://pixnio.com/">free images</a> license <a href="', df6$LicenseURL[i], '">', df6$License[i], '</a>')
    }
    
    if (df6$Provider == 'Pixabay') {
      credit_html <- ''
    }
    
    # if you are using content for editorial purposes, you must include the following credit adjacent to the content: “FreeImages.com/Artist’s Member Name.”
    if (df6$Provider == 'FreeImages') {
      credit_html <- paste0('<a href="', df6$LicenseURL[i], '">', df6$License[i], '</a> / Artist: <a href="', df6$ArtistURL[i], '">', df6$Artist[i], '</a>')
    }
    
    df6$CreditHTML[i] <- credit_html    
  }
  
}
linkLicense <- paste0("<a href='", licenseURL_line2, "'>", licens, "</a>")


    
saveRDS(df6, 'data/df6.rds')