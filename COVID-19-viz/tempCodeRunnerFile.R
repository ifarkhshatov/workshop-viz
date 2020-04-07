   # api.R

   # if you don't have this package yet
   # install.packages("httr") 
   # install.packages("dplyr")

    # Current link on available API
    API_LINK <- "https://pomber.github.io/covid19/timeseries.json"

    # assign name to our JSON object from GET request.
    api_response <-  httr::GET(
       API_LINK
    )
    # avoiding HTTP error
    if (!api_response$status_code %in% c(400:406, 500,503,501,504,599,502)) {

    # we need to take only content from api_response, so we will replace object
    api_response <- httr::content(api_response, as = "parsed", encoding = "UTF-8")

    # binding data for each countries as now for each country we have separated dates
    for (country in seq(api_response)) {
        api_response[[country]] <- dplyr::bind_rows(api_response[[country]])
    }
        
    curr_dir <- getwd()
    #save data if suddenly API would be removed app is still available
    save(api_response, file = paste0(curr_dir,"/api_response.rda"))
    } else {
        api_response <- api_response$status_code
    }