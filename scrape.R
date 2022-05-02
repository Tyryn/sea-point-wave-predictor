# Scrape script ####
library(rvest)
library(tidyverse)
library(janitor)

# Dataset 
swell <- read_html("https://www.tide-forecast.com/locations/Cape-Town-South-Africa/forecasts/latest")

forecast <- swell %>% 
  html_table()

forecast <- forecast[[1]] %>% 
  slice(2:10)

# Get column names
var_names <- as.vector(forecast[[1]])
var_names <- var_names[-c(1, 4,5)] 
var_names <- append("Date",  var_names)

# Get tomorrow's date
tomorrow <- as.numeric(sub('.*\\-','',as.character(Sys.Date()+1)))

# Get dataframe
forecast_df <- forecast %>% 
  select(-1) %>% 
  slice(-c(4:5)) %>% 
  t(.) %>% # Transpose
  as.data.frame(.) %>% 
  # Get only tomorrow's data
  mutate(V1 = as.numeric(str_extract(V1,"\\d+"))) %>% 
  filter(V1==tomorrow) %>% 
  # Get the column names
  rename_with(~var_names) %>% 
  rename(time=`Change units`) %>% 
  # Replace date with tomorrow's date
  mutate(Date = Sys.Date()+1) %>% 
  # Clean names
  clean_names() %>% 
  # Separate swell and wind magnitude from direction
  mutate(swell_size = as.numeric(gsub("[^0-9.-]", "", swell_m_direction))) %>% 
  mutate(swell_direction = gsub("[^a-zA-Z]", "", swell_m_direction)) %>% 
  mutate(wind_speed = as.numeric(gsub("[^0-9.-]", "", wind_km_h))) %>% 
  mutate(wind_direction = gsub("[^a-zA-Z]", "", wind_km_h)) %>% 
  mutate(period = as.numeric(period_s)) %>% 
  select(-c(swell_m_direction, wind_km_h, wave_height_m, period_s)) %>% 
  mutate(date_time = paste(as.character(date), time)) %>% 
  relocate(date_time, date, time, swell_size, swell_direction, period, 
           wind_speed, wind_direction, tide_state) 
  


