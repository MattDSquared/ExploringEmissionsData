# =============================================================================
# Question 3: Of the four types of sources indicated by the type (point, 
# nonpoint, onroad, nonroad) variable, which of these four sources have seen 
# decreases in emissions from 1999-2008 for Baltimore City? Which have seen 
# increases in emissions from 1999-2008? Use the ggplot2 plotting system to 
# make a plot answer this question.
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
# Baltimore City, Maryland has fips = 24510
totalemissions <- NEI %>% filter(fips == 24510) %>% group_by(type,year) %>% 
    summarize(TotalEmissions = sum(Emissions))

# =============================================================================
# plot and save results
# =============================================================================
## set up window
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI, xpos=0, ypos=0)

## plot data using ggplot2
g <- ggplot(totalemissions, aes(year, TotalEmissions, color=type))
g <- g + 
    geom_line(linetype=2) +
    geom_smooth(method="lm", se=FALSE, linetype=1, size=1) +
    labs(x = "Year") +
    labs(y = "PM2.5 Emmisions (tons)") + 
    labs(title = "Baltimore PM2.5 Emission by type, 1999-2008")
print(g)
#(qplot(year, TotalEmissions, data=totalemissions, geom="line", color=type))


## save results to image file
dev.copy(png, file="plot3_PM2.5_baltimorebytype.png", width=640, height=480); 
dev.off()