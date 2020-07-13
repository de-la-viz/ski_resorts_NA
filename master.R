
# run this master file to reproduce the viz

library(tidyverse) # wrangling and plotting
library(rio) # to load the data

library(extrafont) # we use Fira Sans
library(svglite) # save ggplots as .svg

library(jsonlite) # for geolocalize_data.R
library(rvest) # for geolocalize_data.R

library(maps) # for plot_map.R
library(mapproj) # for plot_map.R



# load and clean raw data:
source("code/data_cleaning.R") 
# creates "data/resorts_clean_and_normalized.RData"


# select data for plotting:
source("code/data_selection.R") 
# creates "data/resorts_for_plotting.RData"


need_to_localize = FALSE # toggle to re-run the geolocalization
# takes 5min
if (need_to_localize == TRUE) {
  source("code/geolocalize_data.R")
  resorts = rio::import("data/resorts_for_plotting.RData")
  resorts_to_localize <- resorts %>% select(Nearest_city, State_or_province)
  geolocalize_data(resorts = resorts, resorts_to_localize = resorts_to_localize)
  # creates "data/resorts_localized.RData"
}


# load the theme for the plots:
source("code/plotting_theme_def.R")


# plot the legend
source("code/plot_legend.R")
# creates "plots/legend.pdf" and .svg


# plot the map
source("code/plot_map.R")
resorts_localized <- rio::import("data/resorts_localized.RData")
plot_map(resorts_localized = resorts_localized)


# plot the small multiples
source("code/small_multiple.R")


# Then put the map, legend and small multiples together in a single viz. 




