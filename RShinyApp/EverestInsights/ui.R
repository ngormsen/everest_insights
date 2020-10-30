library(shiny)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
    titlePanel("Everest Insights"),
    
    fileInput(inputId = "userInputFile", label = "Transaction Log", accept = ".csv"),
    
    selectInput("custIdCol", "Customer ID", choices = NULL),
    selectInput("orderIdCol", "Order ID", choices = NULL),
    selectInput("orderTimestampCol", "Timestamp of Order", choices = NULL),
    
    DTOutput(outputId="plotTranslogRaw")
))
