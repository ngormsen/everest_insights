library(shiny)
library(shinymaterial)
library(DT)
# library(fresh)

source("html_elements.R")

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  includeCSS("WWW/style.css"),
  
  # Header ------------------------------------------------------------------
  HTML(htmlHeader),
  
  # Dataset -----------------------------------------------------------------
  fluidRow(
    column(3,
      fileInput("userInputFile", "Transaction Log", accept = ".csv"),
      selectInput("custIdCol", "Customer ID", choices = NULL, multiple = FALSE),
      selectInput("amountSpentCol", "Amount Spent", choices = NULL, multiple = FALSE),
      selectInput("orderTimestampCol", "Timestamp of Order", choices = NULL, multiple = FALSE),
      actionButton("startPreprocessing", "Preprocess Dataset")
    ),
    column(9, DTOutput(outputId="plotTranslogRaw"))
  ),
  
  HTML(dividerHTML),
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
  
  HTML(dividerHTML),
  h2("CLV Analysis"),
  plotOutput("plotCLVScatterplot"),
  
  HTML(dividerHTML),
  h2("Recency & Frequency Segmentation"),
  plotOutput("plotRecencyFrequency")
))

shinyApp(ui, server)
