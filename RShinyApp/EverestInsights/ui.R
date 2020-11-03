library(shiny)
library(shinymaterial)
library(DT)

source("html_elements.R")

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
    includeCSS("WWW/style.css"),

    # Header ------------------------------------------------------------------
    HTML(htmlHeader),

    # Dataset -----------------------------------------------------------------
    h2("Import Data"),
    materialCard(
        fluidRow(
            column(3,
                   fileInput("userInputFile", "Transaction Log", accept = ".csv"),
                   selectInput("custIdCol", "Customer ID", choices = NULL, multiple = FALSE),
                   selectInput("amountSpentCol", "Amount Spent", choices = NULL, multiple = FALSE),
                   selectInput("orderTimestampCol", "Timestamp of Order", choices = NULL, multiple = FALSE),
                   actionButton("startPreprocessing", "Preprocess Dataset")
            ),
            column(9, DTOutput(outputId="plotTranslogRaw"))
        )
    ),
    
    h2("Cohort Analysis"),
    materialCard(
        selectInput(
            inputId = "cohortType",
            label = NULL, 
            choices = c("Monthly Cohorts", "Quarterly Cohorts", "Yearly Cohorts"),
            selected = "Monthly Cohorts"
        ),
        fluidRow(
            column(6, plotOutput("plotCohortAgeLinechart")),
            column(6, plotOutput("plotC3"))
        )
    ),
    
    h2("CLV Analysis"),
    materialCard(
        plotOutput("plotCLVScatterplot"),
    ),
    
    h2("Recency & Frequency Segmentation"),
    materialCard(
        plotOutput(
            "plotRecencyFrequency",
            height = 300,
            click = "plotRecencyFrequency_click",
            brush = brushOpts(id = "plotRecencyFrequency_brush")
        ),
        textOutput("customer_title"),
        verbatimTextOutput("click_info")
    )
))
