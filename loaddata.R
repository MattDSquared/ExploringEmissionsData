# =============================================================================
# Downloads, unzips, then loads the NEI and SCC data into R
# Will skip downloading if it finds the .zip file already exists
# Will skip data loading if NEI or SCC variable already exists in R
# =============================================================================

if (file.exists("ExploringEmissionsData")) setwd("ExploringEmissionsData")

source("download.R")
dldata("NEI_data.zip", 
       "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip")

## This first line will likely take a few seconds the first time. Be patient!
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
## WARNING: do not modify NEI or SCC after this point, 
## inconsistent behovior may occur
