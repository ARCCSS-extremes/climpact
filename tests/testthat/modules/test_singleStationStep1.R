context("Testing module - singleStationStep1")
library(testthat) # testthat used for its expectations
# requires rstudio/shiny v1.4.0.9001 or higher

#' singleStationStep1 validates user input and if invalid returns error messages
testModule(singleStationStep1, {
  #input$dataFile$name
  cat("Initially, input$stationName is NULL ... right?", is.null(input$stationName), "\n")
  expect_equal(input$stationName, NULL)
})
