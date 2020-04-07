   # api.R

   # if you don't have this package yet
   # install.packages("httr") 
   # install.packages("dplyr")
    library(dplyr)
    # Current link on available API
    API_LINK_COVID <- "https://pomber.github.io/covid19/timeseries.json"
    API_LINK_CAPITALS <- "http://techslides.com/demos/country-capitals.json"
    curr_dir <- getwd()
    # Bad request status
    BAD_STATUS <-  c(400:406, 500,503,501,504,599,502)

    # check was list of capitals created later
    if (!file.exists("api_capitals.rda")) {
          api_response_capitals <-  httr::GET(
       API_LINK_CAPITALS
    )
        # avoid bad request
        if (!api_response_capitals$status_code %in% BAD_STATUS) { 
            api_response_capitals <-
             httr::content(api_response_capitals, as = "parsed", encoding = "UTF-8")  
               # binding data for each countries as now for each country we have separated dates
            api_response_capitals <- dplyr::bind_rows(api_response_capitals)
            api_response_capitals <-  api_response_capitals[ api_response_capitals$ContinentName != "UM",]
            api_response_capitals$CountryName[api_response_capitals$ContinentName == "US"] <- "US"

            #save data if suddenly API would be removed app is still available
            save(api_response_capitals, file = paste0(curr_dir,"/api_capitals.rda"))  
        } else {
            api_response_capitals <- api_response_capitals$status_code
        }
    }


    # assign name to our JSON object from GET request.
    api_response_covid <-  httr::GET(
       API_LINK_COVID
    )
    # avoiding HTTP error
    if (!api_response_covid$status_code %in% BAD_STATUS) {

        # we need to take only content from api_response_covid, so we will replace object
        api_response_covid <- httr::content(api_response_covid, as = "parsed", encoding = "UTF-8")

        # binding data for each countries as now for each country we have separated dates
        for (country in seq(api_response_covid)) {
        # for each country in list of countries we binding all lists together to get dataset    
            api_response_covid[[country]] <- dplyr::bind_rows(api_response_covid[[country]])
        # convert date to Date type (even though it is not important right now)    
            api_response_covid[[country]]$date <-  as.Date(api_response_covid[[country]]$date)
            api_response_covid[[country]] <-  api_response_covid[[country]] %>% arrange(date)
            api_response_covid[[country]]$CountryName <- names(api_response_covid)[country]
        }

        #save data if suddenly API would be removed app is still available
        save(api_response_covid, file = paste0(curr_dir,"/api_response_covid.rda"))
    } else {
        api_response_covid <- api_response_covid$status_code
    }