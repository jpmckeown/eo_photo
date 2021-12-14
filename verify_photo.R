# Google Doc pasted in data/fromGoogleDoc.txt

# country name prefixed *** 3 asterisks
# caption # wikimedia; @ other source; £ other landing; ~ no image

# a country may contain 0+ pairs of caption and image
# each caption must be followed by a URL address

# Output must be Tab-separated because commas in caption, attribution, and URLs
# Goal is tsv with columns: Country, iso3c, (photo)ID, format, width, height, Caption, Attribution, File_address, Commons_address

library(readr)
library(stringr)
library(countrycode)
library(Hmisc)
library(RCurl)

# include('helpers.R')
cleanCaption <- function(line) {
  caption <- sub('#', '', line)
  caption <- capitalize(caption)
  # remove trailing spaces
  caption <- trimws(caption, which = "right", whitespace = "[ \t\r\n]")
  # add final period if missing
  if (!str_sub(caption, -1) == '.') {
    caption <- paste0(caption, '.')
  }
  return(caption)
}

url_exists <- function(x, non_2xx_return_value = FALSE, quiet = FALSE,...) {
  
  suppressPackageStartupMessages({
    require("httr", quietly = FALSE, warn.conflicts = FALSE)
  })
  
  # you don't need thse two functions if you're alread using `purrr`
  # but `purrr` is a heavyweight compiled pacakge that introduces
  # many other "tidyverse" dependencies and this doesnt.
  
  capture_error <- function(code, otherwise = NULL, quiet = TRUE) {
    tryCatch(
      list(result = code, error = NULL),
      error = function(e) {
        if (!quiet)
          message("Error: ", e$message)
        
        list(result = otherwise, error = e)
      },
      interrupt = function(e) {
        stop("Terminated by user", call. = FALSE)
      }
    )
  }
  
  safely <- function(.f, otherwise = NULL, quiet = TRUE) {
    function(...) capture_error(.f(...), otherwise, quiet)
  }
  
  sHEAD <- safely(httr::HEAD)
  sGET <- safely(httr::GET)
  
  # Try HEAD first since it's lightweight
  res <- sHEAD(x, ...)
  
  if (is.null(res$result) || 
      ((httr::status_code(res$result) %/% 200) != 1)) {
    
    res <- sGET(x, ...)
    
    if (is.null(res$result)) return(NA) # or whatever you want to return on "hard" errors
    
    if (((httr::status_code(res$result) %/% 200) != 1)) {
      if (!quiet) warning(sprintf("Requests for [%s] responded but without an HTTP status code in the 200-299 range", x))
      return(non_2xx_return_value)
    }
    
    return(TRUE)
    
  } else {
    return(TRUE)
  }
}

# c(
#   "http://content.weird/",
#   "http://rud.is/this/path/does/not_exist",
#   "https://www.amazon.com/s/ref=nb_sb_noss_2?url=search-alias%3Daps&field-keywords=content+theft", 
#   "https://www.google.com/search?num=100&source=hp&ei=xGzMW5TZK6G8ggegv5_QAw&q=don%27t+be+a+content+thief&btnK=Google+Search&oq=don%27t+be+a+content+thief&gs_l=psy-ab.3...934.6243..7114...2.0..0.134.2747.26j6....2..0....1..gws-wiz.....0..0j35i39j0i131j0i20i264j0i131i20i264j0i22i30j0i22i10i30j33i22i29i30j33i160.mY7wCTYy-v0", 
#   "https://rud.is/b/2018/10/10/geojson-version-of-cbc-quebec-ridings-hex-cartograms-with-example-usage-in-r/"
# ) -> some_urls
# 
# data.frame(
#   exists = sapply(some_urls, url_exists, USE.NAMES = FALSE),
#   some_urls,
#   stringsAsFactors = FALSE
# ) %>% dplyr::tbl_df() %>% print()

country_count <- 0
goodURL <- 0
badURL <- 0
expectPhoto <- FALSE

country_found <- vector()
iso3c_found <- vector()

infile <- 'data/fromGoogleDoc.txt'
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
        #   print(paste(photoID, line))          
        # } else {
        #   print(paste('DODGY?===', photoID, line))
        # }

        
      } else if (grepl('https', line) || grepl('jpg', line) || grepl('png', line) || grepl('JPG', line) || grepl('PNG', line) || grepl('svg', line)  || grepl('Photo-', line)) {
        badURL <- badURL + 1
        
      } else {
        print(paste('ID', photoID, country, 'no URL', line, caption))
      }
      expectPhoto <- FALSE
    }
    
    # caption
    if (grepl('^#', line)) {
      caption <- cleanCaption(line)
      expectPhoto <- TRUE
    }
    
    # unspecified
    if (grepl('pixabay.com/photos/search', line)) {
      print(paste(country, 'ID', photoID, line))
    }

  }
  } # blank line excluder
} # read lines

close(con)

# check for duplicates
# if (length(unique(iso3c_found)) == length(iso3c_found)) {
#   print('Countries appear once each, no duplicates')
# }

# identify missing countries (versus those on data sheet)
# load('data/eo.Rda')

missing_iso3c <- setdiff(as.vector(eo$iso3c), iso3c_found)
# 
countrycode(missing_iso3c, origin = 'iso3c', destination = 'country.name')
