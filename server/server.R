server <- function(input, output, session) {
  # Everything within this function is instantiated separately for each session.
  # REF: https://shiny.rstudio.com/articles/scoping.html

  source("server/session_vars.R", local = TRUE)
  source("server/validate_user_input.R", local = TRUE)
  # source("server/quality_control_checks.R", local = TRUE)
  
  # modules called with second parameter being namespace id for corresponding UI
  step1 <- callModule(singleStationStep1, uiHelper$ns)
  step2 <- callModule(singleStationStep2, uiHelper$ns, step1, uiHelper)

  output$griddedMenuItem <- renderMenu({
    if (isLocal) {
      menuItem("Gridded data", tabName = "gridded", icon = icon("cube"),
        menuSubItem("Calculate Gridded Indices", tabName = "gridded-indices", icon = icon("cube")),
        menuSubItem("Calculate Gridded Thresholds", tabName = "gridded-thresholds", icon = icon("cube"))
      )
    }
  })

    # sectorCorrelationChanges <- reactive({
    #   input$calculateSectorCorrelation
    # })

    output$loadSectorDataText <- renderText({ HTML(uiHelper$sampleText) })

    output$loadParamHelpText <- renderText({
        indexParamLink <- paste0("<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#calculate_indices> Section 3.3</a>")
        HTML(paste0("The following fields change user-definable parameters in several ClimPACT indices. Leave as default unless you are interested
                    in these indices. See ", indexParamLink, " of the ", uiHelper$userGuideLink, " for guidance."))
    })

    output$batchIntroText <- renderText({
      guideBatchLink <- paste("<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#batch>section 5</a>", sep="")
      sampleBatchLink <- paste("<a target=\"_blank\" href=sample_data/climpact.sample.batch.metadata.txt>this file</a>",sep="")
      HTML(paste("A text file must be created with information for each station. Refer to ",uiHelper$guideBatchLink," of the user guide and use ",sampleBatchLink," as a template.
                         Once done supply ClimPACT with the file below."))
    })

    output$batchFolderText <- renderText({
      batchFormatLink <- paste("<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#appendixB>Appendix B</a>", sep="")
      HTML("Select all the ClimPACT formatted station text files that you would like to process from the dialog window that opens when you click Browse... below.<br />",
        paste0("These must be formatted according to ",batchFormatLink," of the user guide.<br />")
      )
    })

    output$indicesLink <- renderText({
      if(indexCalculationStatus() == "Done") {

        # zip files and get link
        folderToZip <- file.path(getwd(),outinddir)
        indicesZipLink <- zipFiles(folderToZip)
        localLink <- paste0("Please view the output in the following directory: <br /><br /><b>", folderToZip, "</b>")
        remoteLink <- paste0("<div class= 'alert alert-success' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                            " Calculated Indices available ", indicesZipLink, "</div>")
        
        HTML(localOrRemoteLink(localLink, remoteLink),
                    "<br><br>The <i>plots</i> subdirectory contains an image file for each index.",
                    "<br>The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index",
                    "<br>The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.",
                    "<br>The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables.",
                    "<br><br>The <i>qc</i> subdirectory contains quality control diagnostic information.",
                    "<br><br>If you have chosen to calculate and plot correlations between annual sector data you supply and the indices ClimPACT has calculated, the <i>corr</i> subdirectory will contain plots and .csv files containing the correlations."
        )
      }
    })

    output$sectorCorrelationLink <- renderText({
      sectorCorrelationChanges()  # respond to sector correlation calculation

      # zip files and get link
      folderToZip <- file.path(getwd(), get.corr.dir())
      corrZipLink <- zipFiles(folderToZip)
      localLink <- paste0("Correlation output has been created. Please view the output in the following directory: <br /><br /><b>", folderToZip, "</b>")
      remoteLink <- paste0("<div class= 'alert alert-success' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                            " Correlation output available ", corrZipLink, "</div>")
      HTML(localOrRemoteLink(localLink, remoteLink))
    })

      observeEvent(input$selectNcFiles,{
        gridNcFiles <<- fchoose(filters=ncFilter)
        output$ncFilePrint <- renderText({print(paste0("Input file(s): ",paste0(gridNcFiles,collapse=", ")))})
      })

      observeEvent(input$selectNcFilesThreshInput,{
        gridNcThresh <<- fchoose(filters=ncFilter)
        output$ncFilePrintThreshInput <- renderText({print(paste0("Threshold file: ",paste0(gridNcThresh,collapse=", ")))})
      })

      observeEvent(input$selectOutDir,{
        gridOutDir <<- dchoose()
        output$outDirPrint <- renderText({print(paste("Output directory: ",gridOutDir,sep=""))})
      })

      observeEvent(input$selectNcFilesThresh,{
        gridNcFilesThresh <<- fchoose(filters=ncFilter)
        output$ncFilePrintThresh <- renderText({print(paste0("Input file(s): ",paste0(gridNcFilesThresh,collapse=", ")))})
      })

      observeEvent(input$selectOutDirThresh,{
        gridOutDirThresh <<- dchoose()
        output$outDirPrintThresh <- renderText({print(paste("Output directory: ",gridOutDirThresh,sep=""))})
      })

     # now batchCsvs
      # observeEvent(input$selectInDirBatch,{
      #   batchInDir <<- dchoose()
      #   output$inDirPrintBatch <- renderText({print(paste("Input directory: ",batchInDir,sep=""))})
      # })

      # Create the ncdf wrapper file that will be executed from the Linux command line.
      # All code needs to be placed inside the renderText() function so that validate() can abort this code if any errors are detected.
      output$ncPrint <- eventReactive(input$calculateGriddedIndices, {
          # ------------------------------------------------------------------ #
          # Validate inputs
          # ------------------------------------------------------------------ #
          validate(
            need(!is.null(gridNcFiles),message="Please specify input file(s)."),
            need(input$prName,message="Please specify the name of the precipitation variable as it is recorded in its netCDF file"),
            need(input$tnName,message="Please specify the name of the minimum temperature variable as it is recorded in its netCDF file."),
            need(input$txName,message="Please specify the name of the maximum temperature variable as it is recorded in its netCDF file."),
            need(!is.null(gridOutDir),message="Please specify output directory."),
            need(input$fileConvention,message="Please specify an output filename convention."),
            need(input$instituteID,input$instituteName,message="Please specify institute name and ID."),
            need(input$baseBegin,input$BaseEnd,message="Please specify start and end year of base period (e.g. 1990)"),
            need(input$nCores,message="Please specify number of cores to use."),
            need(input$maxVals,message="Please specify max values.")
          )

          # ------------------------------------------------------------------ #
          # Make and edit wrapper file with user preferences
          # ------------------------------------------------------------------ #
          user_wrapper_file <<- paste("climpact.ncdf.",input$instituteID,".wrapper.r",sep="")
          master.ncdf.gridded.wrapper.file <<- paste0("climpact.ncdf.wrapper.r")
          file.copy(master.ncdf.gridded.wrapper.file <<- paste0("climpact.ncdf.wrapper.r"),user_wrapper_file,overwrite=TRUE)

          wraptext <- readLines(user_wrapper_file)
          fileText = ""
          for (i in 1:length(gridNcFiles)) {
            fileText = paste(fileText,"\"",gridNcFiles[i],"\"",sep="")
            if(i < length(gridNcFiles)) {
              fileText = paste(fileText,",",sep="")
            }
          }

		  # Take care of backward slashes (in Windows)
		  fileText <- gsub(pattern="\\\\",replace="/",x=fileText)

		  tmp1 <- gridOutDir
		  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
		  tmp2 <- split_path(tmp1)
		  tmp3 <- do.call('file.path',as.list(rev(tmp2)))
		  rm(tmp1,tmp2)

          wraptext <- gsub(pattern=".*infiles=.*",replace=paste("infiles=c(",fileText,")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*vars=.*",replace=paste("vars=c(prec=\"",input$prName,"\",tmax=\"",input$txName,"\",tmin=\"",input$tnName,"\")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*outdir=.*",replace=paste("outdir=\"",tmp3,"\"",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*file.template=.*",replace=paste("file.template=\"",input$fileConvention,"\"",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*author.data=list.*",replace=paste("author.data=list(institution=\"",input$instituteName,"\",institution_id=\"",input$instituteID,"\")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*base.range=c.*",replace=paste("base.range=c(",input$baseBegin,",",input$baseEnd,")",sep=""),x=wraptext)
          if(input$nCores>1) {
            wraptext <- gsub(pattern=".*cores=FALSE.*",replace=paste("cores=",input$nCores,sep=""),x=wraptext)
          }
          if(exists("gridNcThresh") && !is.null(gridNcThresh)) {
            wraptext <- gsub(pattern=".*thresholds.files=NULL.*",replace=paste("thresholds.files=\"",gridNcThresh,"\"",sep=""),x=wraptext)
          }
          wraptext <- gsub(pattern=".*EHF_DEF = .*",replace=paste("EHF_DEF=\"",input$EHFcalc,"\"",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*maxvals=10.*",replace=paste("maxvals=",input$maxVals,sep=""),x=wraptext)

          writeLines(wraptext,con=user_wrapper_file)

          showModal(modalDialog(
            title = "Important message",
            "Calculating gridded indices usually takes many hours, depending on how large your dataset is, how fast your computer is and how many cores you choose.",
            br(),
            br(),
            paste0("Do not close the ClimPACT browser window until this process is complete. You will see \"Done\" printed below the \"Calculate NetCDF indices\"
                   button when ClimPACT is finished."),
            br(),
            br(),
            paste0("Your output will be created in ",gridOutDir),
            footer = tagList(
              modalButton("Cancel"),
              actionButton("proceedGridded", "PROCEED")
            )
          ))

          # HOW CAN WE DISPLAY THE R CONSOLE OUTPUT TO THE USER IN REALTIME?
          return("")
      })

      observeEvent(input$proceedGridded,{
        disable("calculateGriddedIndices")
        removeModal()

		    error <- FALSE

        data <- tryCatch(system(paste("Rscript ",user_wrapper_file,sep=""),intern=TRUE),
                         error= function(c) {
                           if(interactive()) {
                             showModal(modalDialog(
                               title = "WARNING",
                               print("There was a problem processing your gridded data. Check your R console for the specific error message generated. It is very likely your data is not formatted correctly."),
                               print(paste("R error message was: ",c,sep="")),
								error <- TRUE,
                               footer = tagList(modalButton("Ok, I will fix it and try again."))
                             ))
                             output$ncGriddedDone <- renderText({ HTML(" ") })
                           }
                           return(c)
                         }, warning=function(c) {
                           if(interactive()) {
                             showModal(modalDialog(
                               title = "ERROR",
                               print("There was a problem processing your gridded data. Check your R console for the specific error message generated. It is very likely your data is not formatted correctly."),
                               print(paste("R error message was: ",c,sep="")),
								error <- TRUE,
                               footer = tagList(modalButton("Ok, I will fix it and try again."))
                             ))
                             output$ncGriddedDone <- renderText({ HTML(" ") })
                           }
                           return(c)
                        }, finally={
                          invisible(file.remove(user_wrapper_file))
                        })

		    print(data)

        if(is.character(data) && !error) output$ncGriddedDone <- renderText({ HTML("Done.",paste0("Look in the following directory for your output: ",gridOutDir)) })

        gridNcThresh <<- NULL
        enable("calculateGriddedIndices")
      })

      #observeEvent
      output$ncPrintThresh <- eventReactive(input$calculateGriddedThresholds, {
          # ------------------------------------------------------------------ #
          # Validate inputs
          # ------------------------------------------------------------------ #
          validate(
            need(!is.null(gridNcFilesThresh),message="Please specify input file(s)."),
            need(input$prNameThresh,message="Please specify the name of the precipitation variable as it is recorded in its netCDF file"),
            need(input$tnNameThresh,message="Please specify the name of the minimum temperature variable as it is recorded in its netCDF file."),
            need(input$txNameThresh,message="Please specify the name of the maximum temperature variable as it is recorded in its netCDF file."),
            need(!is.null(gridOutDirThresh),message="Please specify output directory."),
            need(input$outFileThresh,message="Please specify an output filename."),
            need(input$instituteIDThresh,input$instituteName,message="Please specify institute name and acronym."),
            need(input$baseBeginThresh,input$BaseEndThresh,message="Please specify start and end year of base period (e.g. 1990 and 2010)"),
            need(input$nCoresThresh>0,message=paste0("Number of cores must be between 1 and ",detectCores())),
            need(input$nCoresThresh<=detectCores(),message=paste0("Number of cores must be between 1 and ",detectCores()))
          )

          # ------------------------------------------------------------------ #
          # Make and edit wrapper file with user preferences
          # ------------------------------------------------------------------ #
          user_wrapper_thresh_file <<- paste("climpact.ncdf.",input$instituteIDThresh,".thresholds.wrapper.r",sep="")
          master.ncdf.threshold.wrapper.file <<- paste0("climpact.ncdf.thresholds.wrapper.r")
          file.copy(master.ncdf.threshold.wrapper.file,user_wrapper_thresh_file,overwrite=TRUE)
          wraptext <- readLines(user_wrapper_thresh_file)
          fileText = ""
          for (i in 1:length(gridNcFilesThresh)) {
            fileText = paste(fileText,"\"",gridNcFilesThresh[i],"\"",sep="")
            if(i < length(gridNcFilesThresh)) {
              fileText = paste(fileText,",",sep="")
            }
          }

		  # Take care of backward slashes (in Windows)
		  fileText <- gsub(pattern="\\\\",replace="/",x=fileText)

		  tmp1 <- paste0(gridOutDirThresh,"/",input$outFileThresh)
		  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
		  tmp2 <- split_path(tmp1)
		  tmp3 <- do.call('file.path',as.list(rev(tmp2)))
		  tmp3 <- gsub(pattern="//",replace="/",x=tmp3)
		  rm(tmp1,tmp2)

          wraptext <- gsub(pattern=".*input.files=.*",replace=paste("input.files=c(",fileText,")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*vars=.*",replace=paste("vars=c(prec=\"",input$prNameThresh,"\",tmax=\"",input$txNameThresh,"\",tmin=\"",input$tnNameThresh,"\")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*output.file=.*",replace=paste("output.file=\"",tmp3,"\"",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*author.data=list.*",replace=paste("author.data=list(institution=\"",input$instituteNameThresh,"\",institution_id=\"",input$instituteIDThresh,"\")",sep=""),x=wraptext)
          wraptext <- gsub(pattern=".*base.range=c.*",replace=paste("base.range=c(",input$baseBeginThresh,",",input$baseEndThresh,")",sep=""),x=wraptext)
          if(input$nCoresThresh>1) {
            wraptext <- gsub(pattern=".*cores=FALSE.*",replace=paste("cores=",input$nCoresThresh,sep=""),x=wraptext)
          }

          writeLines(wraptext,con=user_wrapper_thresh_file)

          showModal(modalDialog(
            title = "Important message",
            "Calculating gridded thresholds usually takes an hour or more, depending on how large your dataset is, how fast your computer is and how many cores you choose.",
            br(),
            br(),
            paste0("Do not close the ClimPACT browser window until this process is complete. You will see \"Done\" printed below the \"Calculate NetCDF thresholds\"
                   button when ClimPACT is finished."),
            br(),
            br(),
            footer = tagList(
              modalButton("Cancel"),
              actionButton("proceedGriddedThresh", "PROCEED")
            )
          ))

            return("")
		})

		observeEvent(input$proceedGriddedThresh,{
        disable("calculateGriddedThresholds")
        removeModal()

		error <- FALSE

        data <- tryCatch(system(paste("Rscript ",user_wrapper_thresh_file,sep=""),intern=TRUE),
                         error= function(c) {
                           if(interactive()) {
                             showModal(modalDialog(
                               title = "WARNING",
                               print("There was a problem processing your gridded data. Check your R console for the specific error message generated. It is very likely your data is not formatted correctly."),
                               print(paste("R error message was: ",c,sep="")),
							   error <- TRUE,
                               footer = tagList(modalButton("Ok, I will fix it and try again."))
                             ))
                             output$ncGriddedThreshDone <- renderText({ HTML(" ") })
                           }
                           return(c)
                         }, warning=function(c) {
                           if(interactive()) {
                             showModal(modalDialog(
                               title = "ERROR",
                               print("There was a problem processing your gridded data. Check your R console for the specific error message generated. It is very likely your data is not formatted correctly."),
                               print(paste("R error message was: ",c,sep="")),
   							   error <- TRUE,
                               footer = tagList(modalButton("Ok, I will fix it and try again."))
                             ))
                             output$ncGriddedThreshDone <- renderText({ HTML(" ") })
                           }
                           return(c)
                         }, finally={
                           invisible(file.remove(user_wrapper_thresh_file))
                         })

		    print(data)
        if(is.character(data) && !error) output$ncGriddedThreshDone <- renderText({
          filePath <- file.path(gridOutDirThresh, input$outFileThresh)
          HTML("Done. Threshold file stored here: ", filePath)
        })
        enable("calculateGriddedThresholds")
      })

      startYearBatch <<- reactive({
        validate(
          need(input$startYearBatch,message="Please specify start year of base period.")
        )
        input$startYearBatch
      })

      endYearBatch <<- reactive({
        validate(
          need(input$endYearBatch,message="Please specify end year of base period.")
        )
        input$endYearBatch
      })

      nCoresBatch <<- reactive({
        validate(
          need(input$nCoresBatch>0,message="You require a minimum of 1 core to perform this operation."),
          need(input$nCoresBatch<=detectCores(),message=paste0("You cannot select more than ",detectCores()," on this computer."))
        )
        input$nCoresBatch
      })

      batchMeta <<- reactive({
        validate(
          need(input$batchMeta,message="Please specify the name of metadata text file (Step 1).")
        )
        input$batchMeta
      })

      batchCsvs <<- reactive({
        validate(
          need(input$batchCsvs,message="Please upload files to process (Step 2).")
        )
        input$batchCsvs
      })

      batchProcessingModal <- function(msg) {
        modalDialog(
          title = "Important message",
          "Your indices will be calculated after closing this window. Doing this for multiple stations can take time. On a typical computer each station takes ~1 minute to process per core.",
          br(),
          br(),
          msg,
          br(),
          br(),
          "You will see a message printed at the bottom of the screen when processing is complete.",
          # paste0("In the meantime, you should start to see your output appear in ",batchInDir,"."),
          footer = tagList(modalButton("Cancel"), actionButton("ok", "OK"))
        )
      }

      observeEvent(input$ok, {
        removeModal()
        disable("calculateBatchIndices")

        progress <<- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message="Processing data", value=0.01)

        nCoresBatch <- nCoresBatch()
        source("climpact.batch.stations.r")

        # cat(file=stderr(), "input$batchMeta$datapath:", input$batchMeta$datapath, "\n")
        assign("file.list.metadata.global",input$batchMeta$datapath,envir=.GlobalEnv)
        # cat(file=stderr(), "file.list.metadata.global:", file.list.metadata.global, "\n")

        batchMode <<- FALSE #JMC was TRUE
        cl <<- makeCluster(nCoresBatch)

        cat(file=stderr(), "about to call testvariables___ functions.", "\n")
        # Assign value with <<- operator as we are calling out of a reactive function
        metadatafilepath <<- input$batchMeta$datapath
        metadatafilename <<- input$batchMeta$name
        batchfiles <<- input$batchCsvs

        assign("metadatafilepath.global", metadatafilepath, envir=.GlobalEnv)
        assign("metadatafilename.global", metadatafilename, envir=.GlobalEnv)
        assign("batchfiles.global", batchfiles, envir=.GlobalEnv)

        # This function is where the work is done
        batchZipFilePath <- batch(metadatafilepath,metadatafilename,batchfiles,input$startYearBatch,input$endYearBatch)
        cat(file=stderr(), "batchZipFilePath", batchZipFilePath, "\n")

        enable("calculateBatchIndices")

        batchZipFileLink <- getLinkFromPath(batchZipFilePath, "here")

        localLink <- paste0("<br /><br /><b>",paste0(getwd(),"/www/",batchZipFilePath),"</b>")
        remoteLink <- paste0(" ", batchZipFileLink)
        HTML("Batch output has been created. Please view the output", localOrRemoteLink(localLink, remoteLink),
                    "<br>Results for each station are stored in separate directories. See *error.txt files for stations that had problems.",
                    "<br><br>The <i>plots</i> subdirectory contains an image file for each index.",
                    "<br>The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index",
                    "<br>The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.",
                    "<br>The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables.",
                    "<br><br>The <i>qc</i> subdirectory contains quality control diagnostic information.",
                    "<br><br>If you have chosen to calculate and plot correlations between annual sector data you supply and the indices ClimPACT has calculated, the <i>corr</i> subdirectory will contain plots and .csv files containing the correlations."
        )

      })
      # handle calculateBatchIndices click
      output$ncPrintBatch <- eventReactive(input$calculateBatchIndices, {

        # ------------------------------------------------------------------ #
        # Validate inputs
        # ------------------------------------------------------------------ #
        startYearBatch <- startYearBatch()
        endYearBatch <- endYearBatch()
        batchCsvs <- batchCsvs()
        batchMeta <- batchMeta()
        nCoresBatch <- nCoresBatch()
        tmp <<- read.table(input$batchMeta$datapath,header=TRUE)

        modalMessage <- paste0("You appear to have ", nrow(tmp)," stations and have requested ",nCoresBatch," cores and so this process should take ~",nrow(tmp)/nCoresBatch," minutes to complete.")
        # Display notification before processing
        showModal(batchProcessingModal(modalMessage))


      })

      output$sliders <- renderUI({
        numStations <- as.integer(input$nStations)
        lapply(1:numStations, function(i) {
          fluidRow(
            column(1,
                 textInput("stationFile", "Station filename:")
            ),
            column(1,
                 textInput("stationLat", "Latitude of station:")
            ),
              uiOutput("sliders")
            )
        })
      })

      withConsoleRedirect <- function(containerId, expr) {
        # Change type="output" to type="message" to catch stderr
        # (messages, warnings, and errors) instead of stdout.
        txt <- capture.output(results <- expr, type = "output")
        if (length(txt) > 0) {
          insertUI(paste0("#", containerId), where = "beforeEnd",
                   ui = paste0(txt, collapse = "")
          )
        }
        results
      }

    indexCalculationStatus <- reactiveVal("Not Started")

    # Index calculation has been requested by the user.
    output$indiceCalculationError <- eventReactive(input$calculateIndices, {
      # ------------------------------------------------------------------ #
      # Validate inputs
      # ------------------------------------------------------------------ #
      validate(
        need(input$wsdin<=10,message="WSDId requires d to be between 1 and 10"),
        need(input$wsdin>0,message="WSDId requires d to be between 1 and 10"),
        need(input$csdin<=10,message="CSDId requires d to be between 1 and 10"),
        need(input$csdin>0,message="CSDId requires d to be between 1 and 10"),
        need(input$rxnday>=1,message="RXnDAY requires n to be a positive number"),
        need(input$txtn>=1,message="TXdTNd and TXbdTNbd requires d to be a positive number"),
        need(input$rnnmm>=0,message="Rnnmm requires nn to be greater than or equal to zero"),
        need(input$spei>=1,message="Custom SPEI/SPI time scale must be a positive number")
      )
      plotTitleMissing()

      # Get inputs.
      plot.title <- input$plotTitle
      wsdi_ud <- input$wsdin
      csdi_ud <- input$csdin
      rx_ui <- input$rxnday
      txtn_ud <- input$txtn
      Tb_HDD <- input$hdd
      Tb_CDD <- input$cdd
      Tb_GDD <- input$cdd
      rnnmm_ud <- input$rnnmm
      custom_SPEI <- input$spei
      var.choice <- input$custVariable
      op.choice <- input$custOperation
      constant.choice <- input$custThreshold

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message="Calculating indices", value=0)

      indexCalculationStatus("In Progress")

      # Call into ClimPACT to calculate indices.      
      error <- draw.step2.interface(progress, plot.title, wsdi_ud, csdi_ud,
                                    rx_ui, txtn_ud, rnnmm_ud, Tb_HDD, Tb_CDD,
                                    Tb_GDD, custom_SPEI, var.choice, op.choice,
                                    constant.choice, outputFolders)
      indexCalculationStatus("Done")
      return("")
    }
    )

    ## Correlation functionality

    # React to upload
    observeEvent(input$sectorDataFile, {
      val <- strsplit(input$sectorDataFile$name, "[_\\.]")[[1]][1]
      updateTextInput(session, "sectorPlotName", value=val)
    })

    # Handle calculation of correlation between climate/sector data
    output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {

      if(!exists("corrdir")){
        return("Correlation directory does not exist, please use Process button on Load & Check Data")
      }

      climate.data <- dataFile()
      if (is.null(climate.data)) {
        return("Bad data file")
      }

      sector.data <- sectorDataFile()
      if (is.null(sector.data)) {
        return("Bad sector data file")
      }

      plotTitleMissing()

      plot.title <- input$sectorPlotName
      detrendCheck <- input$detrendCheck

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message="Calculating correlation", value=0)

      error <- draw.correlation(progress, climate.data$datapath, sector.data$datapath, stationName(), plot.title, detrendCheck)

      ifelse(error=="",return(""),return(error))
    })

    outputOptions(output, "indiceCalculationError", suspendWhenHidden=FALSE)
    # outputOptions(output, "qualityControlError", suspendWhenHidden=FALSE)
    outputOptions(output, "sectorCorrelationError", suspendWhenHidden=FALSE)

    # toggle state of buttons depending on certain criteria
    # Single station
    # observe(toggleState('btn_next_process_single_station_step_1', !is.null(input$dataFile)))
    # observe(toggleState('btn_next_process_single_station_step_2', !is.null(input$dataFile) && qualityControlErrorText()==''))
    # observe(toggleState('btn_next_process_single_station_step_3', indexCalculationStatus()=='Done'))

    # observe(toggleState('doQualityControl', !is.null(input$dataFile)))
    # observe(toggleState('calculateIndices', !is.null(input$dataFile)))

    # Batch
    observe(toggleState('calculateBatchIndices', !is.null(input$batchMeta) && !is.null(input$batchCsvs)))
    # Sector correlation
    # observe(toggleState('calculateSectorCorrelation', !is.null(input$dataFile) & !is.null(input$sectorDataFile)))

    observeEvent(input$btn_next_process_single_station_step_1, {
      tabName <- "process_single_station_step_2"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })
    observeEvent(input$btn_next_process_single_station_step_2, {
      tabName <- "process_single_station_step_3"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })
    observeEvent(input$btn_next_process_single_station_step_3, {
      tabName <- "process_single_station_step_4"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })

    # observeEvent(qualityControlErrorText(), {
    #   session$sendCustomMessage("enableTab", "process_single_station_step_3")
    # })
    observeEvent(indexCalculationStatus(), {
      if (indexCalculationStatus()=="Done") {
        session$sendCustomMessage("enableTab", "process_single_station_step_4")
      }
    })
}
