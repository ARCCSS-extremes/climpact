singleStationStep1 <- function (input, output, session) {
  stationName <- reactive({strsplit(input$dataFile$name, "[_\\.]")[[1]][1]})

  observeEvent(input$dataFile, {
    # update this module's inputs 
    updateTextInput(session, "stationName", value = stationName())    
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