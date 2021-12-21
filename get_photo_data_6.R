# 6th step, assemble CreditHTML for all Providers
#  no API call so can be run across whole df repeatedly

df5 <- readRDS('data/df5.rds')
df6 <- df5

loopEnd <- nrow(df6)
for (i in 1:loopEnd) {
  
  # if CreditHTML exists we use that 
  if (!is.na(df6$CreditHTML)) {

    # Artist, ArtistURL, License, LicenseURL, ImageName, InfoURL
    #  also provider prefix and suffix, or special way of assembling?
    # https://creativecommons.org/licenses/publicdomain/
    
    if (df6$Provider == 'Wikimedia') {
      credit_html <-
    }
    
    if (df6$Provider == 'Unsplash') {
      credit_html <-
    }
    
    if (df6$Provider == 'Pixnio') {
      credit_html <- '<a href="https://pixnio.com/">Pixnio free images</a>'
    }
    
    if (df6$Provider == 'Pixabay') {
      credit_html <-
    }
    
    if (df6$Provider == 'FreeImages') {
      credit_html <-
    }
    
    df6$CreditHTML[i] <- credit_html    
  }
  
}
linkLicense <- paste0("<a href='", licenseURL_line2, "'>", licens, "</a>")


    
saveRDS(df6, 'data/df6.rds')