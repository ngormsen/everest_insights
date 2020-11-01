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
    

    # Cohort Analysis ------------------------------------------------------------------
    h2("Cohort Analysis"),
    selectInput(
        inputId = "cohortType",
        label = "Choose Type of Cohorts", 
        choices = c("Monthly Cohorts", "Quarterly Cohorts", "Yearly Cohorts"),
        selected = "Monthly Cohorts"
    ),
    # DTOutput(outputId="plotCohortData"),
    # tabsetPanel(type = "tabs",
    #             tabPanel("Linechart", plotOutput("plotCohortAgeLinechart")),
    #             tabPanel("C3", plotOutput("plotC3"))
    # )
    fluidRow(
        column(6, plotOutput("plotCohortAgeLinechart")),
        column(6, plotOutput("plotC3"))
    )
    # plotOutput("plotCohortAgeLinechart"),
    # plotOutput("plotC3")

    # CLV Analysis ------------------------------------------------------------------
))
