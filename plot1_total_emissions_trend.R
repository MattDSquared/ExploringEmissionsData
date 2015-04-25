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
source("loaddata.R")

# =============================================================================
## calculate total emissions
# =============================================================================
totalemissions <- NEI %>% group_by(year) %>% 
    summarize(TotalEmissions = sum(Emissions))

# =============================================================================
## plot and save results
# =============================================================================
PPI <- 96 # pixels per inch
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI)

plot(totalemissions, type = "l", 
     ylab="PM2.5 Emmisions (tons)", xlab="Year")
title("Total PM2.5 Emission for US between 1999 and 2008")

## save results to image file
dev.copy(png, file="plot1_PM2.5_trend.png"); dev.off()