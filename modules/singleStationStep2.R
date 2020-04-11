singleStationStep2 <- function (input, output, session, step1, uiHelper) {
  qcZipFileLink <- reactiveVal("")

  # Update UI with validation text
  output$dataFileLoadedWarning <- reactive({
      dataFileLoadedText <- ""
      if (is.null(step1$dataFile())) {
        dataFileLoadedText <- HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span> Please load a dataset</div>")
      }
      else {
        dataFileLoadedText <- ""
      }
      return (dataFileLoadedText)
  })

  folderToZip <- ""
  qcZipLink <- reactiveVal("")
  isQCOutputReady <- reactiveVal(FALSE)

  output$qcLink <- renderText({
      if (!is.null(step1$dataFile()) && isQCOutputReady()) {
      # zip files and get link
      localLink <- paste0("Quality control directory: ", folderToZip)
      remoteLink <- paste0("<div class= 'alert alert-info' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                            " Quality control files ", qcZipLink(),"</div>")
      appendixCLink <- paste0("<a target=\"_blank\" href=", "user_guide/ClimPACT_user_guide.htm#appendixC>", "Appendix C</a>")
      HTML(paste0("Please view the quality control output described below and carefully evaluate before continuing.",
                  "<br />Refer to ", appendixCLink, " of the ", uiHelper$userGuideLink, " for help.<br />", localOrRemoteLink(localLink, remoteLink)))
      }
  })

  outputFolders <- ""

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


    source("server/climpact.GUI-functions.r")
    source("server/quality_control_checks.r")
    source("server/quality_control/quality_control.r")
    source("models/outputFolders.R", local = TRUE)

    # Call into ClimPACT to do the quality control.
    out <- tryCatch({
        baseFolder <- file.path(getwd(), "www", "output")
        outputFolders <- outputFolders(baseFolder, step1$stationName())
        qc.errors <- load_data_qc(progress, step1$dataFile()$datapath,
                                  step1$latitude(), step1$longitude(),
                                  step1$stationName(), step1$startYear(),
                                  step1$endYear(), outputFolders)
        return (qc.errors)
      },
      readUserFileError = function(cond) {
        return(paste("Error:", cond$message))
      },
      error = function(cond) {
        browser()
          return(paste("Error:", cond$message))
      },
      finally = {
        pathToZipFile <- zipFiles(outputFolders$outqcdir)
        link <- getLinkFromPath(pathToZipFile, "here")
        qcZipLink(link)
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
        errorHTML <- HTML("<div class= 'alert alert-danger' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span>", qualityControlCheckResult(), "</div>")
      }
      return(errorHTML)
    })

  return(list(outputFolders = outputFolders))


  # TODO respond in other modules to event in this module
  # updateTextInput(session, "plotTitle", value=val)
  # session$sendCustomMessage("enableTab", "process_single_station_step_2")
}
