library(shiny)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(

    # Header ------------------------------------------------------------------
    titlePanel("Everest Insights"),


    # Dataset -----------------------------------------------------------------
    fileInput(inputId = "userInputFile", label = "Transaction Log", accept = ".csv"),
    
    selectInput("custIdCol", "Customer ID", choices = NULL),
    selectInput("amountSpentCol", "Amount Spent", choices = NULL),
    selectInput("orderTimestampCol", "Timestamp of Order", choices = NULL),
    actionButton("startPreprocessing", "Preprocess Dataset"),
    
    DTOutput(outputId="plotTranslogRaw"),
    
    
    h2("Cohort Analysis"),
    selectInput(
        inputId = "cohortType",
        label = NULL, 
        choices = c("Monthly Cohorts", "Quarterly Cohorts", "Yearly Cohorts"),
        selected = "Monthly Cohorts"
    ),
    fluidRow(
        column(6, plotOutput("plotCohortAgeLinechart")),
        column(6, plotOutput("plotC3"))
    ),
    
    
    h2("CLV Analysis"),
    plotOutput("plotCLVScatterplot")
))
