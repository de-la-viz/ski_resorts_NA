
# plot the legend.

# needs: tidyverse, extrafont, svglite, and source("code/plotting_theme_def.R")


# need to first define the angles for coordpolar (depends on number of vars!)
my_angles = seq(0, 360, by = 60)[1:6] 

# fake data:
names <- rep("Resort Name", 6)
variables <- c("Total_trails_norm", "Avg_annual_snowfall_norm", "Vertical_drop_norm", "Peak_elevation_norm", 
               "Adult_weekend_lift_ticket_norm", "Total_lifts_norm")
values_norm <- c(0.8, 0.65, 0.7, 0.9, 0.85, 0.65)
values_raw <- c("Trail Count", "Average Annual\nSnowfall (in)", "Vertical Drop (ft)", "Peak Elevation (ft)", 
                "Adult weekend\nlift ticket ($)", "Lift Count")
legend_df <- tibble(Resort_name = names, variable = variables, value = values_norm, 
                    angle = my_angles, labels = values_raw)


# additional variables to draw the snowflakes:
arrow_width = 5 # angle x
arrow_heigth = 0.1 # y
space_btw_arrows = 0.12
size = 1

# need to compute arrows values:
legend_df <- legend_df %>% 
  mutate(
    arr_out = value,
    arr_mid = ifelse(value - space_btw_arrows > 0.2, value - space_btw_arrows, NA), # don't draw arrow if value is too low (<= 0.2)
    arr_in = ifelse(value - 2*space_btw_arrows > 0.2, value - 2*space_btw_arrows, NA), # don't draw arrow if value is too low (<= 0.2)
    arr_left = ifelse(angle - arrow_width >= 0, angle - arrow_width, 360 - arrow_width), # take  care of negative angles
    arr_right = angle + arrow_width,
    xend_angle = ifelse(angle != 0, angle, 360),
    y_label = case_when(
      angle == 0 ~ value,
      angle == 60 ~ value,
      angle == 120 ~ value,
      angle == 180 ~ value,
      angle == 240 ~ value,
      angle == 300 ~ value
    )
  ) 

polygon_x <- seq(0, 360, by = 1)
polygon_y <- rep(0,361)
flake_poly <- tibble(polygon_x, polygon_y)

p_legend <- ggplot(legend_df, aes(x = angle, y = value)) +
  geom_polygon(data = flake_poly, aes(polygon_x, polygon_y), fill = "white", size = size) +
  geom_segment(aes(y = 0, yend = value, x = angle, xend = angle), lineend = "round", size = size, color = "white") +
  coord_polar() +
  scale_x_continuous(limits = c(0, 360)) +
  scale_y_continuous(limits = c(-0.1, 1)) +
  # outer arrows:
  geom_segment(aes(y = arr_out, yend = arr_out - arrow_heigth, x = arr_left, xend = xend_angle), 
               size = size, color = "white", lineend = "round") +
  geom_segment(aes(y = arr_out, yend = arr_out - arrow_heigth, x = arr_right, xend = angle),
               size = size, color = "white", lineend = "round") + 
  # mid arrows:
  geom_segment(aes(y = arr_mid, yend = arr_mid - arrow_heigth, x = arr_left, xend = xend_angle),
               size = size, color = "white", lineend = "round") +
  geom_segment(aes(y = arr_mid, yend = arr_mid - arrow_heigth, x = arr_right, xend = angle),
               size = size, color = "white", lineend = "round") + 
  # inner arrows:
  geom_segment(aes(y = arr_in, yend = arr_in - arrow_heigth, x = arr_left, xend = xend_angle),
               size = size, color = "white", lineend = "round") +
  geom_segment(aes(y = arr_in, yend = arr_in - arrow_heigth, x = arr_right, xend = angle),
               size = size, color = "white", lineend = "round") + 
  my_theme() +
  geom_text(aes(label = labels, y = value), size = 2, color = light,
               vjust = c(-2, -0.5, +3, +3, +1.8, -2), 
               hjust = c(0.5, 0, 0.2, 0.4, 0.5, 0.8))


# Save as PDF:
ggsave(filename = "plots/legend.pdf", 
       plot = p_legend, 
       device = cairo_pdf,
       width = 59.4, # = 297mm/5 (one fifth of the A4 landscape width)
       height = 59.4, 
       units = "mm")
# embed the output font in the PDF:
extrafont::embed_fonts("plots/legend.pdf")

# Save as SVG:
ggsave(filename = "plots/legend.svg", 
       plot = p_legend, 
       width = 59.4, # = 297mm/5 (one fifth of the A4 landscape width)
       height = 59.4, 
       units = "mm")




