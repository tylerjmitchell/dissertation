setwd("/Users/user/Desktop/dew")
library(tidyr)
library(dplyr)

# Function to process a single CSV file
process_csv <- function(file_path) {
  data <- read.csv(file_path)
  data <- tidyr::separate(data, valid, sep = "-", into = c("year", "month", "day"))
  data <- tidyr::separate(data, day, sep = " ", into = c("day", "time"))
  data <- tidyr::separate(data, time, sep = ":", into = c("hour", "minute"))
  
  data$dwpf <- as.numeric(data$dwpf)
  data <- data[complete.cases(data), ]
  
  data$year <- as.numeric(data$year)
  data$day <- as.numeric(data$day)
  data$month <- as.numeric(data$month)
  data$hour <- as.numeric(data$hour)
  data$minute <- as.numeric(data$minute)
  JJA.data <- data[data$month %in% 6:8, ]
  JJA.data <- JJA.data[JJA.data$year > 1972, ]
  
  percentile <- quantile(JJA.data$dwpf, c(.90))
  JJA.data$warmdew <- ifelse(JJA.data$dwpf > percentile, 1, 0)
  
  JJA.data$CWH <- ifelse(JJA.data$hour != lag(JJA.data$hour) &
                           JJA.data$year == lag(JJA.data$year), JJA.data$warmdew, NA)
  
  AVL3 <- aggregate(CWH ~ day + month + year, FUN = sum, data = JJA.data)
  AVL3$CWE <- ifelse(AVL3$CWH > 12, 1, 0)
  
  AVL3$CWE_back_to_back <- ifelse(AVL3$CWE == 1 & lag(AVL3$CWE) == 1 & AVL3$year == lag(AVL3$year), 1, 0)
  
  back_to_back_counts <- aggregate(CWE_back_to_back ~ year, FUN = sum, data = AVL3)
  
  AVL3$CWE_duration <- with(AVL3, ave(CWE_back_to_back, cumsum(cumsum(CWE_back_to_back == 0) * CWE_back_to_back)), FUN = length)
  back_to_back_durations <- aggregate(CWE_duration ~ year, FUN = sum, data = AVL3)
  
  CWH <- aggregate(CWH ~ year, FUN = sum, data = AVL3)
  CWE <- aggregate(CWE ~ year, FUN = sum, data = AVL3)
  
  # Create a data frame with results from the current CSV file
  result_df <- data.frame(year = unique(AVL3$year),
                          EDH = CWH$CWH,
                          EDD = CWE$CWE,
                          MDEDE = back_to_back_counts$CWE_back_to_back,
                          MDMDEDE = back_to_back_durations$CWE_duration)
  
  # Add a column to indicate the source CSV file
  result_df$file <- file_path
  
  return(result_df)
}

# Get a list of all CSV files in the directory
file_list <- list.files(pattern = "*.csv")

# Process all the CSV files and combine the results
result_df_list <- lapply(file_list, process_csv)

# Combine the results into a single data frame
combined_results <- Reduce(function(x, y) merge(x, y, by = "year", all = TRUE), result_df_list)

# Save the combined results to a CSV file
output_file <- "combined_results.csv"
write.csv(combined_results, file = output_file, row.names = FALSE)

# Print the combined results
print(combined_results)

# Print the file save message
message("Combined results saved as '", output_file, "'")

