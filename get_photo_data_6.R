# 6th step, uses df5 ArtistHTML and also Attribution
#  extract Artist and (if available) ArtistURL
#  from old Attribution, otherwise Step 2 was wasted time!

attrib_to_html <- function(attrib) {
  #result <- gsub("^(.*), <a href='(.*)'>.*; <a href='(http.*)'>(.*)</a>.*", "\\1 \\3 \\4", attrib)
  s <- str_match(attrib, "^(.*), <a href='(.*)'>.*; <a href='(http.*)'>(.*)</a>.*")
  return(s)
}

artisthtml_with_1url <- function(html) {
  s <- str_match(html, "^<a .*href ?= ?'(.*?)'.*>(.*)</a>(.*)$")
  return(s)
}

artisthtml_with_2urls <- function(html) {
  s <- str_match(html, "^<a .*href ?= ?'(.*?)'.*>(.*)</a>(.*)<a .*href ?= ?'(.*?)'.*>(.*)</a>(.*)$")
  return(s)
}

# due to unknown state of df 5 after messup while ad hoc fixing 6 missing in step5; may need to retrieve archived df5.rds from other folder and then run step 5 fix on it again
# df6 <- readRDS('data/df5.rds')

artist_vector <- df5$Artist # rep(NA, nrow(df6))
artistURL_vector <- rep(NA, nrow(df6))
link2nd_vector <- rep(NA, nrow(df6))
artExtra_vector <- rep(NA, nrow(df6))
link0 <- 0; link1 <- 0; link2 <- 0

loopEnd <- nrow(df6)
for (i in 1:loopEnd) {
  changed <- 0
  
  attrib <- df6$Attribution[i]
  artist_html <- df6$ArtistHTML[i]
  artist <- df6$Artist[i]
  
  if (df6$Provider[i] == 'Wikimedia') {
    
    # from ArtistHTML extracting Artist and ArtistURL because helps if
    # link is Wikimedia flagged as not existing, or detect link invalid
    
    # where artist's URL provided, artistLine has 1 or 2 Anchor href with \" quotes

    if ( is.na(artist_html) && !is.na(artist) ) {
      print(paste(i, 'lacks ArtistHTML and Artist extracted manually'))
    } else {
      
      # Count number of links in ArtistHTML
      links <- str_count(artist_html, "href ?=")
      
      if (links == 0) {
        artist <- artist_html
        print(paste(i, artist))
        incr(link0)
        # 18 artists in df5, maybe manually found
        if (is.na(artist_vector[i])) {
          artist_vector[i] <- artist          
        }
        
      } else if (links == 1) {
        s <- artisthtml_with_1url(artist_html)
        #print(paste(i, 'one', s[2], s[3], s[4]))
        incr(link1)
        artistURL_vector[i] <- s[2]
        if (is.na(artist_vector[i])) {
          artist_vector[i] <- s[3]
        }
        artExtra_vector[i] <- s[4]
        if (grepl('page does not exist', artist_html)) {
          artistURL_vector[i] <- NA  
        }
  
      } else if (links ==  2) {
        s <- artisthtml_with_2urls(artist_html)
        #print(paste(i, s[2], s[3], s[4], s[5], s[6]))
        incr(link2)
        artistURL_vector[i] <- s[2]
        if (is.na(artist_vector[i])) {
          artist_vector[i] <- s[3]
        }
        link2nd_vector[i] <- s[5]
        artExtra_vector[i] <- s[6]
        # if (grepl('page does not exist', artist_html)) {
        #   artistURL_vector[i] <- NA  
        # }
  
      } else if (links >  2) {
        print(paste(i, 'contains more than 2 links'))
      
      } else {
        print(paste(i, 'links not a number'))
      }
    } # end test if ArtistHTML present
    
  } # end Wikimedia 
  
  # "Unsplash photographers appreciate as it provides exposure to their work and encourages them to continue sharing.
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

} # photo loop

# get artist_URL and check if valid and isn't missing at Provider

# find and count empty artist
emptyArt <- which(stri_isempty(artist_vector)) # 51  78 163 211 241 242
nEmptyArt <- sum(stri_isempty(artist_vector), na.rm=TRUE) # six
print(paste(nEmptyArt, '=', emptyArt))

# how many Wikimedia with 0 1 2 hyperlinks?
print(paste('Links 0:', link0, '1:', link1, '2:', link2))

df6$Artist <- artist_vector
df6$ArtistURL <- artistURL_vector
df6$ArtistExtra <- artExtra_vector
df6$Artist2ndURL <- link2nd_vector

#saveRDS(df6, 'data/df6.rds')

# Artist, fix ad hoc in Step 7
#D 247 says Own work, no name (i did find it before)
#D 499 'photo by: '
#D 19 User:
# 560 has 2nd URL in place of Artist name birdphotos.com
# 39,437 includes 2nd URL as well as Artist
# 230 Copyright c 
# 343 &copy; 
# some UPPER CASE 104, 381, 463
# <bdi> 229
# 2, 82/200, bits should be in Extra 

# ArtistURL
# archive panoramio look wrong but they are OK

##### Earlier efforts failed due to varying formats of ArtistHTML #####

# Artist has affiliation, and a 2nd link
# <a href='https://en.wikipedia.org/wiki/User:Khaufle' class='extiw' title='wikipedia:User:Khaufle'>Khaufle</a> at <a href='https://en.wikipedia.org/wiki/' class='extiw' title='wikipedia:'>English Wikipedia</a>

# 2nd link to personal website
# <a href='//commons.wikimedia.org/wiki/User:JJ_Harrison' title='User:JJ Harrison'>JJ Harrison</a> (<a rel='nofollow' class='external free' href='https://www.jjharrison.com.au/'>https://www.jjharrison.com.au/</a>

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