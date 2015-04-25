# =============================================================================
# Question 5: How have emissions from motor vehicle sources changed from 1999-
# 2008 in Baltimore City?
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
# calculate total emissions
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

## subset for Baltimore City, Maryland, fips = 24510
## calculate total emissions table
totalemissions <- NEI %>% 
    filter((fips == 24510) & (SCC %in% SCCmotor$SCC)) %>% 
    group_by(year) %>% 
    summarize(TotalEmissions = sum(Emissions))

# =============================================================================
# plot and save results
# =============================================================================
## set up window
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI, xpos=0, ypos=0)

## plot data using ggplot2
g <- ggplot(totalemissions, aes(year, TotalEmissions))
g <- g + 
    geom_line(linetype=2) +
    geom_smooth(method="lm", se=FALSE, linetype=1, size=1) +
    labs(x = "Year") +
    labs(y = "PM2.5 Emmisions (tons)") + 
    labs(title = "Baltimore PM2.5 Emission from Motor Vehicles, 1999-2008")
print(g)

## save results to image file
dev.copy(png, file="plot5_motorvehicle.png", width=640, height=480); 
dev.off()