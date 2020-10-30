library(shiny)
library(data.table)
library(tidyverse)
library(DT)
library(lubridate)

source("ui.R")


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
        updateSelectInput(session, inputId = "orderIdCol", choices = names(translogRaw()))
        updateSelectInput(session, inputId = "orderTimestampCol", choices = names(translogRaw()))
    })
    

# Outputs ---------------------------------------------------------
    output$plotTranslogRaw <- renderDT({
        translogRaw()
    })
}

shinyApp(ui=ui, server=server)
