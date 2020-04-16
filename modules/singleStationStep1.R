singleStationStep1 <- function (input, output, session, parentSession, singleStationState) {
  stationName <- reactive({
    strsplit(input$dataFile$name, "[_\\.]")[[1]][1]
  })

  observeEvent(input$dataFile, {
    updateTextInput(session, "stationName", value = stationName())
  })

  # Validation, if expression works then can reuse validation logic, otherwise duplicate...
  latitudeExpr <- function() {
    input$stationLat >= -90 && input$stationLat <= 90
  }

  stationLatCheck <- reactive({
      validate(need(latitudeExpr(), "Latitude must be between -90 and 90."))
      input$stationLat
  })

  stationLonCheck <- reactive({
      validate(need(input$stationLon >= -180 && input$stationLon <= 180, "Longitude must be between -180 and 180"))
      input$stationLon
  })

  stationNameCheck <- reactive({
      validate(need(input$stationName != "", message="Please enter a station name"))
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

  # observe(toggleState("btn_next_step_1", !is.null(input$dataFile)))
  # session$sendCustomMessage("enableTab", "process_single_station_step_2")

  # TODO respond in other modules to event in this module
  # updateTextInput(session, "plotTitle", value=val)

  # must use = not <- to get named values in list()
  return(list(singleStationState = singleStationState))
}
