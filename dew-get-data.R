setwd("/Users/user/Desktop/dew")
# define the states and their corresponding network codes
states <- c("GA", "NC", "SC","AL", "TN", "VA", "FL", "KY", "WV")
network_codes <- c("GA_ASOS", "NC_ASOS", "SC_ASOS", "AL_ASOS", "TN_ASOS", "VA_ASOS", "FL_ASOS", "KY_ASOS", "WV_ASOS")  # Corresponding network codes for each state

# define the station codes for each state
station_codes <- list(
  GA = c("AHN", "ATL", "CSG", "MCN", "SAV"),
  NC = c("AVL", "CLT", "GSO", "POB", "RDU"),  
  SC = c("CAE", "CHS", "GSP"),
  AL = c("BHM", "HSV", "MGM"),
  TN = c("BNA", "CHA", "MEM"),
  VA = c("DCA", "ROA"),
  FL = c("DAB", "EYW", "GNV", "JAX", "MCO", "MIA", "TLH", "TPA", "VPS"),
  KY = c("HOP", "LEX", "SDF"),
  WV = c("HTS")
)

# define the URL pattern for downloading the station data
url_pattern <- "https://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?station=%s&data=dwpf&year1=1973&month1=1&day1=1&year2=2022&month2=12&day2=31&tz=Etc%%2FUTC&format=onlycomma&latlon=yes&elev=yes&missing=M&trace=T&direct=no&report_type=1&report_type=2"

# loop over the states and download the station data for each state
for (i in 1:length(states)) {
  state <- states[i]
  network <- network_codes[i]
  station_list <- station_codes[[state]]
  
  # loop over the stations within the current state
  for (station in station_list) {
    # construct the URL for the current station
    url <- sprintf(url_pattern, station)
    
    # construct the file name for the downloaded CSV
    file_name <- paste0(state, "_", station, "_ASOS.csv")
    
    # check if the file already exists in the directory
    if (file.exists(file_name)) {
      message("File '", file_name, "' already exists. Skipping download.")
      next
    }
    
    # download the station data as a CSV file
    download.file(url, destfile = file_name, method = "auto")
    
    # print a message indicating the successful download
    message("Downloaded station data for ", state, " - ", station, " ASOS: ", file_name)
  }
}
