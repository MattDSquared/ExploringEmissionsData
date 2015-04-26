# =============================================================================
# Question 6: Compare emissions from motor vehicle sources in Baltimore City 
# with emissions from motor vehicle sources in Los Angeles County, California 
# (fips == 06037). Which city has seen greater changes over time in motor 
# vehicle emissions?
# =============================================================================
library(plyr); library(dplyr)
library(ggplot2)
if (file.exists("ExploringEmissionsData")) setwd("ExploringEmissionsData")

# =============================================================================
# Load the data
# =============================================================================
## download data useing external function
source("download.R")
dldata("NEI_data.zip", 
       "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip")

## load the data if it doesn't already exist in memory, faster for testing
if (!exists("NEI")) {
    NEI <- readRDS("summarySCC_PM25.rds")
    
    NEI$fips <- factor(NEI$fips)
    NEI$SCC <- factor(NEI$SCC)
    NEI$Pollutant <- factor(NEI$Pollutant)
    NEI$type <- factor(NEI$type)
} else {
    message("using previously loaded NEI data.")
}
if (!exists("SCC")) {
    SCC <- readRDS("Source_Classification_Code.rds")
} else {
    message("using previously loaded SCC data.")
}

# =============================================================================
# calculate mean-centered, total emissions
#   Mean-centering shows change in each data set as compared to the other.
#   Total emissions avoids any confusion for how the data might have been 
#   scaled. For future work, bringing in the square area of the county, or 
#   possibly making PM2.5 per capita would be valuable scaling factor. 
# =============================================================================

## define motor vehicle using the following criteria:
print(unique(filter(SCC, SCC.Level.One == "Mobile Sources")$SCC.Level.Two))
#[1] Highway Vehicles - Gasoline            Border Crossings                      
#[3] Highway Vehicles - Diesel              Off-highway Vehicle Gasoline, 2-Stroke
#[5] Off-highway Vehicle Gasoline, 4-Stroke LPG                                   
#[7] CNG                                    Off-highway Vehicle Diesel            
#[9] Aircraft                               Marine Vessels, Commercial            
#[11] Pleasure Craft                         Marine Vessels, Military              
#[13] Railroad Equipment                     Paved Roads                           
#[15] Unpaved Roads                          unknown non-US source 

## motor vehicle is defined as SCC.Level.Two having the following values:
motorvehicledescriptor = c("Highway Vehicles - Gasoline", 
                           "Highway Vehicles - Diesel",
                           "Off-highway Vehicle Gasoline, 4-Stroke",
                           "Off-highway Vehicle Gasoline, 2-Stroke",
                           "Off-highway Vehicle Diesel")

SCCmotor <- filter(SCC, (SCC.Level.One == "Mobile Sources") & 
                               (SCC.Level.Two %in% motorvehicledescriptor))

## Calculate total emissions data based on fips and motor vehicle SCC
# subset for Baltimore City, Maryland, fips = 24510
# subset for Los Angeles, CA, fips = 06037
emSum <- NEI %>% 
    filter(((fips == "24510") | (fips == "06037")) & (SCC %in% SCCmotor$SCC)) %>% 
    group_by(year,fips) %>% 
    summarize(TotalEmissions = sum(Emissions))

## Shift data for comparison of change to initial 1999 value
# TODO: there's probably a cleaner way to do this, but this works for now
# get initial emissions for each city
IDX.Balt <- emSum$fips == "24510"
IDX.LA <- emSum$fips == "06037"
em0.Balt <- emSum$TotalEmissions[IDX.Balt & emSum$year == 1999]
em0.LA <- emSum$TotalEmissions[IDX.LA & emSum$year == 1999]
# initialize trended variable (compiler complains otherwise)
emSum$TrendedEmissions <- rep(0,nrow(emSum))
# subract TotalEmissions by initial value
emSum$TrendedEmissions[IDX.Balt] <- emSum$TotalEmissions[IDX.Balt] - em0.Balt
emSum$TrendedEmissions[IDX.LA] <- emSum$TotalEmissions[IDX.LA] - em0.LA

# =============================================================================
# plot and save results
# =============================================================================
## set up window
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI, xpos=0, ypos=0)

## plot data using ggplot2
# rename fips for clarity
emSum <- emSum %>% mutate(City = sub("24510","Baltimore", fips)) %>%
    mutate(City = sub("06037","Los Angeles", City))

# line plot used for consistency with previous plots, bar may be better here
g <- ggplot(emSum, aes(year, TrendedEmissions, color=City))
g <- g + 
    geom_line(linetype=2) +
    geom_smooth(method="lm", se=FALSE, linetype=1, size=1) +
    labs(x = "Year") +
    labs(y = "Change in PM2.5 Emmisions (tons)") + 
    labs(legend = c("Baltimore", "Los Angeles"))
g <- g + labs(title = paste("Change in PM2.5 from Motor Vehicles\n",
                            "Baltimore vs. Los Angeles, 1999-2008", sep=""))
print(g)

## save results to image file
dev.copy(png, file="plot6_motorvehicle_LAvsBA.png", width=640, height=480); 
dev.off()