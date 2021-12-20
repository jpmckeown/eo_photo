# functions for photo_data
library(tidyverse)
library(readr)
library(stringr)
library(stringi)
library(countrycode)
library(tools)
library(RCurl)

incr <- function(x) { eval.parent(substitute(x <- x + 1)) }

firstCap <- function(str) {
  Capstr <- paste0(toupper(substring(str, 1,1)), substring(str, 2))
  return(Capstr)
}
 
cleanCaption <- function(line) {
  # stops odd characters
  caption <- stri_encode(line, '', 'UTF-8')
  # remove prefix
  caption <- sub('#', '', caption)
  caption <- firstCap(caption)
  # remove trailing spaces
  caption <- trimws(caption, which = "right", whitespace = "[ \t\r\n]")
  # add final period if missing
  if (!str_sub(caption, -1) == '.') {
    # cope with American-style quote after period
    if (!str_sub(caption, -2) == '.') {
      caption <- paste0(caption, '.')
    }
  }
  return(caption)
}

url_exists <- function(x, non_2xx_return_value = FALSE, quiet = FALSE,...) {
  
  suppressPackageStartupMessages({
    require("httr", quietly = FALSE, warn.conflicts = FALSE)
  })
  
  # you don't need these two functions if you're alread using `purrr`
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

cleanURL <- function(url) {
  # remove any characters before http
  line <- gsub('.*http', 'http', line)
  # remove any trailing space
  url <- trimws(line, which = "right", whitespace = "[ \t\r\n]")
  return(url)
}

fileURL_to_infoURL <- function(fileURL) {
  imgName <- fileURL_to_imgName(fileURL)
  infoURL <- paste0('https://commons.wikimedia.org/wiki/File:', imgName)
  return(infoURL)
}

imgName_to_infoURL <- function(imgName) {
  infoURL <- paste0('https://commons.wikimedia.org/wiki/File:', imgName)
  return(infoURL)
}

fileURL_to_imgName <- function(fileURL) {
  # keeping extension as part of imgName
  # imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/[A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+/([A-Z|a-z|0-9|-|_|%]+[.jpg|.JPG|.jpeg|.JPEG|.png|.PNG]+)/.*', '\\1', fileURL)
  imgName <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/[A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+/([A-Z|a-z|0-9|_|%|Ä|Å|‡|.|-]+)/.*', '\\1', fileURL)
  return(imgName)
}

infoURL_to_imgName <- function(infoURL) {
  imgName <- sub('https://commons.wikimedia.org/wiki/File:(.*)', '\\1', infoURL)
  return(imgName)
}

fileURL_to_folder <- function(fileURL) {
  folder <- sub('https://upload.wikimedia.org/wikipedia/commons/thumb/([A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+)/.*', '\\1', fileURL)
  return(paste0(folder, '/'))
}

originalURL_to_folder <- function(originalURL) {
  folder <- sub('https://upload.wikimedia.org/wikipedia/commons/([A-Z|a-z|0-9]+/[A-Z|a-z|0-9]+)/.*', '\\1', originalURL)
  return(paste0(folder, '/'))
}
