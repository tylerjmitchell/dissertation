require("tidyverse")

data <- read.csv("2917741.csv")
head(data)

# convert NOAA's DATE into three separate variables using tidyr ----
data <- tidyr::separate(data, DATE, sep="-", into = c("year", "month", "day"))
data$year <- as.numeric(data$year)
data$month <- as.numeric(data$month)
data$day <- as.numeric(data$day)

# remove missing precipitation observations ----
data <- data[!is.na(data$PRCP),]

# subset months of interest for intense rainfall calculation, here: july (7) ----
selected.month <- 7
data <- data[data$month == selected.month,]

# standard-normal (z) scores for precipitation and selection of intensity threshold ----
data$z <- scale(data$PRCP)
threshold <- 2.00
data$ire <- ifelse(data$z > threshold, 1, 0)

# retain precipitation amounts from intense rainfall event (ire) selection ----
data$ireppt <- ifelse(data$ire == 1, data$PRCP, 0)

# summarize intense rainfall events by year ----
ire.frequency <- setNames(aggregate(data$ire ~ data$year, FUN = sum),
                   c("year", "ire.frequency"))

ire.precipitation <- setNames(aggregate(data$ireppt ~ data$year, FUN = sum),
                              c("year", "ire.precipitation"))

ire <- merge(ire.frequency, ire.precipitation, by = "year")
ire

# another workflow using the lubridate package and pipes to calculate all years 
# and months at once. calculates standard normal (z) scores based on ALL months distribution ----
require("lubridate")
require("tidyverse")
data <- read.csv("2917741.csv")

# remove missing precipitation observations ----
data <- data[!is.na(data$PRCP),]

# standard-normal (z) scores for precipitation and selection of intensity threshold ----
data$z <- scale(data$PRCP)
threshold <- 2.00
data$ire <- ifelse(data$z > threshold, 1, 0)

# retain precipitation amounts from intense rainfall event (ire) selection ----
data$ireppt <- ifelse(data$ire == 1, data$PRCP, 0)

data <- data %>% 
  group_by(year = year(DATE), month = month(DATE)) %>% 
  summarise_if(is.numeric, sum)

data[c(1:2,6,8:9)]
