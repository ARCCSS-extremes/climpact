griddedStep1 <- function(input, output, session, climpactUI) {

  infoDialog <- function() {
    ns <- session$ns
    modalDialog(title = "Important message",
        tags$p("Calculating gridded indices usually takes many hours, depending on how large your dataset is,",
          " how fast your computer is and how many cores you choose."),
        tags$p("Do not close the ClimPACT browser window until this process is complete. ",
          "You will see \"Done\" printed below the \"Calculate NetCDF indices\" button when ClimPACT is finished."),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("proceedGridded"), "Calculate Indices")
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

  observeEvent(input$calculateGriddedIndices, {
    validate(
        need(!is.null(input$dataFiles), message = "Please specify input file(s)."),
        need(input$prName, message = "Please specify the name of the precipitation variable as it is recorded in its netCDF file"),
        need(input$txName, message = "Please specify the name of the maximum temperature variable as it is recorded in its netCDF file."),
        need(input$tnName, message = "Please specify the name of the minimum temperature variable as it is recorded in its netCDF file."),
        need(input$outputFileNamePattern, message = "Please specify an output filename convention."),
        need(input$instituteID, input$instituteName, message = "Please specify institute name and ID (usually an abbreviation)."),
        need(input$baseStart, input$baseEnd, message = "Please specify start and end year of base period (e.g. 1990)"),
        need(input$nCores, message = "Please specify number of cores to use."),
        need(input$maxVals, message = "Please specify max values.")
      )
      showModal(infoDialog())
  })

  ncdfCalculationStatus <- reactiveVal("Not Started")
  output$ncdfCalculationStatusText <- renderText({
    ncdfCalculationStatus()
  })

  observeEvent(input$proceedGridded, {
    disable("calculateGriddedIndices")
    removeModal()

    params <- ncdfInputParams(input$prName,
                input$txName,
                input$tnName,
                input$outputFileNamePattern,
                input$instituteID,
                input$instituteName,
                input$baseStart,
                input$baseEnd,
                input$indicesToCalculate,
                input$ehfDefinition,
                input$nCores,
                input$maxVals)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Calculating ncdf indices", value = 0)

    ncdfCalculationStatus("In Progress")

    outputFolder <- reactiveVal(file.path(getwd(), "www", "output", paste0(input$instituteID, "_ncdf")))
    errorOccurred <- reactiveVal(FALSE)

    out <- tryCatch({
      # Create folder if it doesn't exist, hide warning if it exists already
      dir.create(outputFolder(), showWarnings = FALSE)
      # Calculate gridded indices
      ncdfCalc(progress, input$dataFiles$datapath, input$thresholdFiles$datapath, outputFolder(), params)
    },
    error = function(cond) {
      errorOccurred(TRUE)
      showModal(errorDialog(cond$message))
      return(paste0("Error occurred: ", cond$message))
    },
    # warning = function(cond) {
    #   showModal(warningDialog(cond$message))
    #   return(paste0("Warning: ", cond$message))
    # },
    finally = {
      ncdfCalculationStatus("Done")
    })

    output$ncGriddedDone <- renderUI({
      if (ncdfCalculationStatus() == "Done") {
        if (!errorOccurred()) {
          HTML("<b>NetCDF indices calculations complete</b><p>Please view the output in the following directory: <b>", outputFolder(), "</b></p>")
        } else {
          HTML("<b>An error occurred:</b><p>", out, "</p>")
        }
      } else if (ncdfCalculationStatus() == "In Progress") {
        # would like to put output from create.indices.from.file() here...
        HTML("<b>Calculating indices...</b>")
      } else {
        ""
      }
    })
    enable("calculateGriddedIndices")
  })

  library(climdex.pcic.ncdf)

  ncdfCalc <- function(progress, griddedFiles, thresholdFiles, outputFolder, params) {
    # Call the 'create.indices.from.files' function from the modified climdex.pcic.ncdf package
    # to calculate ETCCDI, ET-SCI and other indices, using data and parameters provided by the user.
    # Note even when using a threshold file, the base.range parameter must still be specified accurately.
    create.indices.from.files(
      root.dir                  = NULL,
      input.files               = griddedFiles,
      out.dir                   = outputFolder,
      output.filename.template  = params$outputFileNamePattern,
      author.data               = params$authorData,
      climdex.vars.subset       = params$indicesToCalculate,
      variable.name.map         = params$variableNameMap,
      axis.to.split.on          = params$axisName,
      fclimdex.compatible       = params$fClimdexCompatible,
      base.range                = params$baseRange,
      parallel                  = params$numCores,
      thresholds.files          = thresholdFiles,
      thresholds.name.map       = c(tx05thresh = "tx05thresh", tx10thresh = "tx10thresh",
                                    tx50thresh = "tx50thresh", tx90thresh = "tx90thresh", tx95thresh = "tx95thresh",
                                    tn05thresh = "tn05thresh", tn10thresh = "tn10thresh", tn50thresh = "tn50thresh",
                                    tn90thresh = "tn90thresh", tn95thresh = "tn95thresh",
                                    tx90thresh_15days = "tx90thresh_15days", tn90thresh_15days = "tn90thresh_15days",
                                    tavg90thresh_15days = "tavg90thresh_15days",
                                    tavg05thresh = "tavg05thresh", tavg95thresh = "tavg95thresh",
                                    txraw = "txraw", tnraw = "tnraw", precraw = "precraw",
                                    r95thresh = "r95thresh", r99thresh = "r99thresh"),
      ehfdef                    = params$ehfDefinition,
      max.vals.millions         = params$maxVals,
      cluster.type              = "SOCK"
    )
  }
  observe(toggleState("calculateGriddedIndices", !is.null(input$dataFiles)
    & (input$prName != "")
    & (input$txName != "")
    & (input$tnName != "")
    & (input$outputFileNamePattern != "")
    & (input$instituteID != "")
    & (input$instituteName != "")
    & (input$baseStart != "")
    & (input$baseEnd != "")
    & (input$nCores != "")
    & (input$maxVals != "")))
  outputOptions(output, "ncdfCalculationStatusText", suspendWhenHidden = FALSE)
}
