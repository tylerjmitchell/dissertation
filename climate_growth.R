require("tidyverse")
require("readxl")

setwd("~/Documents/dissertation")

data <- read_excel("analyses.xlsx")
data <- as.data.frame(data)
cor(data)
