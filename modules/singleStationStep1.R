singleStationStep1 <- function (input, output, session) {
  stationName <- reactive({strsplit(input$dataFile$name, "[_\\.]")[[1]][1]})

  observeEvent(input$dataFile, {
    updateTextInput(session, "stationName", value = stationName())         
  })
  
  # Validation, if expression works then can reuse validation logic, otherwise duplicate...
  latitudeExpr <- function() { input$stationLat >= -90 && input$stationLat <= 90 }
  stationLatCheck <- reactive({
      validate(
          need(latitudeExpr(), "Latitude must be between -90 and 90.")
      )
      input$stationLat
  })

  stationLonCheck <- reactive({
      validate(
          need(input$stationLon >= -180 && input$stationLon <= 180, "Longitude must be between -180 and 180")
      )
      input$stationLon
  })

  stationNameCheck <- reactive({
      validate(
          need(input$stationName != "", message="Please enter a station name")
      )
      input$stationName
  })

  # must use = below and not <- to get named values in list()
  return(
    list(
      dataFile = reactive({input$dataFile}),
      stationName = stationName,
      latitude = reactive({input$stationLat}),
      longitude = reactive({input$stationLon}),
      startYear = reactive({input$startYear}),
      endYear = reactive({input$endYear})
    )
  )

  # TODO respond in other modules to event in this module 
  # updateTextInput(session, "plotTitle", value=val)        
  # session$sendCustomMessage("enableTab", "process_single_station_step_2")
}