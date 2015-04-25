# =============================================================================
# Question 4: Across the United States, how have emissions from coal 
# combustion-related sources changed from 1999-2008?
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
## find all coal combustion related source classifications
SCCcoalcomb <- SCC$SCC[grepl("(Comb.*Coal)|(Coal.*Comb)", SCC$Short.Name, 
                             ignore.case = TRUE)]
# save some memory since SCC codes are unique entries
SCCcoalcomb <- as.character(SCCcoalcomb)

## calculate total emissions table
totalemissions <- NEI %>% filter(SCC %in% SCCcoalcomb) %>% group_by(year) %>% 
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
    labs(title = "US PM2.5 Emission from Coal Combustion, 1999-2008")
print(g)

## save results to image file
dev.copy(png, file="plot4_coal.png", width=640, height=480); 
dev.off()