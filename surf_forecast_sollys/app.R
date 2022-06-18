
library(shiny)
library(RMariaDB)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Solly's data input"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          dateInput("date", label = h3("Date")),
          selectInput("time", label = h3("Select the closest time"),
                      choices = c("2AM", "5AM", "8AM", "11AM", "2PM", "5PM",
                                  "8PM", "11PM")),
          radioButtons("yes_no", label = h3("Is it worth going out?"),
                       choices = list("Yes"="Yes", "No"="No")),
          actionButton("submit", label = "Submit report")
        ),

        # Show a plot of the generated distribution
        mainPanel(
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  report_df <- reactive({
    date <- as.character(input$date)
    time <- as.character(input$time)
    date_time <- paste(date, time)
    report <- as.character(input$yes_no)
    return(data.frame(date_time=date_time, date=date, time=time,
                            report=report))
  })
  
  observeEvent(input$submit, {
    mySQLdb <- dbConnect(MariaDB(), user="tyryn", password="lets_surf!", dbname="surf_forecast_db", host="surf-forecast-database.c8jiq4m8tj3s.us-east-1.rds.amazonaws.com")
    dbWriteTable(mySQLdb, value=report_df(), row.names=FALSE, name="report_sollys", append=TRUE)
  })

  
}

# Run the application 
shinyApp(ui = ui, server = server)
