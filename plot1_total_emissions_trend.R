# =============================================================================
# Question 1: Have total emissions from PM2.5 decreased in the United States 
# from 1999 to 2008? Using the base plotting system, make a plot showing the 
# total PM2.5 emission from all sources for each of the years 1999, 2002, 2005,
# and 2008.
# =============================================================================
library(plyr); library(dplyr)
library(RColorBrewer)
if (file.exists("ExploringEmissionsData")) setwd("ExploringEmissionsData")

# =============================================================================
## Load the data
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
## calculate total emissions
# =============================================================================
totalemissions <- NEI %>% group_by(year) %>% 
    summarize(TotalEmissions = sum(Emissions))

# =============================================================================
## plot and save results
# =============================================================================
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI)

plot(totalemissions, type = "l", 
     ylab="PM2.5 Emmisions (tons)", xlab="Year")
title("Total PM2.5 Emission for US between 1999 and 2008")

## save results to image file
dev.copy(png, file="plot1_PM2.5_over_time.png"); dev.off()