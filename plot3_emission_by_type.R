# =============================================================================
# Question 2: Have total emissions from PM2.5 decreased in the Baltimore City, 
# Maryland (fips == "24510") from 1999 to 2008? Use the base plotting system to
# make a plot answering this question.
# =============================================================================
library(plyr); library(dplyr)
library(RColorBrewer)
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
## calculate total emissions
# =============================================================================
# Baltimore City, Maryland has fips = 24510
totalemissions <- NEI %>% filter(fips == 24510) %>% group_by(year) %>% 
    summarize(TotalEmissions = sum(Emissions))

# =============================================================================
## plot and save results
# =============================================================================
PPI <- 96 # pixels per inch for my monitor
windows(width=640/PPI, height=480/PPI, xpinch=PPI, ypinch=PPI)

plot(totalemissions, "l", lty=2,
     ylab="PM2.5 Emmisions (tons)", xlab="Year")
title("Total PM2.5 Emission for Baltimore between 1999 and 2008")
model <- lm(TotalEmissions ~ year, totalemissions)
abline(model, lwd=2)

strlegend <- c("")
legend("topright", legend=c("PM2.5 Baltimore", "Linear Fit"),
       lwd=c(1,2), lty=c(2,1))

## save results to image file
dev.copy(png, file="plot2_PM2.5_baltimore.png"); dev.off()