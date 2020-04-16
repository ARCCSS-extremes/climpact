singleStationStep4 <- function(input, output, session, climpactUI, singleStationState) {

  correlationCalculationStatus <- reactiveVal("Not Started")
  folderToZip <- reactiveVal("")
  corrZipLink <- reactiveVal("")

  observeEvent(input$sectorDataFile, {
    val <- strsplit(input$sectorDataFile$name, "[_\\.]")[[1]][1]
    updateTextInput(session, "y_axis_label", value = val)
  })

  # TODO -  prefer this to be one shot update when moving to step 4.
  observeEvent(singleStationState$stationName(), {
    updateTextInput(session, "sectorPlotTitle", value = singleStationState$stationName())
  })

  # Handle calculation of correlation between climate/sector data
  output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
    validate(
      need(!is.null(input$sectorDataFile), message="Please load station data"),
      need(input$sectorPlotTitle != "", message="Please enter a chart title")
    )

    if (is.null(singleStationState$dataFile())) { return("Data file not provided at Step 1 Load.") }

    params <- sectorInputParams(input$sectorDataFile, input$sectorPlotTitle, input$detrendCheck, input$y_axis_label)
    singleStationState$sectorInputParams(params)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Calculating correlation", value=0)

    correlationCalculationStatus("In Progress")

    error <- draw.correlation(progress,
                              singleStationState$dataFile()$datapath,
                              params$sectorDataFile()$datapath,
                              singleStationState$stationName(),
                              params$sectorPlotTitle(),
                              params$detrendData(),
                              params$y_axis_label(),
                              singleStationState$outputFolders()$corrdir,
                              singleStationState$outputFolders()$outinddir)

    if (error == "") {
      # zip files and get link
      folderToZip(singleStationState$outputFolders()$corrdir)
      pathToZipFile <- zipFiles(folderToZip())
      corrZipLink(getLinkFromPath(pathToZipFile, "here"))
      correlationCalculationStatus("Done")
      return("")
    } else {
      correlationCalculationStatus("Error")
      return(error)
    }
  })

  output$sectorCorrelationLink <- renderText({
    if (correlationCalculationStatus() == "Done") {
      if (isLocal) {
        HTML("<p>Please view the output in the following directory: <br /><b>", folderToZip(), "</b></p>")
      } else {
        HTML("<div class= 'alert alert-success' role='alert'>
              <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
              " Correlation output available ", corrZipLink, "</div>")
      }
    }
  })

  observe(toggleState("calculateSectorCorrelation", !is.null(input$dataFile) & !is.null(input$sectorDataFile)))

  outputOptions(output, "indexCalculationError", suspendWhenHidden = FALSE)
  outputOptions(output, "sectorCorrelationError", suspendWhenHidden = FALSE)

}
