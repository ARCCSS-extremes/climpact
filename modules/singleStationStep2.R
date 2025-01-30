singleStationStep2 <- function (input, output, session, parentSession, climpactUI, singleStationState) {

  singleStationState$iqr_threshold_temp <- reactive({ input$iqr_threshold_temp })
  singleStationState$iqr_threshold_prec <- reactive({ input$iqr_threshold_prec })
  singleStationState$prec_threshold <- reactive({ input$prec_threshold })
  singleStationState$temp_threshold <- reactive({ input$temp_threshold })
  singleStationState$no_variability_threshold <- reactive({ input$no_variability_threshold })
  singleStationState$temp_change_threshold <- reactive({ input$temp_change_threshold })

  output$slickRQC <- renderSlickR({
    imgs(list())
    if (qcProgressStatus() == "Done" && (!is.null(singleStationState$outputFolders()))) {
      watchPath <- singleStationState$outputFolders()$outqcdir
      imgs(list.files(watchPath, pattern=".png", full.names = TRUE))
    }
    bottom_opts <- settings(slidesToShow = 1, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    sl <- slickR(imgs(), slideId = "slickRQCMain", height = 600) + bottom_opts
    return(sl)
  })

  imgs <- reactiveVal(list())
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
  output$qcLinkTop <- renderText(HTML(getQCLink()))
  output$qcLink <- renderText(getQCEvalText())

  getQCEvalText <- function() {
    if (singleStationState$isQCCompleted()) {

      appendixCLink <- paste0("<a target=\"_blank\" href=", "https://github.com/ARCCSS-extremes/climpact/blob/master/www/user_guide/Climpact_user_guide.md#outputstation>", "section 6</a>")

      HTML("<b>Evaluate Data Quality</b>",
        "<p>Please view the quality control output described below and carefully evaluate before continuing.",
        "<br />Refer to ", appendixCLink, " of the ", climpactUI$userGuideLink, " for help.<br />",
        getQCLink(), "</p>")
    }
  }
  getQCLink <- function() {
    if (singleStationState$isQCCompleted()) {
      localLink <- paste0("<b> Quality control directory: ", folderToZip(), "</b>")
      remoteLink <- paste0("<b> Quality control files: ", qcZipLink(), "</b>")
      return(localOrRemoteLink(localLink, remoteLink))
    }
  }

  warningDialog_baseperiod <- function(msg) {
  modalDialog(title = "Warning",
    HTML(print(msg)),
    footer = tagList(modalButton("I understand"))
  )
}

  observeEvent(input$doQualityControl, {
    # input$dataFile will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with
    # 'name', 'size', 'type', and 'datapath' columns.
    # The 'datapath' column will contain the local filenames
    # where the data can be found.
    disable("doQualityControl")

    qcProgressStatus("In Progress")
    print(singleStationState$iqr_threshold_temp())

    progress <- shiny::Progress$new()
    progress$set(message="Quality Control checks", value=0, detail = "Starting...")
    singleStationState$isQCCompleted(FALSE)

    # Call into Climpact to do the quality control.
    out <- tryCatch({
        # create output folders to hold files for quality control and index output and plots
        # if this is a remote instance then put output in a randomly named folder to avoid overwriting among users
        if (isLocal == FALSE) {
          random_dir <- paste0(sample(LETTERS, 10, TRUE),collapse="")
          baseFolder <- file.path(getwd(), "www", "output", random_dir)
        } else {
          baseFolder <- file.path(getwd(), "www", "output")
        }

        # assign new outputFolders object to reactive singleStationState$outputFolders attribute
        singleStationState$outputFolders(outputFolders(baseFolder, singleStationState$stationName()))

        # apply quality control checks
        qcResult <- load_data_qc(progress, 1, singleStationState$dataFile()$datapath,
          singleStationState$latitude(), singleStationState$longitude(),
          singleStationState$stationName(), singleStationState$startYear(),
          singleStationState$endYear(), singleStationState$outputFolders(),
          singleStationState$iqr_threshold_temp(), singleStationState$iqr_threshold_prec(),
          singleStationState$prec_threshold(), singleStationState$temp_threshold(), 
          singleStationState$no_variability_threshold(), singleStationState$temp_change_threshold())

        # capture any errors
        singleStationState$qualityControlErrors(qcResult$errors)
        singleStationState$metadata(qcResult$metadata)

        if (qcResult$errors == "") {
          if (qcResult$warnings != "") {
            showModal(warningDialog_baseperiod(qcResult$warnings))
          }
          singleStationState$climdexInput(qcResult$cio)
        } else {
          print(qcResult$errors)
        }
	on.exit(progress$close()) 	# place on.exit here so that errors that aren't manually caught by QC (like base periods larger than the data) are left on-screen for users to see.
        return(qcResult$errors)
      },
      readUserFileError = function(cond) {
	progress$set(message=cond$message, value=0, detail = paste("ERROR: ",cond$message))
	print(paste("Error:", cond$message))
        return(paste("Error:", cond$message))
      },
      error = function(cond) {
	  progress$set(message=cond$message, value=0, detail = paste("ERROR: ",cond$message))
          print(paste("Error:", cond$message))
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
        qcProgressStatus("Done")
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
  outputOptions(output, "slickRQC", suspendWhenHidden = FALSE)

  observe(toggleState("btn_next_step_2", singleStationState$isQCCompleted() && singleStationState$qualityControlErrors() == ""))
  session$sendCustomMessage("enableTab", "process_single_station_step_3")
  return(list(singleStationState = singleStationState))
}
