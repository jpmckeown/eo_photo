# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address

# because comparing with list of countries having data
load('data/eo.Rda')

country_count <- 0
goodURL <- 0
badURL <- 0
expectPhoto <- FALSE  # Caption must precede URL
country_found <- vector()
iso3c_found <- vector()

infile <- 'data/fromGoogleDoc.txt'  # copy manually from web
con = file(infile, "r")
allRead <- readLines(con, warn = FALSE)

for (i in seq_along(allRead)) {
  line = allRead[i]
  
  # ignore header and blank lines
  if (line != '' && i > 20) {
    if (!grepl('[a-zA-Z0-9]+', line)) {
      # print(paste('Exclude', line))
    } else {
      
      # country
      if (grepl('^[*][*][*]', line)) {
        
        # get country name
        country <- sub("^[*][*][*][ ]*([A-Z|a-z| ]*)[-|:| ]*", "\\1", line)
        # not needed while only checking countries included
        # country <- str_to_title(country)
        # if (country == 'Guineabissau') {
        #   country <- 'Guinea-Bissau'
        # }
  # print(country)     
        country_count <- country_count + 1
        country_found[country_count] <- country
  
        iso3c <- countrycode(country, origin = 'country.name', destination = 'iso3c')
        iso3c_found[country_count] <- iso3c
        
        # makes Myanmar (Burma); Congo - Brazzaville; Congo - Kinshasa
        # country <- countrycode(iso3c, origin = 'iso3c', destination = 'country.name')
        
        # ready to count photos in this country      
        photoID <- 0
        
      } # country label
      
      # photo
      if (expectPhoto) {
        photoID <- photoID +1
  
        if(grepl('https', line)) {
          goodURL <- goodURL + 1
          # if (url.exists(line)) {
        print(paste(iso3c, photoID, line))          
          # } else {
          #   print(paste('DODGY?===', photoID, line))
          # }
  
          
        } else if (grepl('jpg', line) || grepl('png', line) || grepl('JPG', line) || grepl('PNG', line) || grepl('svg', line)  || grepl('Photo-', line)) {
          # lacks https
          badURL <- badURL + 1
          
        } else {
          print(paste('ID', photoID, country, 'no URL', line, caption))
        }
        expectPhoto <- FALSE
      }
      
      # caption
      if (grepl('^#', line)) {
        # caption <- cleanCaption(line)  # not yet
        expectPhoto <- TRUE
      }
      
      # unspecified
      if (grepl('pixabay.com/photos/search', line)) {
        print(paste(country, 'ID', photoID, line))
      }
  
    } # GoogleDoc pagebreak symbol excluder
  } # blank line excluder
} # read lines

close(con)

# check for duplicates
if (length(unique(iso3c_found)) == length(iso3c_found)) {
  print('Countries appear once each, no duplicates')
}

# identify missing countries (versus those on data sheet)

missing_iso3c <- setdiff(as.vector(eo$iso3c), iso3c_found)
print(missing_iso3c)
saveRDS(missing_iso3c, 'data/countryData_lack_photo.rds')

# identify countries with photos but not in eo datasheet
extra_iso3c <- setdiff(iso3c_found, as.vector(eo$iso3c))
print(extra_iso3c)
saveRDS(extra_iso3c, 'data/photos_lack_countryData.rds')

print(countrycode(missing_iso3c, origin = 'iso3c', destination = 'country.name'))

print(paste('Countries with photos =', length(iso3c_found)))
print(paste('Country data lacking photo =', length(missing_iso3c)))

saveRDS(iso3c_found, 'data/countries_with_photo.rds')
