library(shiny)
library(shinydashboard)
library(DT)

header <- dashboardHeader(
  
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Cohort Analysis", tabName = "cohortAnalysis", icon = icon("th"))
  )
)

body <- dashboardBody(
  
)



dashboard <- tabItem(
  tabName = "dashboard"
)

cohortAnalysis <- tabItem(
  tabName = "cohortAnalysis"
)



ui <- shinydashboard::dashboardPage(
  header = header,
  sidebar = sidebar, 
  body = body,
  title = "Hello Dashboard"
)


shinyApp(ui, server)