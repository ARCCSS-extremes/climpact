singleStationStep2 <- function (input, output, session, climpactUI, singleStationState) {

  # Update UI with validation text
  output$loadDataError <- reactive({
      dataFileLoadedText <- "<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span> Please load a dataset</div>"
      if (!is.null(input$dataFile)) {
        dataFileLoadedText <- ""
      }
      return (dataFileLoadedText)
  })

  folderToZip <- reactiveVal("")
  qcZipLink <- reactiveVal("")
  isQCOutputReady <- reactiveVal(FALSE)

  output$qcLink <- renderText({
    if (isQCOutputReady()) {
      # zip files and get link
      localLink <- paste0("Quality control directory: ", folderToZip())
      remoteLink <- paste0("<div class= 'alert alert-info' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                            " Quality control files: ", qcZipLink(),"</div>")
      appendixCLink <- paste0("<a target=\"_blank\" href=", "user_guide/ClimPACT_user_guide.htm#appendixC>", "Appendix C</a>")
      HTML(paste0("Please view the quality control output described below and carefully evaluate before continuing.",
                  "<br />Refer to ", appendixCLink, " of the ", climpactUI$userGuideLink, " for help.<br />", localOrRemoteLink(localLink, remoteLink)))
    }
  })

  observeEvent(input$doQualityControl, {

    # input$dataFile will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Quality Control checks", value=0, detail = "Starting...")
    isQCOutputReady(FALSE)

    # Call into ClimPACT to do the quality control.
    out <- tryCatch({
        # create output folders to hold files for quality control and index output and plots
        baseFolder <- file.path(getwd(), "www", "output")
        singleStationState$outputFolders <- outputFolders(baseFolder, singleStationState$stationName())
        # apply quality control checks
        qcResult <- load_data_qc(progress, singleStationState$dataFile()$datapath,
                                  singleStationState$latitude(), singleStationState$longitude(),
                                  singleStationState$stationName(), singleStationState$startYear(),
                                  singleStationState$endYear(), singleStationState$outputFolders)
        return (qcResult$qcErrors)
      },
      readUserFileError = function(cond) {
        return(paste("Error:", cond$message))
      },
      error = function(cond) {
        browser()
          return(paste("Error:", cond$message))
      },
      finally = {
        # capture any errors
        singleStationState$qualityControlErrors = qcResult$errors
        qualityControlCheckResult(qcResult$errors)
        # capture climdex input object created
        if (qcResult$errors == "") { singleStationState$climdexInput = qcResult$cio }

        folderToZip(singleStationState$outputFolders$outqcdir)
        pathToZipFile <- zipFiles(folderToZip())
        qcZipLink(getLinkFromPath(pathToZipFile, "here"))
        isQCOutputReady(TRUE)
      }
    )
    browser()
    return(out)
  })

  qualityControlCheckResult <- reactiveVal("")
    # Quality control processing has been requested by the user.
  output$qualityControlError <- reactive ({
    errorHTML <- ""
    if (qualityControlCheckResult() != "") {
      errorHTML <- HTML("<br /><div class= 'alert alert-danger' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span>", qualityControlCheckResult(), "</div>")
    }
    return(errorHTML)
  })

  outputOptions(output, "qcLink", suspendWhenHidden=FALSE)

  return(list(singleStationState = singleStationState))


  # TODO respond in other modules to event in this module
  # updateTextInput(session, "plotTitle", value=val)
  # session$sendCustomMessage("enableTab", "process_single_station_step_2")
}
