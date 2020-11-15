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

  numberOfCustomers <- reactive({
   length(unique(translogClean()$custId))
  })
  
  computeDataPerMonth <- function(transLog) {
    dt <- copy(transLog)
    dt[, numOrdersPerMonth := .N, by = .(custId, orderPeriod)]
    dt[, amountSpentPerOrderPeriod := sum(amountSpent), by = orderPeriod]
    customerPerMonth <- unique(dt, by = "orderPeriod")
    revenuePerMonth <- unique(dt, by = "orderPeriod")
    return(list(customerPerMonth=customerPerMonth, revenuePerMonth=revenuePerMonth))
  }
  
  
  output$customerPerMonth <- renderPlot({
    ggplot(data = computeDataPerMonth(translog())[["customerPerMonth"]], aes(x = orderPeriod, y = numOrdersPerMonth)) +
      geom_bar(stat = "identity", fill = "steelblue", color = "white", width = 0.5) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 50, size = 8)) +
      ggtitle(paste("Number of Customers per Month")) +
      ylab("Number of Customers")
  })
  
  output$revenuePerMonth <- renderPlot({
    ggplot(data = computeDataPerMonth(translog())[["revenuePerMonth"]], aes(x = orderPeriod, y = amountSpentPerOrderPeriod)) +
      geom_bar(stat = "identity", fill = "steelblue", color = "white", width = 0.5) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 50, size = 8)) +
      ggtitle(paste("Revenue Per Month")) +
      ylab("Revenue Per Month")
  })
  
  
  output$numberOfCustomers <- renderValueBox({
    valueBox(
      value = numberOfCustomers(),
      subtitle = "numberOfCustomers",
      icon = icon("credit-card")
    )
  })
}
