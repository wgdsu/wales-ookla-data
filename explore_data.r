library(tidyverse) 
library(sf)
library(RColorBrewer)
library(leaflet)

#read wales msoa shapefiles
msoas <- read_sf("./wales_msoa.shp")#read wales shapefiles

#read in ookla tiles for Wales
tiles <- read_sf("./data/y-2020-q1-type-fixed.shp")

  
#map msoa shapes to same projection as the ookla data
msoas <- st_transform(msoas, st_crs(tiles))
  
#this lets us filter data by area - this example filters for Pembrokeshire
subset_msoas <- msoas %>% filter(str_detect(msoa11_nam, "^Pem"))

#this if filtered on msoa - keeps only square that corresp0nd to chosen msoa area
tiles_in_msoas <- st_join(subset_msoas, tiles)

#filter the tiles by the ones that match the join keys above
filter_tiles <- tiles %>% filter(quadkey %in% tiles_in_msoas$quadkey)

#set up a colour pallette
pal <- colorNumeric("RdYlBu", filter_tiles$avg_d_kbps/1000)


#plot the tiles and msoa boundaries
leaflet(filter_tiles) %>% addProviderTiles(providers$CartoDB)  %>%
  addPolygons( stroke=FALSE, fillColor = ~pal(avg_d_kbps/1000),
               fillOpacity = 0.9) %>%
  addPolygons(data = subset_msoas, fillOpacity = 0, color = "black", weight = 0.8) %>%
  addLegend(pal = pal, values = filter_tiles$avg_d_kbps/1000, opacity = 0.8, title = "Mb/s")


