singleStationStep4 <- function(input, output, session, climpactUI, singleStationState) {

  output$slickRCorr <- renderSlickR({
    imgs <- list()
    if (!is.null(singleStationState$outputFolders())) {
      watchPath <- singleStationState$outputFolders()$corrdir
      imgs <- list.files(watchPath, pattern=".png", full.names = TRUE)
    }
    bottom_opts <- settings(arrows = FALSE, slidesToShow = 5, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    slickR(imgs, slideId = "slickRCorrMain", height = 600) %synch% (slickR(imgs, slideId = "slickRCorrNav", height = 100) + bottom_opts)
  })

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
      need(input$sectorPlotTitle != "", message="Please enter a plot title")
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
      pathToZipFile <- zipFiles(folderToZip(), destinationFolder = singleStationState$outputFolders()$baseFolder)
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
        HTML("<b>Correlation output</b><p>Please view the output in the following directory: <b>", folderToZip(), "</b></p>")
      } else {
        HTML("<b>Correlation output</b><p>Correlation output files ", corrZipLink(), "</p>")
      }
    }
  })

  observe(toggleState("calculateSectorCorrelation", !is.null(input$dataFile) & !is.null(input$sectorDataFile)))

  outputOptions(output, "indexCalculationError", suspendWhenHidden = FALSE)
  outputOptions(output, "sectorCorrelationError", suspendWhenHidden = FALSE)
  outputOptions(output, "sectorCorrelationLink", suspendWhenHidden = FALSE)
  outputOptions(output, "slickRCorr", suspendWhenHidden = TRUE) # otherwise renders incorrectly initially

}
