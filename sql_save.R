library("RMariaDB")

# Set up the dataframe
mySQLdb <- dbConnect(MariaDB(), user="root", password="321SouthAfrica!", dbname="forecast", host="localhost")
dbListTables(mySQLdb)


# Write and append to the table
dbWriteTable(mySQLdb, value=forecast_df, row.names=FALSE, name="forecast_cpt", append=TRUE)


source("scrape.R")
