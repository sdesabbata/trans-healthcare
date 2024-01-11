# This script downloads 
# the 2021 Census bulk data on Sexual Orientation and Gender Identity from NomisWeb 
# https://www.nomisweb.co.uk/sources/census_2021_bulk
#
# Released under the Open Government Licence v3.0 
# https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
# 
# Author: Stef De Sabbata
# Date: 07 January 2024


# Libraries ---------------------------------------------------------------

library(tidyverse)



# Data download -----------------------------------------------------------

cat("Retrieving data\n")


urls <- c(
  # TS079	Sexual orientation (detailed)
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts079.zip",
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts079-extra.zip",
  # TS070	Gender identity (detailed)
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts070.zip",
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts070-extra.zip",
  # TS077	Sexual orientation
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts077.zip",
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts077-extra.zip",
  # TS078	Gender identity
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts078.zip",
  "https://www.nomisweb.co.uk/output/census/2021/census2021-ts078-extra.zip"
)

for (this_url in urls) {
  
  census_file <-
    this_url %>% 
    str_split("/") %>% 
    flatten() %>% 
    as_vector() %>% 
    last() %>% 
    paste0("storage/", .)
  
  if (!file.exists(file.path(census_file))) {
    
    cat(census_file)
    cat("\n")
    
    # Download file
    download.file(
      url = this_url,
      destfile = census_file
    )
    
    # Extract zip
    unzip(
      census_file, 
      exdir = str_sub(census_file, end = -5)
    )
    
  }
}