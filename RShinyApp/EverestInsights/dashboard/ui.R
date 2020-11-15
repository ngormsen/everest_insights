library(shiny)
library(shinydashboard)
library(DT)

# Sidebar Tabs ------------------------------------------------------------
tabDashboard <- tabItem(
  tabName = "tabDashboard",
  box(valueBoxOutput("myvaluebox")),
  DTOutput(outputId="plotTranslogRaw")
)

tabCohortAnalysis <- tabItem(
  tabName = "tabCohortAnalysis",
  # box(title="Number of Purchases", plotOutput("cohortTableNPurchases")),
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

