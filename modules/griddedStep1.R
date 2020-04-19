griddedStep1 <- function(input, output, session, climpactUI) {
  infoDialog <- function(msg) {
    ns <- session$ns
    modalDialog(
        title = "Important message",
        HTML("Calculating gridded indices usually takes many hours, depending on how large your dataset is,",
          " how fast your computer is and how many cores you choose."),
        br(),
        br(),
        HTML("Do not close the ClimPACT browser window until this process is complete. ",
          "You will see \"Done\" printed below the \"Calculate NetCDF indices\" button when ClimPACT is finished."),
        br(),
        br(),
        paste0("Your output will be created in ", gridOutDir()),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("proceedGridded"), "Calculate Indices")
        )
      )
  }
  warningDialog <- function(msg) {
    ns <- session$ns
    modalDialog(
      title = "Warning",
      HTML("There was a problem processing your gridded data. ",
        "Check your R console for the specific error message generated. It is very likely your data is not formatted correctly."),
      print(paste0("R error message was: ", msg)),
      footer = tagList(modalButton("OK"))
    )
  }
  errorDialog <- function(msg) {
    ns <- session$ns
    modalDialog(
      title = "Error",
      HTML("There was a problem processing your gridded data.",
        " Check your R console for the specific error message generated. It is very likely your data is not formatted correctly.",
        "R error message was: ", msg),
      footer = tagList(modalButton("OK"))
    )
  }

  gridNcFiles  <- reactiveVal(NULL)
  gridNcThresh <- reactiveVal(NULL)
  gridOutDir   <- reactiveVal(NULL)

  observeEvent(input$selectNcFiles, {
    gridNcFiles(fchoose(filters=ncFilter))
    output$ncFilePrint <- renderText({
      print(paste0("Input file(s): ", paste0(gridNcFiles(), collapse = ", ")))
    })
  })

  observeEvent(input$selectOutDir, {
    gridOutDir(dchoose())
    output$outDirPrint <- renderText({
      print(paste0("Output directory: ", gridOutDir()))
    })
  })

  observeEvent(input$selectNcFilesThreshInput, {
    gridNcThresh(fchoose(filters=ncFilter))
    output$ncFilePrintThreshInput <- renderText({
      paste0("Threshold file: ", paste0(gridNcThresh(), collapse=", "))
    })
  })

  # Global vars required as class level vars not updated from within methods.
  user_wrapper_file <- reactiveVal("")

  # Create the ncdf wrapper file that will be executed from the Linux command line.
  # All code needs to be placed inside the renderText() function so that validate() can abort this code if any errors are detected.
  output$ncPrint <- eventReactive(input$calculateGriddedIndices, {
      # ------------------------------------------------------------------ #
      # Validate inputs
      # ------------------------------------------------------------------ #
      validate(
        need(!is.null(gridNcFiles()), message = "Please specify input file(s)."),
        need(input$prName, message = "Please specify the name of the precipitation variable as it is recorded in its netCDF file"),
        need(input$tnName, message = "Please specify the name of the minimum temperature variable as it is recorded in its netCDF file."),
        need(input$txName, message = "Please specify the name of the maximum temperature variable as it is recorded in its netCDF file."),
        need(!is.null(gridOutDir()), message = "Please specify output directory."),
        need(input$fileConvention, message = "Please specify an output filename convention."),
        need(input$instituteID, input$instituteName, message = "Please specify institute name and ID."),
        need(input$baseBegin, input$BaseEnd, message = "Please specify start and end year of base period (e.g. 1990)"),
        need(input$nCores, message = "Please specify number of cores to use."),
        need(input$maxVals, message = "Please specify max values.")
      )

      # ------------------------------------------------------------------ #
      # Make and edit wrapper file with user preferences
      # ------------------------------------------------------------------ #
      master.ncdf.gridded.wrapper.file <- "climpact.ncdf.wrapper.r"
      user_wrapper_file(paste0("climpact.ncdf.", input$instituteID, ".wrapper.r"))
      file.copy(master.ncdf.gridded.wrapper.file, user_wrapper_file(), overwrite = TRUE)

      wraptext <- readLines(user_wrapper_file())
      fileText <- ""
      for (i in 1:length(gridNcFiles())) {
        fileText <- paste0(fileText, "\"", gridNcFiles()[i], "\"")
        if (i < length(gridNcFiles())) {
          fileText <- paste0(fileText, ",")
        }
      }

      # Take care of backward slashes (in Windows)
      fileText <- gsub(pattern="\\\\", replace="/", x = fileText)

      tmp1 <- gridOutDir()
      split_path <- function(x) {
        if (dirname(x) == x) {
          x
        } else {
          c(basename(x), split_path(dirname(x)))
        }
      }

      tmp2 <- split_path(tmp1)
      tmp3 <- do.call("file.path", as.list(rev(tmp2)))
      rm(tmp1, tmp2)

      wraptext <- gsub(pattern = ".*infiles=.*", replace = paste0("infiles=c(", fileText, ")"), x = wraptext)
      wraptext <- gsub(pattern = ".*vars=.*",
        replace = paste0("vars=c(prec=\"", input$prName, "\",tmax=\"", input$txName, "\",tmin=\"", input$tnName, "\")"), x = wraptext)
      wraptext <- gsub(pattern = ".*outdir=.*", replace = paste0("outdir=\"", tmp3, "\""), x = wraptext)
      wraptext <- gsub(pattern = ".*file.template=.*", replace = paste0("file.template=\"", input$fileConvention, "\""), x = wraptext)
      wraptext <- gsub(pattern = ".*author.data=list.*",
        replace = paste0("author.data=list(institution=\"", input$instituteName, "\",institution_id=\"", input$instituteID, "\")"), x = wraptext)
      wraptext <- gsub(pattern = ".*base.range=c.*",
        replace = paste0("base.range=c(", input$baseBegin, ",", input$baseEnd, ")"), x = wraptext)
      if (input$nCores > 1) {
        wraptext <- gsub(pattern = ".*cores=FALSE.*", replace = paste0("cores=", input$nCores), x = wraptext)
      }
      if (!is.null(gridNcThresh())) {
        wraptext <- gsub(pattern = ".*thresholds.files=NULL.*", replace = paste0("thresholds.files=\"", gridNcThresh(), "\""), x = wraptext)
      }
      wraptext <- gsub(pattern = ".*EHF_DEF = .*", replace = paste0("EHF_DEF=\"", input$EHFcalc, "\""), x = wraptext)
      wraptext <- gsub(pattern = ".*maxvals=10.*", replace = paste0("maxvals=", input$maxVals), x = wraptext)

      writeLines(wraptext, con = user_wrapper_file())

      showModal(infoDialog())

      # TODO - DISPLAY THE R CONSOLE OUTPUT TO THE USER IN REALTIME
      return("")
  })

  error <- FALSE
  observeEvent(input$proceedGridded, {
    disable("calculateGriddedIndices")
    removeModal()
browser()
    out <- tryCatch(system(paste0("Rscript ", user_wrapper_file()), intern = TRUE),
              error = function(cond) {
                error <- TRUE
                showModal(errorDialog(cond$message))
                return(paste0("Error occurred: ", cond$message))
              },
              # warning = function(cond) {
              #   showModal(warningDialog(cond$message))
              #   return(paste0("Warning: ", cond$message))
              # },
              finally = {
                if (file.exists(user_wrapper_file())) {
                  invisible(file.remove(user_wrapper_file()))
                }
              })
    output$ncGriddedDone <- renderText({
      if (is.character(data) && !error) {
        HTML("Done.", paste0("Look in the following directory for your output: ", gridOutDir()), "<br />", out)
      } else {
        HTML(out)
      }
    })

    gridNcThresh(NULL)
    enable("calculateGriddedIndices")
  })

}
