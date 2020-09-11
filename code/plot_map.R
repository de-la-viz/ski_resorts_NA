
# Goal: plot the localization of the resorts on a map

# needs: library(maps), library(mapproj), library(svglite), and ggplot2
# and source("code/plotting_theme_def.R")


plot_map <- function(resorts_localized){
  
  geo_data <- ggplot2::map_data("world", regions = c("usa", "canada", "mexico"))
  
  p_map <- ggplot() + 
    geom_polygon(data = geo_data, mapping = aes(x = long, y = lat, group = group ),
                 color = light, fill = dark, size = 0.2) +
    geom_point(data = resorts_localized, aes(x = longitude, y = latitude), 
               pch = 21, fill = light, color = light, size = 1) +
    coord_map(projection = "albers", lat0 = 35, lat1 = 55, xlim = c(220, 300)) + 
    theme_void() +
    theme(
      plot.background = element_rect(fill = dark, 
                                     color = dark)
    )
  
  # Save as PDF:
  ggsave(filename = "subplots/map.pdf", 
         plot = p_map, 
         device = cairo_pdf,
         width = 59.4, # = 297mm/5 (one fifth of the A4 landscape width)
         height = 59.4, 
         units = "mm")
  # Save as SVG:
  ggsave(filename = "subplots/map.svg", 
         plot = p_map, 
         width = 59.4, # = 297mm/5 (one fifth of the A4 landscape width)
         height = 59.4, 
         units = "mm")
  
  return(p_map)
}
