singleStationStep4 <- function(input, output, session, climpactUI, singleStationState) {
  # Handle calculation of correlation between climate/sector data
  output$sectorCorrelationStatus <- reactive({
    # trigger refresh on update
    singleStationState$isQCCompleted()
    singleStationState$indexCalculationStatus()
    singleStationState$correlationCalculationStatus()
  })
  outputOptions(output, "sectorCorrelationStatus", suspendWhenHidden = FALSE)

  output$sectorCorrelationError <- reactive({
    # trigger refresh on update
    singleStationState$isQCCompleted()
    singleStationState$indexCalculationStatus()
    singleStationState$correlationCalculationErrors()
  })
  outputOptions(output, "sectorCorrelationError", suspendWhenHidden = FALSE)

  singleStationState$correlationCalculationStatus("Not Started")
  folderToZip <- reactiveVal("")
  corrZipLink <- reactiveVal("")

  output$slickRCorr <- renderSlickR({
    imgs <- list()
    if (!is.null(singleStationState$outputFolders())) {
      watchPath <- singleStationState$outputFolders()$corrdir
      imgs <- list.files(watchPath, pattern=".png", full.names = TRUE)
    }
    bottom_opts <- settings(arrows = FALSE, slidesToShow = 5, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    slickR(imgs, slideId = "slickRCorrMain", height = 600) %synch% (slickR(imgs, slideId = "slickRCorrNav", height = 100) + bottom_opts)
  })
  outputOptions(output, "slickRCorr", suspendWhenHidden = TRUE) # otherwise renders incorrectly initially


  observeEvent(input$sectorDataFile, {
    val <- strsplit(input$sectorDataFile$name, "[_\\.]")[[1]][1]
    updateTextInput(session, "y_axis_label", value = val)
    singleStationState$correlationCalculationStatus("Not Started")
  })

  observeEvent(singleStationState$stationName(), {
    updateTextInput(session, "sectorPlotTitle", value = singleStationState$stationName())
  })


  observeEvent(input$calculateSectorCorrelation, {
    validate(
      need(!is.null(input$sectorDataFile), message="Please load station data"),
      need(input$sectorPlotTitle != "", message="Please enter a plot title")
    )

    singleStationState$correlationCalculationStatus("In Progress")

    if (is.null(singleStationState$dataFile())) {
      singleStationState$correlationCalculationStatus("Done")
      singleStationState$correlationCalculationErrors("Data file not provided at Step 1 Load.")
    }

    params <- sectorInputParams(input$sectorDataFile, input$sectorPlotTitle, input$detrendCheck, input$y_axis_label)
    singleStationState$sectorInputParams(params)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Calculating correlation", value=0)

    errors <- draw.correlation(progress,
                              singleStationState$dataFile()$datapath,
                              params$sectorDataFile()$datapath,
                              singleStationState$stationName(),
                              params$sectorPlotTitle(),
                              params$detrendData(),
                              params$y_axis_label(),
                              singleStationState$outputFolders()$corrdir,
                              singleStationState$outputFolders()$outinddir)

    if (errors == "") {
      # zip files and get link
      folderToZip(singleStationState$outputFolders()$corrdir)
      pathToZipFile <- zipFiles(folderToZip(), destinationFolder = singleStationState$outputFolders()$baseFolder)
      corrZipLink(getLinkFromPath(pathToZipFile, "here"))
    }
    singleStationState$correlationCalculationErrors(errors)
    singleStationState$correlationCalculationStatus("Done")
  })

  output$sectorCorrelationLinkTop <- renderText(getLinkForTopMiddle())
  output$sectorCorrelationLinkMiddle <- renderText(getLinkForTopMiddle())

  getLinkForTopMiddle <- function() {
    if (singleStationState$correlationCalculationStatus() == "Done") {
      if (isLocal) {
        HTML("<p>Please view the output in the following directory: <b>", folderToZip(), "</b></p>")
      } else {
        HTML("<p>Correlation output files ", corrZipLink(), "</p>")
      }
    } else {
      ""
    }
  }

  output$sectorCorrelationLink <- renderText({
    if (singleStationState$correlationCalculationStatus() == "Done") {
      if (isLocal) {
        HTML("<b>Correlation output</b><p>Please view the output in the following directory: <b>", folderToZip(), "</b></p>")
      } else {
        HTML("<b>Correlation output</b><p>Correlation output files ", corrZipLink(), "</p>")
      }
    } else {
      ""
    }
  })
  outputOptions(output, "sectorCorrelationLink", suspendWhenHidden = FALSE)

  observe(toggleState("calculateSectorCorrelation", !is.null(input$dataFile) & !is.null(input$sectorDataFile)))
}
