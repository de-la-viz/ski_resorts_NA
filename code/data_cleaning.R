
# this script loads the wikipedia data as .csv and output a clean R file
# data source: https://en.wikipedia.org/wiki/Comparison_of_North_American_ski_resorts
# cleaning already done manually in Excel/Numbers: remove "," in columns and remove "$" sign in price col,
# and changed column names.


resorts_raw <- rio::import("data/ski_resorts.csv")
glimpse(resorts_raw)
head(resorts_raw, 20)

# To do:
# - all number columns as numeric instead of char. Need to take care of missing values
# - some ski resorts have a link "[1]" -> remove.
#     -> probably write a function to remove "[...]" -> no, can use stringr::str_replace_all

remove_wiki_links <- function(string){
  # remove the wiki links that are in "[xxx]" format
  # then trim to handle the cases where there is a whitespave btw value and []
  return(
    str_replace(string, pattern = "\\[.*\\]", replacement = "") %>%
      str_trim(side = "right")
      )
}

# cleaning:
resorts <- resorts_raw %>%
  mutate(
    Resort_name = remove_wiki_links(Resort_name),
    Nearest_city = remove_wiki_links(Nearest_city),
    Peak_elevation = as.numeric(remove_wiki_links(Peak_elevation)),
    Skiable_acreage = as.numeric(remove_wiki_links(Skiable_acreage)),
    Avg_annual_snowfall = as.numeric(remove_wiki_links(Avg_annual_snowfall)),
    Adult_weekend_lift_ticket = case_when(
      Adult_weekend_lift_ticket == "Private Club" ~ "",
      Adult_weekend_lift_ticket == "Temporarily Closed" ~ "",
      Adult_weekend_lift_ticket == "Closed Temporarily" ~ "",
      Adult_weekend_lift_ticket == "25/season" ~ "25",
      Adult_weekend_lift_ticket == "Free" ~ "0",
      TRUE ~ Adult_weekend_lift_ticket
    ),
    Adult_weekend_lift_ticket = as.numeric(remove_wiki_links(Adult_weekend_lift_ticket)),
  ) %>%
  select(-Date_statistics_updated) # it is mostly a recent date, so we are good.

# some specific cleaning:
resorts[resorts == "Big Snow Resort (includes Blackjack and Indianhead Mountain)"] <- "Big Snow Resort"
resorts[resorts == "Bellafontaine"] <- "Bellefontaine" # correct name (needed for geocoding)

# # save data:
# save(resorts, file = "data/resorts_clean.RData")

# a df with complete cases only:
resorts_complete <- resorts %>% drop_na()
# save(resorts_complete, file = "data/resorts_clean_complete_cases.RData")

# we normalize the data, for a small multiple plot comparing all data:
range01 <- function(x){
  # range btw a and b, instead of standardization
  # i.e. minmax scaling.
  # we do not use 0 and 1, to have nicer snowflakes
  b = 1
  a = 0.2
  ((b - a) * (x - min(x)) / (max(x) - min(x))) + a
}

resorts_complete_normalized <- resorts_complete %>%
  mutate_at(c("Peak_elevation", "Base_elevation", "Base_elevation", "Vertical_drop", "Skiable_acreage", 
              "Total_trails", "Total_lifts", "Avg_annual_snowfall", "Adult_weekend_lift_ticket"),
            ~range01(.))
# save(resorts_complete_normalized, file = "data/resorts_clean_complete_cases-normalized.RData")


# we create one data frame with the normalized and raw data to have all the information:
resorts_complete_normalized <- resorts_complete_normalized %>%
  rename_all(., function(x) paste0(x,"_norm"))
resorts_for_small_multiple <- bind_cols(resorts_complete, resorts_complete_normalized) %>%
  select(-Resort_name_norm, -Nearest_city_norm, -State_or_province_norm)
save(resorts_for_small_multiple, file = "data/resorts_clean_and_normalized.RData")




  
  
  
