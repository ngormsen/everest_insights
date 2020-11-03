library(shiny)
library(shinymaterial)
library(DT)

# Define UI for application that draws a histogram
ui <- material_page(fluidPage(

    # Header ------------------------------------------------------------------
    titlePanel("Everest Insights"),


    # Dataset -----------------------------------------------------------------
    # fileInput(inputId = "userInputFile", label = "Transaction Log", accept = ".csv"),
    material_card(
        material_file_input(input_id = "userInputFile", label = "Transaction Log"),
        material_dropdown(input_id = "custIdCol", label = "Customer ID", choices = NULL, multiple = FALSE, color = "#ef5350"),
        material_dropdown("amountSpentCol", "Amount Spent", choices = NULL, multiple = FALSE, color = "#ef5350"),
        material_dropdown("orderTimestampCol", "Timestamp of Order", choices = NULL, multiple = FALSE, color = "#ef5350"),
        actionButton("startPreprocessing", "Preprocess Dataset"),
    ),
    
    material_card(
        DTOutput(outputId="plotTranslogRaw"),
    ),
    
    material_card(
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
    ),
    
    material_card(
        h2("CLV Analysis"),
        plotOutput("plotCLVScatterplot")
    ),
    
    material_card(
        h2("Recency & Frequency Segmentation"),
        plotOutput(
            "plotRecencyFrequency", height = 300,
           # Equivalent to: click = clickOpts(id = "plot_click")
        click = "plotRecencyFrequency_click",
        brush = brushOpts(id = "plotRecencyFrequency_brush")
        ),
        material_card(
            textOutput("customer_title"),
            verbatimTextOutput("click_info")
        )
        
    )
))
