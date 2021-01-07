library(tidyverse) # data cleaning
library(sf) # spatial functions
library(here)
library(sp)


#function for getting data.
get_data <- function(type ="fixed", year = "2020", quarter = "1"){
  temp <- tempfile()
  temp2 <- tempfile()


  if(quarter==1){
    filedate <- paste0(year, "-01-01")
  }else if(quarter==2){
    filedate <- paste0(year, "-04-01")
  }else if(quarter==3){
    filedate <- paste0(year, "-07-01")
  }else if(quarter==4){
    filedate <- paste0(year, "-10-01")
  }else{
    print("Error - filedate not set")
  }


  path = paste0("https://ookla-open-data.s3-us-west-2.amazonaws.com/shapefiles/performance/type%3D", type, "/year%3D", year, "/quarter%3D", quarter, "/", filedate, "_performance_", type, "_tiles.zip")

  ## download the zip folder from s3 and save to temp
  download.file(path,temp)

  unzip(zipfile = temp, exdir = temp2)
  ## finds the filepath of the shapefile (.shp) file in the temp2 unzip folder
  ## the $ at the end of ".shp$" ensures you are not also finding files such as .shp.xml
  shp <- read_sf(list.files(temp2, pattern = ".shp$",full.names=TRUE))

  write_sf(shp, paste0("./data/y-", year, "-q", quarter, "-type-", type, ".shp"))

}
