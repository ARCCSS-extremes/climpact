singleStationStep2 <- function (input, output, session, parentSession, climpactUI, singleStationState) {

  output$slickr <- renderSlickR({
    # watchPath <- file.path(getwd(), "www", "assets")
    imgs <- list()
    if (!is.null(singleStationState$outputFolders())) {
      watchPath <- singleStationState$outputFolders()$outqcdir
      imgs <- list.files(watchPath, pattern=".png", full.names = TRUE)
    }
    bottom_opts <- settings(arrows = FALSE, slidesToShow = 3, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    slickR(imgs, height = 640) %synch% (slickR(imgs, height = 100) + bottom_opts)
  })

  qcPlots <- reactiveVal(list())

  qcProgressStatus <- reactiveVal("Not Started")

  output$qcStatus <- reactive({
    qcProgressStatus()
  })

  # Update UI with validation text
  output$loadDataError <- reactive({
      dataFileLoadedText <- HTML("<div class= 'alert alert-warning' role='alert'>",
        "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>",
        "<span class='sr-only'>Error:</span> Please load station data.</div>")
      if (!is.null(input$dataFile)) {
        dataFileLoadedText <- ""
      }
      return(dataFileLoadedText)
  })

  folderToZip <- reactiveVal("")
  qcZipLink <- reactiveVal("")

  output$qualityControlError <- reactive({
    errorHTML <- ""
    if (!singleStationState$isQCCompleted()) {
      # alert warning template
      errorHTML <- HTML("<br /><div class= 'alert alert-warning' role='alert'>",
        "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>",
        "<span class='sr-only'>Warning:</span> Please run quality control checks.</div>")
    } else {
      if (singleStationState$qualityControlErrors() != "") {
        # alert error template
        errorHTML <- HTML("<br /><div class= 'alert alert-danger' role='alert'>",
          "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>",
          "<span class='sr-only'>Error:</span>", singleStationState$qualityControlErrors(), "</div>")
      }
    }
    return(errorHTML)
  })

  output$qcLink <- renderText({
    if (singleStationState$isQCCompleted()) {
      localLink <- paste0("Quality control directory: <b>", folderToZip(), "</b>")
      remoteLink <- paste0("<div class= 'alert alert-info' role='alert'>",
        "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
        " Quality control files: ", qcZipLink(), "</div>")

      appendixCLink <- paste0("<a target=\"_blank\" href=", "user_guide/ClimPACT_user_guide.htm#appendixC>", "Appendix C</a>")

      HTML("<h4>Evaluate Data Quality</h4>",
        "<p>Please view the quality control output described below and carefully evaluate before continuing.",
        "<br />Refer to ", appendixCLink, " of the ", climpactUI$userGuideLink, " for help.<br />",
        localOrRemoteLink(localLink, remoteLink), "</p>")
    }
  })

  observeEvent(input$doQualityControl, {
    # input$dataFile will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with
    # 'name', 'size', 'type', and 'datapath' columns.
    # The 'datapath' column will contain the local filenames
    # where the data can be found.

    qcProgressStatus("In Progress")

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Quality Control checks", value=0, detail = "Starting...")
    singleStationState$isQCCompleted(FALSE)

    # Call into ClimPACT to do the quality control.
    out <- tryCatch({
        # create output folders to hold files for quality control and index output and plots
        baseFolder <- file.path(getwd(), "www", "output")

        # assign new outputFolders object to reactive singleStationState$outputFolders attribute
        singleStationState$outputFolders(outputFolders(baseFolder, singleStationState$stationName()))

        # apply quality control checks
        qcResult <- load_data_qc(progress, singleStationState$dataFile()$datapath,
          singleStationState$latitude(), singleStationState$longitude(),
          singleStationState$stationName(), singleStationState$startYear(),
          singleStationState$endYear(), singleStationState$outputFolders(), qcPlots)

        # capture any errors
        singleStationState$qualityControlErrors(qcResult$errors)
        singleStationState$metadata(qcResult$metadata)
        # qualityControlCheckResult(qcResult$errors)
        # capture climdex input object created
        if (qcResult$errors == "") {
          singleStationState$climdexInput(qcResult$cio)
        }

        return(qcResult$errors)
      },
      readUserFileError = function(cond) {
        return(paste("Error:", cond$message))
      },
      error = function(cond) {
        browser()
          return(paste("Error:", cond$message))
      },
      finally = {
        if (!is.null(progress)) progress$inc(0.05, detail = "Compressing outputs...")
        qcProgressStatus("Done")
        folderToZip(singleStationState$outputFolders()$outqcdir)
        pathToZipFile <- zipFiles(folderToZip(), destinationFolder = singleStationState$outputFolders()$baseFolder)
        qcZipLink(getLinkFromPath(pathToZipFile, "here"))
        singleStationState$isQCCompleted(TRUE)
      }
    )
    return(out)
  })

  # TODO respond in other modules to event in this module
  # updateTextInput(session, "plotTitle", value=val)

  # session$sendCustomMessage("enableTab", "process_single_station_step_3")

  observeEvent(input$btn_next_step_2, {
    tabName <- "process_single_station_step_3"
    session$sendCustomMessage("enableTab", tabName)
    updateTabsetPanel(parentSession, "process_single_station", selected = tabName)
  })

  # ensure client-side javascript will inspect qcLink element
  outputOptions(output, "qcLink", suspendWhenHidden=FALSE)
  outputOptions(output, "qcStatus", suspendWhenHidden=FALSE)
  outputOptions(output, "slickr", suspendWhenHidden=FALSE)

  return(list(singleStationState = singleStationState))
}
