# run this main file to reproduce the viz

library(tidyverse) # wrangling and plotting
library(rio) # to load the data

library(extrafont) # we use Fira Sans
library(svglite) # save ggplots as .svg

library(jsonlite) # for geolocalize_data.R
library(rvest) # for geolocalize_data.R

library(maps) # for plot_map.R
library(mapproj) # for plot_map.R

# loads the separate plots for the small mupltiple (sm), the legend,
# and the map. The title and explanations are drawn here.

library(cowplot)
library(ggtext) # box of wrapped text
library(glue) # only used for name of saved image


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

# plot the map
source("code/plot_map.R")
resorts_localized <- rio::import("data/resorts_localized.RData")
p_map <- plot_map(resorts_localized = resorts_localized)

# plot the small multiples
source("code/small_multiple.R")


# source("code/plot_legend.R")
# source("code/plot_map.r")
# source("code/small_multiple.R")
# source("code/plotting_theme_def.R")

# --- everything in a single viz with cowplot ---

small_multiple <- sm + 
  theme(
    plot.margin = margin(t = 60, r = 35, b = 15, l = 35, unit = "mm"),
    plot.background = element_rect(color = dark, fill = dark)
    )

ggdraw(small_multiple) +
  draw_plot(p_legend, 0.08, 0.735, 0.23, 0.23) +
  draw_plot(p_map, 0.7, 0.76, 0.19, 0.19) + 
  # inspiration from Cédric Scherrer (https://github.com/Z3tt/TidyTuesday/blob/master/R/2020_28_CoffeeRatings.Rmd):
  geom_textbox(
    data = tibble(
      x = 0.32,
      y = 0.76,
      label = "<span style='font-size:9.8pt;'>Fifty snowflakes for fifty of the largest North American ski resorts.<br>How do they compare?</span><br><br>Nucleating around a dust particle, each snowflake has six branches. Each branch grows independently and its length encodes one of the key figures describing a ski resort: number of trails, average annual snowfall, vertical drop, peak elevation, adult weekend lift ticket, and number of lifts. The number of trails is used to select, and sort, the fifty largest ski resorts.<br><br><i>Design: François Delavy<br>Data: wikipedia.org/wiki/Comparison_of_North_American_ski_resorts (CC BY-SA 3.0)</i>"
    ),
    aes(
      x = x, y = y, label = label
    ),
    inherit.aes = F,
    family = "Fira Sans",
    color = light,
    size = 2.2,
    lineheight = 1.7,
    width = unit(108, "mm"),
    fill = NA,
    box.colour = NA,
    hjust = 0,
    vjust = 0
  )

# saving:
path <- "poster/ski_resort_poster"

# Save as PDF A4, landscape:
ggsave(filename = glue::glue("{path}.pdf"), 
       device = cairo_pdf,
       width = 297, 
       height = 210, 
       units = "mm")
# embed the output font in the PDF:
extrafont::embed_fonts(glue::glue("{path}.pdf"))

# Save as SVG:
ggsave(filename = glue::glue("{path}.svg"), 
       width = 297,
       height = 210, 
       units = "mm")

ggsave(filename = glue::glue("{path}.png"), 
       width = 297,
       height = 210, 
       units = "mm",
       dpi = 400)

