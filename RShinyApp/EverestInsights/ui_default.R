library(shiny)
library(shinymaterial)
library(DT)
library(fresh)


# html strings --------------------------------------------------------------
logoHTML <- "
<div style='border-bottom: 1px solid darkgray; height:160px;'>
  <img style='max-height: 155px; float: left' src='https://www.creativefabrica.com/wp-content/uploads/2019/10/24/20-1-580x387.jpg'/>
</div>
"

dividerHTML <- "
<div style='padding: 2em 0;'>
<hr style='border-top: 1px solid darkgray;'>
</div>
"

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  includeCSS("WWW/style.css"),
  
  # Header ------------------------------------------------------------------
  HTML(logoHTML),
  
  # Dataset -----------------------------------------------------------------
  h2("Load Transaction Log"),
  fileInput("userInputFile", "Transaction Log", accept = ".csv"),
  selectInput("custIdCol", "Customer ID", choices = NULL, multiple = FALSE),
  selectInput("amountSpentCol", "Amount Spent", choices = NULL, multiple = FALSE),
  selectInput("orderTimestampCol", "Timestamp of Order", choices = NULL, multiple = FALSE),
  actionButton("startPreprocessing", "Preprocess Dataset"),
  
  DTOutput(outputId="plotTranslogRaw"),
  
  
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


