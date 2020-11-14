library(data.table)
library(tidyverse)
library(DT)
library(lubridate)

source("ui.R")
source("utils.R")


server <- function(input, output, session) {
  
  translogRaw <- reactive({
    translogRaw <- as.data.table(read.csv("retail_relay2.csv"))
  })
  
    # for dev: translogClean is already loaded into environment
  translogClean <- reactive({
    PreprocessRawTransactionLog(
      data = translogRaw(),
      columns = list("custId" = "customerId",
                     "amountSpent" = "amountSpent",
                     "orderTimestamp" = "orderTimestamp")
    )
  })
  
  translog <- reactive({
    CreateCohortCols(data = translogClean(), cohortType = "Monthly Cohorts")
  })
  
  output$plotTranslogRaw <- renderDT({
    PlotTranslog(translogClean())
  })
  
  output$myplot <- renderPlot({
    hist(rnorm(5))
  })
  
  output$myvaluebox <- renderValueBox({
    valueBox(
      value = paste0(round(mean(translog()$amountSpent), 2), " $"),
      subtitle = "Avg. Order Size"
    )
  })
}
