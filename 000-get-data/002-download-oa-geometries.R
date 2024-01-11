# This script downloads 
#
# Middle Layer Super Output Areas (2021) Boundaries EW BGC
# https://geoportal.statistics.gov.uk/datasets/ons::middle-layer-super-output-areas-2021-boundaries-ew-bgc/about
#
# Contains both Ordnance Survey and ONS Intellectual Property Rights.
#
# Published Date: July 11, 2023
# Source: Office for National Statistics licensed under the Open Government Licence v.3.0
# https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
# Contains OS data © Crown copyright and database right 2022
#
#
# >>> REQUIRES MANUAL DOWNLOAD OF: <<<
#
#
# save in /storage
#
#
# OAs to LSOAs to MSOAs to LEP to LAD (May 2022) Lookup in England
# https://geoportal.statistics.gov.uk/datasets/ons::oas-to-lsoas-to-msoas-to-lep-to-lad-may-2022-lookup-in-england/about
# File created: Jun 1, 2023, 17:04
# File size: 1.4 MB
# 
# Contains both Ordnance Survey and ONS Intellectual Property Rights.
#
# Published Date: August 24, 2022
# Source: Office for National Statistics licensed under the Open Government Licence v.3.0
# https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
# Contains OS data © Crown copyright and database right 2022
#
#
# Author: Stefano De Sabbata
# Date: 07 January 2024


# Libraries ---------------------------------------------------------------

library(tidyverse)
library(magrittr)
library(sf)
library(jsonlite)



# Data download -----------------------------------------------------------

cat("Retrieving data\n")

lookup_Leics_MSOA_2021 <- 
  read_csv("storage/OAs_to_LSOAs_to_MSOAs_to_LEP_to_LAD_(May_2022)_Lookup_in_England.csv") %>% 
  filter(LEP21NM1 == "Leicester and Leicestershire") %>% 
  distinct(MSOA21CD, MSOA21NM, LEP21CD1, LEP21NM1, LEP21CD2, LEP21NM2, LAD22CD, LAD22NM)

for (i in 0:(
    lookup_Leics_MSOA_2021 %>% 
    nrow() %>% 
    divide_by(50) %>% 
    floor()
)) {
  
  tmp_OAs <-
    lookup_Leics_MSOA_2021 %>% 
    slice_tail(
      n = 
        lookup_Leics_MSOA_2021 %>% 
        nrow() %>% 
        subtract(i * 50)
    ) %>% 
    slice_head(n = 50) %>% 
    pull(MSOA21CD) %>% 
    paste0(
      "MSOA21CD%20%3D%20'",
      .,
      "'%20OR%20",
      collapse = ""
    ) %>% 
    str_sub(end = -6) %>% 
    paste0(
      "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/MSOA_2021_EW_BGC_V2/FeatureServer/0/query?where=%20(",
      .,
      ")%20&outFields=*&outSR=4326&f=json"
    ) %>% 
    st_read()
  
  if (i == 0){
    geom_Leicester_OAs <- tmp_OAs
  } else {
    geom_Leicester_OAs %<>%
      bind_rows(tmp_OAs)
  }
  
}

# Check
lookup_Leics_MSOA_2021 %>% 
  select(MSOA21CD) %>% 
  anti_join(
    geom_Leicester_OAs %>% 
      st_drop_geometry() %>% 
      select(MSOA21CD)
  )

# Write
geom_Leicester_OAs %>% 
  left_join(lookup_Leics_MSOA_2021) %>% 
  st_write("storage/Leicestershire_2021_MSOAs.geojson")
