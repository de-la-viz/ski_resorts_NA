
geolocalize_data <- function(resorts, resorts_to_localize){
  
  geocode <- function(city, state){
    
    # needs: library(jsonlite) and library(rvest)
    
    # NOMINATIM SEARCH API URL
    src_url <- "https://nominatim.openstreetmap.org/search?q="
    
    # CREATE A FULL ADDRESS
    addr <- paste(city, state, sep = "%2C")
    
    # CREATE A SEARCH URL BASED ON NOMINATIM API TO RETURN GEOJSON
    requests <- paste0(src_url, addr, "&format=geojson")
    # print(requests)
    
    # ITERATE OVER THE URLS AND MAKE REQUEST TO THE SEARCH API
    for (i in 1:length(requests)) {
      
      # QUERY THE API TRANSFORM RESPONSE FROM JSON TO R LIST
      response <- read_html(requests[i]) %>%
        html_node("p") %>%
        html_text() %>%
        fromJSON()
      
      # FROM THE RESPONSE EXTRACT LATITUDE AND LONGITUDE COORDINATES
      lon <- response$features$geometry$coordinates[[1]][1]
      lat <- response$features$geometry$coordinates[[1]][2]
      # print(paste(requests[i], lon, lat)) # find which one can't be localized
      
      # CREATE A COORDINATES DATAFRAME
      if (i == 1) {
        loc <- tibble(addr = addr[i],
                      Nearest_city = city[i],
                      State_or_province = state[i],
                      latitude = lat, longitude = lon)
      }else{
        df <- tibble(addr = addr[i],
                     Nearest_city = city[i],
                     State_or_province = state[i],
                     latitude = lat, longitude = lon)
        loc <- bind_rows(loc, df)
      }
    }
    return(loc)
    
    # to test that it works: 
    # geocode("Leadville", "Colorado")
    # geocode("Bellefontaine", "Ohio")
    # geocode(c("Bromont", "Leadville", "Waterbury"), c("Quebec", "Colorado", "Vermont"))
    
  }
  
  # could invest some time making this more efficient, as we geolocalize 300 instead or 50 resorts...
  localized_resorts <- geocode(resorts_to_localize$Nearest_city, resorts_to_localize$State_or_province)
  
  # we merge it back to our resorts:
  resorts_localized <- cbind(resorts, select(localized_resorts, -Nearest_city, -State_or_province))
  save(resorts_localized, file = "data/resorts_localized.RData")
  
}
