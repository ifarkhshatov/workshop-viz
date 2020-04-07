# ui.R
library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel("COVID-19 Monitoring"),
    sidebarLayout(
        # our filters will present here
        sidebarPanel(
            uiOutput("group_stats"),
            uiOutput("country_filter"),
            uiOutput("type_stats")
        ),
        # our dashboard will present here
         mainPanel(
             uiOutput("covid_dashboard")

             )
    )
)) 