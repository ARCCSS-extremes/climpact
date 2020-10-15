griddedStep2 <- function(input, output, session, climpactUI) {

  # observeEvent(input$selectOutDirThresh,{
  #   gridOutDirThresh <<- dchoose()
  #   output$outDirPrintThresh <- renderText({print(paste("Output directory: ",gridOutDirThresh,sep=""))})
  # })

  infoDialog <- function() {
    ns <- session$ns
    modalDialog(title = "Important message",
        tags$p("Calculating gridded thresholds usually takes an hour or more, ",
        "depending on how large your dataset is, how fast your computer is and how many cores you choose."),
        tags$p("Do not close the ClimPACT browser window until this process is complete. ",
          "You will see \"Done\" printed below the \"Calculate NetCDF thresholds\" button when ClimPACT is finished."),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("proceedGriddedThresh"), "Calculate Thresholds")
        )
      )
  }
  warningDialog <- function(msg) {
    ns <- session$ns
    modalDialog(title = "Warning",
      HTML("There was a problem processing your gridded data. ",
      print(paste0("R error message was: ", msg))),
      footer = tagList(modalButton("OK"))
    )
  }
  errorDialog <- function(msg) {
    ns <- session$ns
    modalDialog(title = "Error",
      HTML("There was a problem processing your gridded data.",
          print(paste0("R error message was: ", msg))),
      footer = tagList(modalButton("OK"))
    )
  }

  observeEvent(input$calculateGriddedThresholds, {
    validate(
      need(!is.null(input$dataFilesThresh), message = "Please specify input file(s)."),
      need(input$prNameThresh, message = "Please specify the name of the precipitation variable as it is recorded in its netCDF file"),
      need(input$txNameThresh, message = "Please specify the name of the maximum temperature variable as it is recorded in its netCDF file."),
      need(input$tnNameThresh, message = "Please specify the name of the minimum temperature variable as it is recorded in its netCDF file."),
      need(input$outputFileNameThresh, message = "Please specify an output file name."),
      need(input$instituteIDThresh, input$instituteNameThresh, message = "Please specify institute name and ID (usually an abbreviation)."),
      need(input$baseStartThresh, input$baseEndThresh, message = "Please specify start and end year of base period (e.g. 1990 and 2010)"),
      need(input$nCoresThresh > 0,
        message = paste0("Number of cores is less than or equal to 0.", " Number of cores must be between 1 and ", detectCores())),
      need(input$nCoresThresh <= detectCores(),
        message = paste0("Number of cores is greater than ", detectCores(), ". Number of cores must be between 1 and ", detectCores()))
    )
    showModal(infoDialog())
  })

  thresholdCalculationStatus <- reactiveVal("Not Started")
  output$thresholdCalculationStatusText <- renderText({
    thresholdCalculationStatus()
  })

  observeEvent(input$proceedGriddedThresh, {
    disable("calculateGriddedThresholds")
    removeModal()

    params <- ncdfThresholdInputParams(input$prNameThresh,
                input$txNameThresh,
                input$tnNameThresh,
                input$outputFileNameThresh,
                input$instituteIDThresh,
                input$instituteNameThresh,
                input$baseStartThresh,
                input$baseEndThresh,
                input$nCoresThresh)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Calculating ncdf thresholds", value = 0)

    thresholdCalculationStatus("In Progress")
    outputFolder <- reactiveVal(file.path(getwd(), "www", "output", paste0(input$instituteIDThresh, "_thres")))
    outputFilePath <- reactiveVal(file.path(outputFolder(), input$outputFileNameThresh))
    errorOccurred <- reactiveVal(FALSE)

    out <- tryCatch({
      # Create folder if it doesn't exist, hide warning if it exists already
      dir.create(outputFolder(), showWarnings = FALSE)
      ncdfThresholdsCalc(progress, input$dataFilesThresh$datapath, outputFilePath(), params)
    },
    error = function(cond) {
      errorOccurred(TRUE)
      showModal(errorDialog(cond$message))
      return(paste0("Error occurred: ", cond$message))
    },
    warning = function(cond) {
      showModal(warningDialog(cond$message))
      return(paste0("Warning: ", cond$message))
    },
    finally = {
      thresholdCalculationStatus("Done")
    })

    output$ncGriddedThreshDone <- renderUI({
      if (thresholdCalculationStatus() == "Done") {
        if (!errorOccurred()) {
          HTML("<b>NetCDF Threshold calculations complete</b><p>Please view the output at: <b>", outputFilePath(), "</b></p>")
        } else {
          HTML("<b>An error occurred:</b><p>", out, "</p>")
        }
      } else if (thresholdCalculationStatus() == "In Progress") {
        # would like to put output from create.thresholds.from.file() here...
        HTML("<b>Calculating thresholds...</b>")
      } else {
        ""
      }
    })
    enable("calculateGriddedThresholds")
  })

  library(climdex.pcic.ncdf)

  ncdfThresholdsCalc <- function(progress, griddedFiles, outputFilePath, params) {
    # Call the 'create.thresholds.from.files' function from the modified climdex.pcic.ncdf package
    # to calculate thresholds, using data and parameters provided by the user.

    # request messages to be returned
    verbose <- TRUE

    create.thresholds.from.file(griddedFiles,
      outputFilePath,
      params$authorData,
      variable.name.map   = params$variableNameMap,
      base.range          = params$baseRange,
      parallel            = params$numCores,
      verbose             = verbose,
      fclimdex.compatible = params$fClimdexCompatible,
      root.dir            = NULL
    )
  }
  observe(toggleState("calculateGriddedThresholds", !is.null(input$dataFilesThresh)
    & (input$prNameThresh != "")
    & (input$txNameThresh != "")
    & (input$tnNameThresh != "")
    & (input$outputFileNameThresh != "")
    & (input$instituteIDThresh != "")
    & (input$instituteNameThresh != "")
    & (input$baseStartThresh != "")
    & (input$baseEndThresh != "")
    & (input$nCoresThresh != "")))
  outputOptions(output, "thresholdCalculationStatusText", suspendWhenHidden = FALSE)
}
