# =============================================================================
# Question 2: Have total emissions from PM2.5 decreased in the Baltimore City, 
# Maryland (fips == "24510") from 1999 to 2008? Use the base plotting system to
# make a plot answering this question.
# =============================================================================
library(plyr); library(dplyr)
library(RColorBrewer)
library(reshape2)
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
# totalemissions <- dcast(totalemissions, year ~ type, value.var="TotalEmissions")

# =============================================================================
# plot and save results
# =============================================================================
## set up window
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI, xpos=0, ypos=0)

## initialize nicer colors
cols <- brewer.pal(4,"Set1")

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