
# select the data and prepare the df necessary for plotting

resorts_raw <- rio::import("data/resorts_clean_and_normalized.RData")
# glimpse(resorts_raw)
# head(resorts_raw, 20)

# Select the X largest resorts by count of trails
n_lg_res = 50
resorts_largest <- resorts_raw %>%
  arrange(-Total_trails) %>%
  head(n_lg_res) %>% # remove acreage and base elevation, as a snowflake has 6 branches
  select(-Skiable_acreage, -Skiable_acreage_norm, -Base_elevation, -Base_elevation_norm) %>%
  select( # renaming to facilitate pivoting (ideally do in "data_cleaning.R"):
    Resort_name, Nearest_city, State_or_province,
    Raw_Peak = Peak_elevation,
    Raw_Drop = Vertical_drop,
    Raw_Trails = Total_trails,
    Raw_Lifts = Total_lifts,
    Raw_Snowfall = Avg_annual_snowfall,
    Raw_Ticket = Adult_weekend_lift_ticket,
    Norm_Peak = Peak_elevation_norm,
    Norm_Drop = Vertical_drop_norm,
    Norm_Trails = Total_trails_norm,
    Norm_Lifts = Total_lifts_norm,
    Norm_Snowfall = Avg_annual_snowfall_norm,
    Norm_Ticket = Adult_weekend_lift_ticket_norm,
  ) %>% 
  select( # we change the order of the vars before pivoting. desired order for the snowflakes
    Resort_name, Nearest_city, State_or_province, 
    Raw_Trails, Raw_Snowfall, Raw_Drop, Raw_Peak, Raw_Ticket, Raw_Lifts,
    Norm_Trails, Norm_Snowfall, Norm_Drop, Norm_Peak, Norm_Ticket, Norm_Lifts) %>%
  mutate( #  order the resorts by number of lifts
    Resort_name = fct_reorder(Resort_name, -Raw_Trails)
  )

# Need to pivot to long format for plotting:
resorts_long <- resorts_largest %>%
  pivot_longer(-c(Resort_name, Nearest_city, State_or_province),
               names_to = c(".value", "Variable"), 
               names_sep = "_")

# add the angles for coord_polar:
Angles = seq(0, 360, by = 60)[1:6] # need to first define the angles for coordpolar (depends on number of vars!)
Angles = rep(Angles, n_lg_res)
Labels = c("Trail Count", "Average Annual Snowfal (in)", "Vertical Drop (ft)", "Peak Elevation (ft)", 
           "Adult weekend lift ticket ($)", "Lift Count")
Labels = rep(Labels, n_lg_res)
Labels_units = c("trails", "in", "ft", "ft", "$", "lifts")
Labels_units = rep(Labels_units, n_lg_res)

resorts_long <- mutate(resorts_long, 
                       Angle = Angles,
                       Label = Labels,
                       Label_Unit = Labels_units)

# save the data, this is the one that will be used for the plots:
save(resorts_long, file = "data/resorts_for_plotting.RData")



