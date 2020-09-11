
# draw small multiple and save it as .eps that can then be finalized with Inkscape:
# needs: tidyverse, rio, extrafont, svglite, and source("code/plotting_theme_def.R")

# FINALIZING DATA

resorts_raw <- rio::import("data/resorts_for_plotting.RData")

# add new variables to help plotting snowflake:
arrow_width = 5 # angle x
arrow_heigth = 0.1 # y
space_btw_arrows = 0.12 
size = 0.6 # weight of branches in geom_segment()

resorts <- resorts_raw %>% 
  mutate(
    arr_out = Norm, # y-pos of end of arrow
    arr_mid = ifelse(Norm - space_btw_arrows > 0.2, Norm - space_btw_arrows, NA), # don't draw arrow if Norm is too low (<= 0.2)
    arr_in = ifelse(Norm - 2*space_btw_arrows > 0.2, Norm - 2*space_btw_arrows, NA), # don't draw arrow if Norm is too low (<= 0.2)
    arr_left = ifelse(Angle - arrow_width >= 0, Angle - arrow_width, 360 - arrow_width), # x value of arrow's tip, take  care of negative Angles
    arr_right = Angle + arrow_width, # x value of arrow's tip
    xend_angle = ifelse(Angle != 0, Angle, 360), # help linking 0 and 360
    y_label = case_when( # y-position of labels for geom_text()
      Angle == 0 ~ Norm,
      Angle == 60 ~ Norm,
      Angle == 120 ~ Norm,
      Angle == 180 ~ Norm,
      Angle == 240 ~ Norm,
      Angle == 300 ~ Norm
    ),
    Annotation = paste(Raw, Label_Unit)
  )



# a circle at the center of the snowflake:
flake_poly <- tibble(polygon_x = seq(0, 360, by = 1), polygon_y = rep(0,361))

# plot small multiples
sm <- ggplot(resorts, aes(x = Angle, y = Norm)) +
  coord_polar() +
  scale_x_continuous(limits = c(0, 360)) +
  scale_y_continuous(limits = c(-0.1, 1)) +
  # a circle at the center:
  geom_polygon(data = flake_poly, aes(polygon_x, polygon_y), fill = light, size = size) +
  # the data, normalized var = length of segment:
  geom_segment(aes(y = 0, yend = Norm, x = Angle, xend = Angle), 
               lineend = "round", size = size, color = light) +
  # outer arrows:
  geom_segment(aes(y = arr_out, yend = arr_out - arrow_heigth, x = arr_left, xend = xend_angle), 
               size = size, color = light, lineend = "round") +
  geom_segment(aes(y = arr_out, yend = arr_out - arrow_heigth, x = arr_right, xend = Angle),
               size = size, color = light, lineend = "round") + 
  # mid arrows:
  geom_segment(aes(y = arr_mid, yend = arr_mid - arrow_heigth, x = arr_left, xend = xend_angle),
               size = size, color = light, lineend = "round") +
  geom_segment(aes(y = arr_mid, yend = arr_mid - arrow_heigth, x = arr_right, xend = Angle),
               size = size, color = light, lineend = "round") + 
  # inner arrows:
  geom_segment(aes(y = arr_in, yend = arr_in - arrow_heigth, x = arr_left, xend = xend_angle),
               size = size, color = light, lineend = "round") +
  geom_segment(aes(y = arr_in, yend = arr_in - arrow_heigth, x = arr_right, xend = Angle),
               size = size, color = light, lineend = "round") + 
  my_theme() +
  # adding the labels (the names of the vars are in the legend. Here we plot only values)
  geom_text(aes(label = Annotation, y = Norm), color = light, size = 1,
            family = "Fira Sans",
            vjust = rep(c(-2, -1, +3, +3, +3, -2), 50), 
            hjust = rep(c(0.4, -0.3, 0, 0.3, 1, 1.2), 50)) +
  # facetting by resort:
  facet_wrap(~Resort_name, ncol = 10)


# Save as PDF A4, landscape
ggsave(filename = "subplots/small_multiple.pdf", 
       plot = sm, 
       device = cairo_pdf,
       width = 297, 
       height = 210, 
       units = "mm")
# embed the output font in the PDF:
extrafont::embed_fonts("subplots/small_multiple.pdf")

ggsave(filename = "subplots/small_multiple.svg", 
       plot = sm, 
       width = 297, 
       height = 210, 
       units = "mm")



# ------------------------------- trying with the quantiles as arrows --------

# THIS IS NOT WORKING SO WELL. IT IS LESS NICE.
# Because we already filtered for the largest resorts, so the quantile of the current data 
# are really close to each others. On the other hand, if we were to use the quantiles of the full dataset
# (all 300 and more resorts), they would not be much informative neither because those resorts are 
# not visualized.
# (the idea was that with quantiles, we might be better able to compare the resorts)

# # we add the quantiles, to plot the "arrows" (lateral branches)
# resorts <- resorts %>% 
#   group_by(Variable) %>%
#   mutate(
#     lower_quantile = quantile(Norm)[2],
#     mid_quantile = quantile(Norm)[3],
#     larger_quantile = quantile(Norm)[4],
#   )
# 
# # plot small multiples
# sm <- ggplot(resorts, aes(x = Angle, y = Norm)) +
#   coord_polar() +
#   scale_x_continuous(limits = c(0, 360)) +
#   scale_y_continuous(limits = c(-0.1, 1)) +
#   # a circle at the center:
#   geom_polygon(data = flake_poly, aes(polygon_x, polygon_y), fill = light, size = size) +
#   # the data, normalized var = length of segment:
#   geom_segment(aes(y = 0, yend = Norm, x = Angle, xend = Angle), 
#                lineend = "round", size = size, color = light) +
#   # outer arrows:
#   geom_segment(aes(y = lower_quantile, yend = lower_quantile - arrow_heigth, x = arr_left, xend = xend_angle), 
#                size = size, color = light, lineend = "round") +
#   geom_segment(aes(y = lower_quantile, yend = lower_quantile - arrow_heigth, x = arr_right, xend = Angle),
#                size = size, color = light, lineend = "round") + 
#   # mid arrows:
#   geom_segment(aes(y = mid_quantile, yend = mid_quantile - arrow_heigth, x = arr_left, xend = xend_angle),
#                size = size, color = light, lineend = "round") +
#   geom_segment(aes(y = mid_quantile, yend = mid_quantile - arrow_heigth, x = arr_right, xend = Angle),
#                size = size, color = light, lineend = "round") + 
#   # inner arrows:
#   geom_segment(aes(y = larger_quantile, yend = larger_quantile - arrow_heigth, x = arr_left, xend = xend_angle),
#                size = size, color = light, lineend = "round") +
#   geom_segment(aes(y = larger_quantile, yend = larger_quantile - arrow_heigth, x = arr_right, xend = Angle),
#                size = size, color = light, lineend = "round") + 
#   my_theme() +
#   # adding the labels (the names of the vars are in the legend. Here we plot only values)
#   geom_text(aes(label = Annotation, y = Norm), color = light, size = 1,
#             family = "Fira Sans",
#             vjust = rep(c(-2, -1, +3, +3, +3, -2), 50), 
#             hjust = rep(c(0.4, -0.3, 0, 0.3, 1, 1.2), 50)) +
#   # facetting by resort:
#   facet_wrap(~Resort_name, ncol = 10) +
#   labs(
#     title = "50 of the Largest North American Ski Resorts"
#   )













