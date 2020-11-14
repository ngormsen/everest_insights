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
  box(title="Number of Purchases", plotOutput("cohortTableNPurchases"))
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

