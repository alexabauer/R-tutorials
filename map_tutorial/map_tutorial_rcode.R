#### Document setup ####

# wrangling packages
library(here) # here makes a project transportable
library(janitor) # clean_names
library(readxl) # read excel files
#library(tidyverse) # includes the packages ggplot2( for data vis), dplyr (for manipulation), tidyr (for tidying), tibble, etc.

# graphing packages
library(ggplot2)
library(ggmap) # pulls map from source
library(patchwork) # for structuring multiplot graphs
library(scico)
library(extrafont) # for using custom fonts installed on your device

# font_import() # only necessary if you haven't imported your device fonts before!
loadfonts() # only necessary if using custom fonts


# use here from the here package
here <- here::here
# use clean_names from the janitor package
clean_names <- janitor::clean_names

# Define project variables

data_folder <- "Data"
output_folder <- "Output"

#### Read in data ####

file_name <- "SS-InvCommunitites_Metrics-wide.xlsx"

file_path <- here(data_folder, file_name) # paste together parts of the address
my_file <- read_excel(file_path)

SS_ICM <- clean_names(my_file) # ICM: invertebrate community metrics

head(SS_ICM)

#### Project data onto maps ####

## Make map ##

# > min(SS_ICM$longitude)
# [1] -89.9543
# > max(SS_ICM$longitude)
# [1] -87.77006
# > min(SS_ICM$latitude)
# [1] 30.24828
# > max(SS_ICM$latitude) 
# [1] 31.06512

# Define coordinate range
myLocation <- c(-90.4, 29.75, -87.4, 31.5)

# Pull map tiles - Here: osm based stamen map
# Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under ODbL
myMap <- get_stamenmap(bbox = myLocation,
                       maptype = "toner-background", # toner background: bw, no labels
                       zoom = 8)

# black background is too harsh - can't change color in map projection  
# change opacity of base map: make attributes new dataset, change transparency, map over white background in graph
mapatt <- attributes(myMap)
map_transparent <- matrix(adjustcolor(myMap, alpha.f = 0.3), nrow = nrow(myMap))
attributes(map_transparent) <- mapatt

## maps for relevant diversity measures: richness, evenness, shannon, and inverse simpson

# easier way: facet_grid(metric ~ date), BUT: cant define different color scales for each measure
# Instead, we'll make individual plots and combine them in one graph at the end

# optional: change font to Arial narrow
# note: if not used then need to remove from theme_bw()

# 1st plot: Richness
p1 <- ggmap(map_transparent) +
  geom_point(aes(x = longitude, y = latitude, fill = richness),
             data = SS_ICM,
             color = "black",
             pch = 21,
             size = 4) +
  facet_wrap(~ date) +
  scale_fill_scico(palette="bamako", direction =-1, end = 0.95, name = "Richness") +
  theme_bw(base_family = "Arial Narrow") +
  theme(panel.grid = element_line("#cccccc"),
        panel.background = element_rect(fill = 'white')) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  xlab("") +
  ylab("") +
  labs(subtitle="Richness")

# 2nd plot: Eveness
p2 <- ggmap(map_transparent) +
  geom_point(aes(x = longitude, y = latitude, fill = evenness),
             data = SS_ICM,
             color = "black",
             pch = 21,
             size = 4) +
  facet_wrap(~ date) +
  scale_fill_scico(palette="turku", end = 0.9, name = "Evenness") +
  theme_bw(base_family = "Arial Narrow") +
  theme(panel.grid = element_line("#cccccc"),
        panel.background = element_rect(fill = 'white')) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  theme(strip.text.x = element_blank()) +
  xlab("") +
  ylab("") +
  labs(subtitle="Evenness")

# 3rd plot: Shannon
p3 <- ggmap(map_transparent) +
  geom_point(aes(x = longitude, y = latitude, fill = shannon),
             data = SS_ICM,
             color = "black",
             pch = 21,
             size = 4) +
  facet_wrap(~ date) +
  scale_fill_scico(palette="devon", end = 0.8, name = "Shannon") +
  theme_bw(base_family = "Arial Narrow") +
  theme(panel.grid = element_line("#cccccc"),
        panel.background = element_rect(fill = 'white')) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  theme(strip.text.x = element_blank()) +
  xlab("") +
  ylab("") +
  labs(subtitle="Shannon")

# 4th plot: invSimpson
p4 <- ggmap(map_transparent) +
  geom_point(aes(x = longitude, y = latitude, fill = inv_simpson),
             data = SS_ICM,
             color = "black",
             pch = 21,
             size = 4) +
  facet_wrap(~ date) +
  scale_fill_scico(palette="lajolla", direction =-1, begin = 0.2, name = "invSimps") +
  theme_bw(base_family = "Arial Narrow") +
  theme(panel.grid = element_line("#cccccc"),
        panel.background = element_rect(fill = 'white')) +
  theme(strip.text.x = element_blank()) +
  labs(x="Longitude", y="",
       subtitle = "Inverse Simpson") +
  ylab("") 

# combine plots into one chart
div_metrics <- (p1 / p2 / p3 / p4) #+  plot_layout(guides = 'collect') #+ plot_annotation(tag_levels = 'A')

figure <- div_metrics +
  plot_annotation(title = 'Macroinvertebrate Community Metrics',
                  theme = theme(plot.title = element_text(size = 18,
                                                          face = "bold",
                                                          family = "Arial Narrow"))
                  )
figure

# saving plot for print publication

output_name <- "SS_ICM_maps.png"

output_plot_path <- here(output_folder, "Plots")

ggsave(filename = output_name,
       path = output_plot_path,
       plot=figure,
       device="png",
       height=25.5, width=18.5, units="cm",
       dpi = 500) 