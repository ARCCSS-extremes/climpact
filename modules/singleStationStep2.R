singleStationStep2 <- function (input, output, session, parentSession, climpactUI, singleStationState) {

  output$slickRQC <- renderSlickR({
    imgs <- list()
    if (!is.null(singleStationState$outputFolders())) {
      watchPath <- singleStationState$outputFolders()$outqcdir
      imgs <- list.files(watchPath, pattern=".png", full.names = TRUE)
    }
    bottom_opts <- settings(arrows = FALSE, slidesToShow = 5, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    slickR(imgs, slideId = "slickRQCMain", height = 600) %synch% (slickR(imgs, slideId = "slickRQCNav", height = 100) + bottom_opts)
  })

  qcProgressStatus <- reactiveVal("Not Started")
  output$qcStatus <- reactive({
    input$dataFile # trigger update
    if (singleStationState$isQCCompleted() == "FALSE") {
      qcProgressStatus("Not Started")
    } else {
      qcProgressStatus("Done")
    }
    qcProgressStatus()
  })

  # Update UI with validation text
  output$loadDataError <- reactive({
      errorDataFileNotLoaded <- HTML("<div class= 'alert alert-info' role='alert'>",
        "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>",
        "<span class='sr-only'>Info</span> Please load station data.</div>")
      if (!is.null(input$dataFile)) {
        errorDataFileNotLoaded <- ""
      }
      return(errorDataFileNotLoaded)
  })

  folderToZip <- reactiveVal("")
  qcZipLink <- reactiveVal("")

  output$qualityControlError <- reactive({
    input$dataFile # trigger update
    errorHTML <- ""
    if (!singleStationState$isQCCompleted()) {
      # alert warning template
      errorHTML <- HTML("<br /><div class= 'alert alert-info' role='alert'>",
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
      localLink <- paste0("<b> Quality control directory: ", folderToZip(), "</b>")
      remoteLink <- paste0("<b> Quality control files: ", qcZipLink(), "<\b>")

      appendixCLink <- paste0("<a target=\"_blank\" href=", "user_guide/ClimPACT_user_guide.htm#appendixC>", "Appendix C</a>")

      HTML("<b>Evaluate Data Quality</b>",
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
    disable("doQualityControl")

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
        qcResult <- load_data_qc(progress, 1, singleStationState$dataFile()$datapath,
          singleStationState$latitude(), singleStationState$longitude(),
          singleStationState$stationName(), singleStationState$startYear(),
          singleStationState$endYear(), singleStationState$outputFolders())

        # capture any errors
        singleStationState$qualityControlErrors(qcResult$errors)
        singleStationState$metadata(qcResult$metadata)
        # qualityControlCheckResult(qcResult$errors)
        # capture climdex input object created
        if (qcResult$errors == "") {
          singleStationState$climdexInput(qcResult$cio)
        } else {
          print(qcResult$errors)
        }

        return(qcResult$errors)
      },
      readUserFileError = function(cond) {
        return(paste("Error:", cond$message))
      },
      error = function(cond) {
          return(paste("Error:", cond$message))
      },
      finally = {
        if (!is.null(progress)) progress$inc(0.05, detail = "Compressing outputs...")
        enable("doQualityControl")
        singleStationState$isQCCompleted(TRUE)
        if (!is.null(singleStationState) && !is.null(singleStationState$outputFolders())) {
          folderToZip(singleStationState$outputFolders()$outqcdir)
          pathToZipFile <- zipFiles(folderToZip(), destinationFolder = singleStationState$outputFolders()$baseFolder)
          qcZipLink(getLinkFromPath(pathToZipFile, "here"))
        }
      }
    )
    return(out)
  })

  observeEvent(input$btn_next_step_2, {
    tabName <- "process_single_station_step_3"
    session$sendCustomMessage("enableTab", tabName)
    updateTabsetPanel(parentSession, "process_single_station", selected = tabName)
  })

  # ensure client-side javascript will inspect qcLink element
  outputOptions(output, "qcLink", suspendWhenHidden = FALSE)
  outputOptions(output, "qcStatus", suspendWhenHidden = FALSE)
  outputOptions(output, "loadDataError", suspendWhenHidden = FALSE)
  outputOptions(output, "slickRQC", suspendWhenHidden = TRUE)

  observe(toggleState("btn_next_step_2", singleStationState$isQCCompleted() && singleStationState$qualityControlErrors() == ""))
  session$sendCustomMessage("enableTab", "process_single_station_step_3")
  return(list(singleStationState = singleStationState))
}
