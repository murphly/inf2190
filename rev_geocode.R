#REMEMBER THE View() FUNCTION!!!! IT WAS --SO-- USEFUL FOR LOOKING AT THE GOOGLEWAY RESULTS
## Script Start
#load required libraries 
library(googleway)
library(tidyverse)
library(dplyr)
dplyr::filter
#Set google maps API key
key <- "AIzaSyBrw-hNJZmlwNUPiz9ymXI9QxHqtR1zywU"

## Read in the Councillor Data, clean out advance votes, mail balots, and total; separate out the location data
fileloc <- '~/Downloads/2017councillor.csv' # Put the location of your file data here
councillor <- read.csv(fileloc, sep=',')
councillor <- dplyr::filter(councillor, Voting.Place.ID != 200 & Voting.Place.ID != 300 & Voting.Place != "Total")
votingplace <- data.frame(councillor['Voting.Place.ID'],councillor['Voting.Place'])

#initiate a blank dataframe
counc.data <- data.frame()

# loop over every row in the votingplace data, do a search thru the google maps API, parse the results and put it into
# the counc.data dataframe
for(j in 1:nrow(votingplace)){
  loc <- google_geocode(address=trimws(paste(votingplace[j,2], ", Vancouver, BC")), key = key)
  lat <- loc[["results"]][["geometry"]][["location"]][["lat"]]
  lon <- loc[["results"]][["geometry"]][["location"]][["lng"]]
  p_name <- loc[["results"]][["formatted_address"]]
  Voting.Place.ID <- votingplace[j,1]
  if (nrow(counc.data) == 0){
    counc.data <- data.frame(Voting.Place.ID,lat,lon,p_name)
  }else{
    newrow <- data.frame(Voting.Place.ID, lat,lon,p_name)
    counc.data <- rbind(counc.data,newrow)
  }
}

# Merge the original councillor data with the new lat/lon data, then write out the resulting csv.
finaldf <- merge(councillor,counc.data, by="Voting.Place.ID")
write.csv(finaldf,'~/Documents/finaldf.csv')
