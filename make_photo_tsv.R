# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# loop lines, if country set country;
# a country may contain zero pairs of caption & image
# each caption is always followed by an address
# 
# states = readyCountry, readyCaption, readyAddress

# write csv with columns:
# country, caption, file_address, commons_address

library(readr)
library(stringr)
library(countrycode)
library(Hmisc)

include('helpers.R')

infile <- 'eo_caption_address.txt'

outfile <- 'fromPhotoDoc.tsv'
if (file.exists(outfile)){
  file.remove(outfile)
}
out <- file(outfile, open='a')

# header row for output
dataOut <- paste0('Country\tCode\tID\tCaption\tFile_address\tInfo_address')
cat(dataOut, sep='\n', file=out)

con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 21) {
    #print(paste(skipRow, caption, line)) #(paste(country, line))
    
    if (grepl('^[*][*][*]', line)) {
      # get country
      country <- sub("^[*][*][*][ ]*([A-Z|a-z| ]*)[-|:| ]*", "\\1", line)
      country <- str_to_title(country)
      if (country == 'Guineabissau') {
        country <- 'Guinea-Bissau'
      }
      iso <- countrycode(country, origin = 'country.name', destination = 'iso2c')
      photoID <- 0
    }
    
    # caption
    if(grepl('^#', line)) {
      caption <- cleanCaption(line)
    } else if(grepl('^~', line)) {
      noImageCount = noImageCount + 1
    }
    
    # address
    if(grepl('https', line)) {
      # each photo increments ID even if not currently used
      photoID <- photoID +1
      
      if(grepl('wikimedia', line)) {
        
        if(grepl('commons.wikimedia', line)){
          landingPageAddr <- line
          imageFileAddr <- ''
        } else if(grepl('upload.wikimedia', line)) {
          imageFileAddr <- line
          landingPageAddr <- ''
        } 
        dataOut <- paste0(country, '\t', iso, '\t', photoID, '\t', caption, '\t', imageFileAddr, '\t', landingPageAddr)
        cat(dataOut, sep='\n', file=out)
      }
      caption <- ''
      imageFileAddr <- ''
      landingPageAddr <- ''
    }
  } # ignore blank lines
} # loop input line by line
close(con)
print(i)
close(out)
