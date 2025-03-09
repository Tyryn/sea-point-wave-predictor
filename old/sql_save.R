library(RMariaDB)

source("scrape.R")

# Set up the dataframe
mySQLdb <- dbConnect(MariaDB(), user="tyryn", password="lets_surf!", dbname="surf_forecast_db", host="surf-forecast-database.c8jiq4m8tj3s.us-east-1.rds.amazonaws.com")
dbListTables(mySQLdb)


# Write and append to the table
dbWriteTable(mySQLdb, value=forecast_df, row.names=FALSE, name="forecast_cpt", append=TRUE)


Sys.Date()