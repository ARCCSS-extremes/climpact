singleStationStep1 <- function (input, output, session, parentSession, singleStationState) {

  stationName <- reactive({
    file_parts <- strsplit(input$dataFile$name, "\\.")[[1]]
    stripped <- substr(input$dataFile$name, start = 1, stop = nchar(input$dataFile$name) - nchar(file_parts[length(file_parts)]) - 1)
  })

  observeEvent(input$dataFile, {
    # reset the work flow
    updateTextInput(session, "stationName", value = stationName())
    singleStationState$isQCCompleted(FALSE)
    singleStationState$qualityControlErrors("")
    singleStationState$indexCalculationStatus("Not Started")
    singleStationState$indexCalculationErrors("")
    singleStationState$correlationCalculationStatus("Not Started")
    singleStationState$correlationCalculationErrors("")
  })

  # Validation, expression works, so we can reuse these elsewhere in the app
  latitudeValidation <- function() {
    input$stationLat >= -90 && input$stationLat <= 90
  }
  longitudeValidation <- function() {
    input$stationLon >= -180 && input$stationLon <= 180
  }

  stationLatCheck <- reactive({
      validate(need(latitudeValidation(), "Latitude must be between -90 and 90."))
  })

  stationLonCheck <- reactive({
      validate(need(longitudeValidation(), "Longitude must be between -180 and 180"))
  })

  stationNameCheck <- reactive({
      validate(need(input$stationName != "", message = "Please enter a station name"))
      input$stationName
  })

  singleStationState$dataFile <- reactive({ input$dataFile })
  singleStationState$stationName <- reactive({ input$stationName })
  singleStationState$latitude <- reactive({ input$stationLat })
  singleStationState$longitude <- reactive({ input$stationLon })
  singleStationState$startYear <- reactive({ input$startYear })
  singleStationState$endYear <- reactive({ input$endYear })

  observeEvent(input$btn_next_step_1, {
    tabName <- "process_single_station_step_2"
    session$sendCustomMessage("enableTab", tabName)
    updateTabsetPanel(parentSession, "process_single_station", selected = tabName)
  })

  observe(toggleState("btn_next_step_1", (!is.null(input$dataFile) && latitudeValidation() && longitudeValidation())))
  session$sendCustomMessage("enableTab", "process_single_station_step_2")
  return(list(singleStationState = singleStationState))
}
