library(data.table)
library(tidyverse)
library(DT)
library(lubridate)
library(RColorBrewer)
library(plotly)

source("ui.R")
source("utils.R")


server <- function(input, output, session) {
  

# Data Import + Preprocessing --------------------------------------------------------------------
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

# Computations ------------------------------------------------------------



# Plots DashBoard----------------------------------------------------------
  output$plotTranslogRaw <- renderDT({
    PlotTranslog(translogClean())
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
  
  dt <- reactive({
    CreateCohortCols(data = translogClean(), cohortType = "Monthly Cohorts")
  })
  
  output$revenuePerCustomerCohortDevelopment <- renderPlot({
    PlotCohortAgeLinechart(dt())
  })
  
  output$uniqueCustomerPerMonth <- renderPlotly({
    plotUniqueCustomerPerMonth(computeUniqueCustomerPerMonth(translog()))
  })
  
  output$numberOfCustomers <- renderValueBox({
    valueBox(
      value = numberOfCustomers(),
      subtitle = "numberOfCustomers",
      icon = icon("credit-card")
    )
  })
  

  output$plotC3 <- renderPlot({
    PlotC3(dt(), "Monthly Cohorts")
  })
  
  
# Plots Cohort----------------------------------------------------------
  
  output$cohortTableNPurchases <- renderPlot({
    data <- GetDataCohortTableOfNumPurchases(translog(), x = "orderPeriod")
    PlotCohortTableOfNumPurchases(data)
  })
  
  output$cohortTableCustom <- renderPlot(expr = {
    data <- GetDataCohortTableCustom(
      translog = translog(),
      x = "orderPeriod",
      var = input$selectSummariseVar,
      fun = input$selectSummariseFunc,
      relativeTo = input$selectRelativeTo
    )
    if (input$selectRelativeTo == "none"){
      return(PlotCohortTableCustom(data, perc = F))
    } else {
      return(PlotCohortTableCustom(data, perc = T))
    }
  }, height = 600)
}
