  library(tidyverse) # data cleaning
library(sf) # spatial functions
library(RColorBrewer)
library(here)
library(sp)
library(patchwork)
library(leaflet)
library(htmlwidgets)



#read the shapefile
full_tiles <- read_sf("./data/y-2020-q1-type-fixed.shp")

#read wales shapefiles
msoas <- read_sf("./msoa_wales.shp")

#filter for welsh msoas
msoas <- msoas %>% filter(str_detect(msoa11cd, "^W"))

#map mosa shapes to same projection as the ookla data
msoas <- st_transform(msoas, st_crs(full_tiles))

#this lets us consider msoa by msoa
subset_msoas <- msoas %>% filter(str_detect(msoa11nm, "^Swan"))

#this if filtered on msoa - keeps only square that correspend to chosen msoa area
tiles_in_msoas <- st_join(subset_msoas, full_tiles)
#or this if we want all of wales - keeps squares that correspond to welsh territory
#tiles_in_msoas <- st_join(msoas, full_tiles)

#filter the tiles by the ones that macth the join keys above
filter_tiles <- full_tiles %>% filter(quadkey %in% tiles_in_msoas$quadkey)



#set up color palette
pallog <- colorNumeric(c("darkred","red", "orange", "yellow", "green", "darkgreen", "blue", "darkblue"), log(filter_tiles$avg_d_kbps/1000))
pal <- colorNumeric(c("darkred", "yellow", "green", "green", "darkgreen", "darkgreen", "blue"), filter_tiles$avg_d_kbps/1000)
pal2 <- colorNumeric(c("darkred", "pink"), log(filter_tiles$avg_d_kbps))
#leaflet to plot - zoom in as squares too small for dedfault zoom level
leaflet(filter_tiles) %>% addProviderTiles(providers$CartoDB)  %>%
  addPolygons( stroke=FALSE, fillColor = ~pal(avg_d_kbps/1000),
               fillOpacity = 0.9) %>%
  addPolygons(data = subset_msoas, fillOpacity = 0, color = "black", weight = 0.8) %>%
  addLegend(pal = pal, values = filter_tiles$avg_d_kbps/1000, opacity = 1, title = "Mb/s")

# lets look at lo plot
plot(filter_tiles$avg_d_kbps/1000)

# lets look at log plot
plot(log(filter_tiles$avg_d_kbps/1000))

#density plots for base metric and log conversions
ggplot(filter_tiles, aes(avg_d_kbps/1000))+geom_density()
ggplot(filter_tiles, aes(log(avg_d_kbps/1000)))+geom_density()

#get weighted average at msoa level from squares
sum_stats <- tiles_in_msoas %>%
  st_set_geometry(NULL) %>%
  group_by(msoa11cd, msoa11nm) %>%
  summarise(mean_dl_mbps_wt = weighted.mean(avg_d_kbps, tests, na.rm = TRUE) / 1000,
            mean_ul_mbps_wt = weighted.mean(avg_u_kbps, tests, na.rm = TRUE) / 1000,
            mean_lat_ms_wt = weighted.mean(avg_lat_ms, tests, na.rm = TRUE),
            tests = sum(tests)) %>%
  ungroup()

#join to msoa shapes to plot choropleth
shape_for_sum_stats <- sp::merge(msoas, sum_stats, by.x="msoa11cd", by.y="msoa11cd")


#set up color palette
pal <- colorNumeric(c("red", "yellow", "green"), shape_for_sum_stats$mean_dl_mbps_wt)

#plot log of values
leaflet(shape_for_sum_stats) %>% addProviderTiles(providers$CartoDB)  %>%
  addPolygons( stroke=TRUE, color = "black", weight = 1, fillColor = ~pal(mean_dl_mbps_wt),
               fillOpacity = 0.9) %>%
addLegend(pal = pal, values = filter_tiles$avg_d_kbps/1000, opacity = 1, title = "Mb/s") %>%
  addProviderTiles(providers$CartoDB)
