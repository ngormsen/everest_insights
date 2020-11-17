library(shiny)
library(shinydashboard)
library(DT)
source("../html_elements.R")

# Sidebar Tabs ------------------------------------------------------------
tabDashboard <- tabItem(
  tabName = "tabDashboard",
  valueBoxOutput("myvaluebox"),
  valueBoxOutput("numberOfCustomers"),
  box(plotOutput("customerPerMonth")),
  box(plotOutput("revenuePerMonth")),
  box(plotOutput("revenuePerCustomerCohortDevelopment")),
  box(plotOutput("plotC3"))
  # DTOutput(outputId="plotTranslogRaw"),
)

tabCohortAnalysis <- tabItem(
  tabName = "tabCohortAnalysis",
  fluidRow(
    box(
      fluidRow(
        column(4, selectInput("selectSummariseVar", "Variable", choices = c("amountSpent"))),
        column(4, selectInput("selectSummariseFunc", "Function", choices = c("mean", "median", "max", "min", "sum", "n_distinct"))),
        column(4, selectInput("selectRelativeTo", "Relative To", choices = c("none", "acq", "prev")))
      ),
      plotOutput("cohortTableCustom"),
      title = "Cohort Analysis",
      solidHeader = T,
      width = 12,
      height = "850px"
    ),
    box(
      fluidRow(
        column(2,
          selectInput("lmPredictors",
                      label = "Predictors",
                      choices = c("age", "cohort", "period", "as.factor(age)", "as.factor(cohort)", "as.factor(period)"),
                      multiple = T),
          actionButton("lmRun", label = "Run")
        ),
        column(5,
          htmlOutput("lm"),
          htmlOutput("lmInsights"),
        ),
        column(5,
          plotOutput("lmFit")
        )
      ),
      title = "Simple Linear Regression",
      width = 12
    )
  )
)


# Header, Sidebar, Body ---------------------------------------------------
header <- dashboardHeader(
  
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "tabDashboard", icon = icon("dashboard")),
    menuItem("Cohort Analysis", tabName = "tabCohortAnalysis", icon = icon("th"))
  )
)

body <- dashboardBody(
  tabItems(
    tabDashboard,
    tabCohortAnalysis
  )
)


# Ui ----------------------------------------------------------------------
ui <- shinydashboard::dashboardPage(
  header = header,
  sidebar = sidebar, 
  body = body,
  title = "Hello Dashboard"
)

