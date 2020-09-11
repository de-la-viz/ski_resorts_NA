
# PLOTTING VARIABLES AND THEME:
# needs extrafont package

# those var are loaded then in the scripts were we plot
# but defined once here.

light <- "white" # color of snowflakes and text
dark <- "#383e42" # color of background
my_font <- "Fira Sans" # warning: the font of the annotations is handled separatly in geom_text()

# Define the theme for the plots (background and text)
my_theme <- function() {
  theme_minimal() +
    theme(
      text = element_text(size = 4, color = light, family = my_font),
      plot.title = element_text(size = 10, color = light, family = my_font), 
      strip.text.x = element_text(size = 4, color = light, family = my_font), # titles for facet_wrap
      plot.background = element_rect(fill = dark, 
                                     color = dark),
      legend.position = "none",
      panel.grid = element_blank(),
      axis.text = element_blank(),
      axis.title = element_blank()
    )
}