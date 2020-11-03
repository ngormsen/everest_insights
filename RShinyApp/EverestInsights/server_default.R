library(shiny)
library(data.table)
library(tidyverse)
library(DT)
library(lubridate)

source("ui_default.r")
source("utils.R")


server <- function(input, output, session) {
  
  # Calculations ------------------------------------------------------------
  translogRaw <- reactive({
    file <- input$userInputFile
    ext <- tools::file_ext(file$datapath)
    req(file)
    validate(need(ext == "csv", "Please upload a csv file"))
    
    dt <- as.data.table(read.csv(file=file$datapath))
    dt
  })
  
  # Update inputs for choosing customerId-, orderId, and timestamp-column
  observe({
    updateSelectInput(session, inputId = "custIdCol", choices = names(translogRaw()))
    updateSelectInput(session, inputId = "amountSpentCol", choices = names(translogRaw()))
    updateSelectInput(session, inputId = "orderTimestampCol", choices = names(translogRaw()))
  })
  
  # Once the user clicks on "Start Preprocessing"-Button, start preprocessing
  translogClean <- eventReactive(input$startPreprocessing, {
    PreprocessRawTransactionLog(
      data = translogRaw(),
      columns = list("custId" = input$custIdCol,
                     "amountSpent" = input$amountSpentCol,
                     "orderTimestamp" = input$orderTimestampCol)
    )
  })
  
  dt <- reactive({
    CreateCohortCols(data = translogClean(), cohortType = input$cohortType)
  })
  
  clvs <- reactive({
    ComputeCLV(transLog = dt())
  })
  
  recencyFrequency <- reactive({
    ComputeRecencyFrequency(dt())
  })
  
  # Outputs ---------------------------------------------------------
  output$plotTranslogRaw <- renderDT({
    PlotTranslog(translogClean())
  })
  
  output$plotCohortData <- renderDT({
    dt()
  })
  
  output$plotCohortAgeLinechart <- renderPlot({
    PlotCohortAgeLinechart(dt())
  })
  
  output$plotC3 <- renderPlot({
    PlotC3(dt(), input$cohortType)
  })
  
  output$plotCLVScatterplot <- renderPlot({
    PlotCLVDensity(clvs())
  })
  
  output$plotRecencyFrequency <- renderPlot({
    PlotRecencyFrequency(recencyFrequency())
  })
}

shinyApp(ui=ui, server=server)
