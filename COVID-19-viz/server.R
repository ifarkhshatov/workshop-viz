# server.R
source("api.R")

library(dplyr)

# if current api_response is not working take a stored api_response
if (is.integer(api_response_covid)) {
load(paste0(getwd(),"/api_response_covid.rda"))
}

if (!exists("api_response_capitals")) {
load(paste0(getwd(),"/api_capitals.rda"))
}

for (country in seq(names(api_response_covid))) {
  api_response_covid[[country]] <-
   api_response_covid[[country]] %>% left_join(api_response_capitals, by = "CountryName")
}


library(shiny)

shinyServer(function(input, output, session) {

    output$group_stats <- renderUI({
      radioButtons(
        inputId ="group_stats",
        label = "Group data by",
        choices = c("Continent", "Country"),
        selected = "Country"
      )
    })

    output$type_stats <- renderUI({
      radioButtons(
        inputId ="type_stats",
        label = "What statistic to show",
        choices = c("confirmed", "deaths","recovered")
      )
    })

    # since there are 183 countries in the list I decided to use selectizeInput
    output$country_filter <- renderUI({
        # check is api return list or if not then not allow to proceed further
     shiny::validate(shiny::need(is.list(api_response_covid), message = "API is not working!"))

      req(input$group_stats) 
      if (input$group_stats == "Continent") {
        choices <- unique(api_response_capitals$ContinentName)
      }  else {
        # select list of countries for filter
        choices <- names(api_response_covid)
      }
        selectizeInput(
            inputId = "country_filter",
            label = "Select countries",
            choices = choices,
            multiple = TRUE) # allow to choose more than 1 country in filter
    })

    countriesStats <- eventReactive({
      input$country_filter
    input$type_stats}, {
      req(input$group_stats)
      if (input$group_stats == "Continent") {
        countries <- api_response_capitals$CountryName[api_response_capitals$ContinentName %in% input$country_filter]
 
        df <- api_response_covid[names(api_response_covid) %in% countries] 
        df <- bind_rows(df) %>% 
                group_by(date, ContinentName) %>%
                  summarise(confirmed = sum(confirmed),
                   deaths = sum(deaths), 
                   recovered = sum(recovered)) %>% ungroup() %>%
                    arrange(date)
        df <- split(df, f = df$ContinentName)
        
      } else {
      df <- api_response_covid[names(api_response_covid) %in% input$country_filter]
      df <- df 
      }
      df <- jsonlite::toJSON(list(df,input$type_stats))

    })

    # observe(print(countriesStats()))
    # sending json object of filtered countries data 
    
    observe(session$sendCustomMessage("countriesStats", countriesStats()))


    # building ui for dashboard
  output$covid_dashboard <- 
  renderUI(includeHTML('www/index.html'))
      


})