## Decision tree scratch pad
library(RMariaDB)
library(rpart)
library(rpart.plot)

# Get the data from the mySQL databases
# Get user and password from cinfig file
mySQLdb <- dbConnect(MariaDB(), user="", password="", dbname="surf_forecast_db", host="surf-forecast-database.c8jiq4m8tj3s.us-east-1.rds.amazonaws.com")
dbListTables(mySQLdb)

forecast_report_sollys <- dbReadTable(mySQLdb, "forecast_report_sollys")


# Add data to the table
dates <- c("2020-06-20", "2020-07-20", "2020-01-03", "2020-06-06", "2020-02-02", "2020-11-11",
           "2020-04-04", "2020-05-05", "2020-05-06")
times <- c("2AM", "5AM", "8AM", "11AM", "2PM", "5PM", "8PM", "11PM", "8AM")
date_time <- paste(dates, times)
swell_size <- c(3.65, 3.55, 3.5, 3.44, 3.55, 3.66, 3.87, 3.0, 3.66)
swell_direction <- c("SW", "SW", "WSW", "W", "WSW", "SW", "WSW", "SW", "SW")
period <- c(13, 13, 14, 13, 13, 14, 12, 13, 13)
wind_speed <- c(rep(20, each=9))
wind_direction <- c("SE", "SSE", "E", "ESE", "SE", "SE", "SE", "SE", "NW")
tide_state <- c("high", "high", "ebb", "high", "flow", "ebb", "high", "low", "high")
report <- c("Yes", "Yes","Yes","Yes","Yes","Yes","Yes", "No",  "No")

sollys_fake_df <- data.frame(date_time=date_time, date=as.Date(dates), time=times, 
                             swell_size=swell_size, swell_direction=swell_direction,
                             period=period, wind_speed=wind_speed, wind_direction=wind_direction,
                             tide_state=tide_state, report=report)

sollys_test_df <- subset(rbind(forecast_report_sollys, sollys_fake_df), select = -c(date_time, date, time))

# Replace swell sizes with categories
sollys_test_df$swell_size_2 <- with(sollys_test_df, 
                                    ifelse(swell_size<1.52, "XS",
                                                         ifelse(swell_size>=1.52 
                                                                & swell_size<2.74, "S",
                                                                ifelse(swell_size>=2.74 & swell_size<3.65,
                                                                       "M", ifelse(swell_size>=3.65 & 
                                                                                     swell_size<4.57,  
                                                                                   "L", ifelse(swell_size>=4.57,
                                                                                               "XL", "NULL"))))))
# Replace period with categories
sollys_test_df$period_2 <- with(sollys_test_df,
                                ifelse(period<10, "low",
                                       ifelse(period>=10 & period<13, "medium",
                                              ifelse(period>=13 & period<15, "high",
                                              ifelse(period>=15, "very high", 'NULL')))))
                                       
                                       
                                       

# Drop swell size
sollys_test_df <- sollys_test_df[-c(1,3)]

## Apply algo
fit <- rpart(report~., data = sollys_test_df, method = 'class', minsplit=2, minbucket=1)
rpart.plot(fit)

## Fit predictions to scraped data
forecast_fit <- dbReadTable(mySQLdb, "forecast_cpt")
# Replace swell sizes with categories
forecast_fit$swell_size_2 <- with(forecast_fit, 
                                    ifelse(swell_size<1.52, "XS",
                                           ifelse(swell_size>=1.52 
                                                  & swell_size<2.74, "S",
                                                  ifelse(swell_size>=2.74 & swell_size<3.65,
                                                         "M", ifelse(swell_size>=3.65 & 
                                                                       swell_size<4.57,  
                                                                     "L", ifelse(swell_size>=4.57,
                                                                                 "XL", "NULL"))))))
# Replace period with categories
forecast_fit$period_2 <- with(forecast_fit,
                                ifelse(period<10, "low",
                                       ifelse(period>=10 & period<13, "medium",
                                              ifelse(period>=13 & period<15, "high",
                                                     ifelse(period>=15, "very high", 'NULL')))))

levels_wind_fit <- unlist(unique(sollys_test_df["wind_direction"]))


forecast_fit <- forecast_fit[rowSums(sapply(forecast_fit[-8], '%in%', levels_wind_fit))>0,]

# Argh
forecast_fit <- forecast_fit[!(forecast_fit$wind_direction=="N"|forecast_fit$wind_direction=="SSW"),]

forecast_fit_predict <- predict(fit, forecast_fit, type = "class")
