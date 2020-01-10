climpact.server <- function(input, output, session) {
    master.ncdf.threshold.wrapper.file <<- paste0("climpact.ncdf.thresholds.wrapper.r")
    master.ncdf.gridded.wrapper.file <<- paste0("climpact.ncdf.wrapper.r")
    batch.script <<- paste0("climpact.batch.stations.r")
    
    # Increase file upload limit to something extreme to account for large files. Is this necessary anymore since files aren't loaded into the GUI? nherold.
    options(shiny.maxRequestSize=1000000*1024^2) 
  
    # These element validate and return user input values.
    # Validate latitude
    stationLat <- reactive({
        validate(
            need(input$stationLat >= -90 && input$stationLat <= 90,
                 'Latitude must be between -90 and 90.')
        )
        input$stationLat
    })

    # Validate longitude
    stationLon <- reactive({
        validate(
            need(input$stationLon >= -180 && input$stationLon <= 180,
                 'Longitude must be between -180 and 180')
        )
        input$stationLon
    })

    # Validate station name
    stationName <- reactive({
        validate(
            need(input$stationName != "", message="Please enter a station name")
        )
        input$stationName
    })

    # Validate climate dataset
    dataFile <- reactive({
        validate(
            need(!is.null(input$dataFile), message="Please load a dataset")
        )
        input$dataFile
    })

    # Validate sector dataset
    sectorDataFile <- reactive({
        validate(
            need(!is.null(input$sectorDataFile), message="Please load a dataset")
        )
        input$sectorDataFile
    })

    output$qualityControlError <- eventReactive(input$doQualityControl, {
        stationName()
    })

    output$qualityControlError <- eventReactive(input$calculateIndices, {
        dataFile()
    })

    # Validate the plot title.
    plotTitleMissing <- reactive({
        validate(
            need(input$plotTitle != "", message="Please enter a plotting title")
        )
        ""
    })
    output$indiceCalculationError <- eventReactive(input$calculateIndices, {
        plotTitleMissing()
    })

    # Validate sector plot title.
    sectorPlotTitleMissing <- reactive({
      validate(
        need(input$sectorPlotName != "", message="Please enter a plotting title")
      )
      ""
    })
    output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
      sectorPlotTitleMissing()
    })

    datasetChanges <- reactive({
        input$doQualityControl
    })

    indiceChanges <- reactive({
        input$calculateIndices
    })

    sectorCorrelationChanges <- reactive({
      input$calculateSectorCorrelation
    })

    fileServerUrl <- reactive({
      paste(session$clientData$url_protocol, "//",
            session$clientData$url_hostname, ":", 4199, "/", sep="")
    })

    userGuildLink <- reactive({
      paste("<a target=\"_blank\" href=/user_guide/ClimPACT_user_guide.htm>ClimPACT User Guide</a>", sep="")
    })

    appendixBLink <- reactive({
      paste("<a target=\"_blank\" href=/user_guide/ClimPACT_user_guide.htm#appendixB>Appendix B</a>", sep="")
    })

    # Create some html text to be displayed to the client.
    output$loadDatasetText <- renderText({
      sydneySampleLink <- paste("<a target=\"_blank\" href=/sample_data/sydney_observatory_hill_1936-2015.txt> sydney_observatory_hill_1936.txt</a>", sep="")
      HTML(paste("The dataset <strong>must</strong> use the format described in ",
                  appendixBLink(), " of the ", userGuildLink(),".",
                  "<br>", "<br>",
                  "For a sample dataset look at ", sydneySampleLink, sep="")
           )
    })

    # Create some html text to be displayed to the client.
    output$loadSectorDataText <- renderText({
      wheatSampleLink <- paste("<a target=\"_blank\" href=/sample_data/wheat_yield_nsw_1922-1999.csv>  wheat_yield_nsw_1922-1999.csv</a>", sep="")
      HTML(paste("The dataset <strong>must</strong> use the format described in ",
                  appendixBLink(), " of the ", userGuildLink(),
                  "<br>", "<br>",
                  "To view a sample dataset see here ", wheatSampleLink, sep="")
           )
    })

    output$loadParamHelpText <- renderText({
        indexParamLink <- paste("<a target=\"_blank\" href=/user_guide/ClimPACT_user_guide.htm#calculate_indices> Section 3.3</a>", sep="")
        HTML(paste("The following fields change user-definable parameters in several ClimPACT indices. Leave as default unless you are interested
                    in these indices. See ", indexParamLink, " of the ", userGuildLink(), " for guidance.", sep=""))
    })

    output$batchIntroText <- renderText({
      guideBatchLink <- paste("<a target=\"_blank\" href=/user_guide/ClimPACT_user_guide.htm#batch>section 5</a>", sep="")
      sampleBatchLink <- paste("<a target=\"_blank\" href=sample_data/climpact.sample.batch.metadata.txt>this file</a>",sep="")
      HTML(paste("A text file must be created with information for each station. Refer to ",guideBatchLink," of the user guide and use ",sampleBatchLink," as a template.
                         Once done supply ClimPACT with the file below."))
    })
    
    output$batchFolderText <- renderText({
      batchFormatLink <- paste("<a target=\"_blank\" href=/user_guide/ClimPACT_user_guide.htm#appendixB>Appendix B</a>", sep="")
      HTML(paste("Select the directory containing the ClimPACT formatted station text files that you would like to process. These must be formatted according to ",batchFormatLink," of the user guide.",sep=""),
           "<br> "
           )
    })
    
    # Create some html text to be displayed to the client.
    output$qcLink <- renderText({
        datasetChanges()
        qcDir <- get.qc.dir()
        print("qcDir")
        print(qcDir)
        print(strsplit(qcDir,"/|\\\\"))
        print(file.path(strsplit(qcDir,"/|\\\\")))
        appendixCLink <- paste("<a target=\"_blank\" href=", "/user_guide/ClimPACT_user_guide.htm#appendixC>", "Appendix C</a>", sep="")
        HTML(paste("Please view the quality control output in the directory below and carefully evaluate before continuing. Refer to ",
                   appendixCLink, " of the ", userGuildLink(), " for help.", sep=""),
             paste0("<br /><br /><b>Quality control directory: ",getwd(),.Platform$file.sep,qcDir,"</b>")
            )
    })

    output$indicesLink <- renderText({
        indiceChanges()
        # indicesDirLink <- paste("<a target=\"_blank\" href=",gsub(" ","%20",get.indices.dir()), ">indices</a>", sep="")
        # plotsDirLink <- paste("<a target=\"_blank\" href=", fileServerUrl(),gsub(" ","%20",get.plots.dir()), ">plots</a>", sep="")
        # trendsDirLink <- paste("<a target=\"_blank\" href=", fileServerUrl(),gsub(" ","%20",get.trends.dir()), ">trends</a>", sep="")
        # threshDirLink <- paste("<a target=\"_blank\" href=",fileServerUrl(),gsub(" ","%20",get.thresh.dir()), ">thresholds</a>", sep="")
        zipFileLink <- paste("<a target=\"_blank\" href=", gsub(" ","%20",get.output.zipfile()), ">here</a>.", sep="")
        # HTML(paste("View ", indicesDirLink, ", ", plotsDirLink, ", ", trendsDirLink, ", ",
        #            threshDirLink, " OR ", zipFileLink, sep=""))
        
        HTML("All output has been created in the following server directory: ",
             paste0("<br /><br /><b>",getwd(),.Platform$file.sep,outdir,"</b>"),
		    "<br><br>or can be downloaded ",zipFileLink," if you are accessing ClimPACT remotely",
                    "<br><br>The <i>plots</i> subdirectory contains an image file for each index.",
                    "<br>The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index",
                    "<br>The <i>trends</i> subdirectory contains a .csv file containing linear trend information for each index.",
                    "<br>The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables."
        )
    })

    output$sectorCorrelationLink <- renderText({
      sectorCorrelationChanges()
      HTML("Correlation output has been created in the following directory: ",
           "<br><br>",
           paste0("<b>",getwd(),.Platform$file.sep,get.corr.dir(),"</b>")
      )
    })


    # switch to calculateIndices tab
	  observeEvent(input$calculateIndicesTabLink, {
        updateTabsetPanel(session, "mainNavbar",
                          selected="calculateIndices")
  	})

    # Switch to getting started tab
    observeEvent(input$doGetStarted, {
        updateTabsetPanel(session, "mainNavbar",
                          selected="gettingStarted")
    })

    # Fill in default values for station name and plot title based on the name
    # of datafile.
    observeEvent(input$dataFile, {
        val <- strsplit(input$dataFile$name, "[_\\.]")[[1]][1]
        updateTextInput(session, "stationName", value=val)
        updateTextInput(session, "plotTitle", value=val)
    })

    # Quality control processing has been requested by the user.
    output$qualityControlError <- eventReactive(input$doQualityControl, {
        source("server/climpact.etsci-functions.r")
        batchMode <<- FALSE
        
        # Set up globals in ClimPACT
        global.vars()

        # Check input file.
        file <- dataFile()
        if (is.null(file)) {
            return("Bad data file")
        }

        # Validate inputs. Are these 3 lines not already called through reactive statements elsewhere in this script?
        latitude <- stationLat()
        longitude <- stationLon()
        station <- stationName()

        base.year.start <- input$startYear
        base.year.end <- input$endYear
        outputDir <- paste("www/output/",station,sep="")

        # input$dataFile will be NULL initially. After the user selects
        # and uploads a file, it will be a data frame with 'name',
        # 'size', 'type', and 'datapath' columns. The 'datapath'
        # column will contain the local filenames where the data can
        # be found.
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message="Processing data", value=0)

        # Call into ClimPACT to do the quality control.
        error <- load.data.qc(progress, file$datapath, outputDir, latitude,
                              longitude, station,
                              base.year.start, base.year.end)
        if (error !=  "") {
          print(paste0("returning err: ",error))
            return(error)
        }

        return("")
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
      
      observeEvent(input$selectInDirBatch,{
        batchInDir <<- dchoose()
        output$inDirPrintBatch <- renderText({print(paste("Input directory: ",batchInDir,sep=""))})
      })
      
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
            need(input$instituteID,input$instituteName,message="Please specify institute name and acronym."),
            need(input$baseBegin,input$BaseEnd,message="Please specify start and end year of base period (e.g. 1990)"),
            need(input$nCores,message="Please specify number of cores to use."),
            need(input$maxVals,message="Please specify max values.")
          )

          # ------------------------------------------------------------------ #
          # Make and edit wrapper file with user preferences
          # ------------------------------------------------------------------ #
          user_wrapper_file <<- paste("climpact.ncdf.",input$instituteID,".wrapper.r",sep="")
          file.copy(master.ncdf.gridded.wrapper.file,user_wrapper_file,overwrite=TRUE)
          
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

        if(is.character(data) && !error) output$ncGriddedThreshDone <- renderText({ HTML(paste0("Done. Threshold file stored here: ",gridOutDirThresh,.Platform$file.sep,input$outFileThresh)) })
        
        enable("calculateGriddedThresholds")
      })

      startYearBatch <- reactive({
        validate(
          need(input$startYearBatch,message="Please specify start year of base period.")
        )
        input$startYearBatch
      })
      
      endYearBatch <- reactive({
        validate(
          need(input$endYearBatch,message="Please specify end year of base period.")
        )
        input$endYearBatch
      })
      
      nCoresBatch <- reactive({
        validate(
          need(input$nCoresBatch>0,message="You require a minimum of 1 core to perform this operation."),
          need(input$nCoresBatch<=detectCores(),message=paste0("You cannot select more than ",detectCores()," on this computer."))
        )
        input$nCoresBatch
      })
      
      batchMeta <- reactive({
        validate(
          need(input$batchMeta,message="Please specify the name of metadata text file (Step 1).")
        )
        input$batchMeta
      })
      
      inBatchDir <- reactive({
        validate(
          need(batchInDir,message="Please specify the input directory (Step 2).")
        )
        input$inBatchDir
      })
      
      output$ncPrintBatch <- eventReactive(input$calculateBatchIndices, {
        # ------------------------------------------------------------------ #
        # Validate inputs
        # ------------------------------------------------------------------ #
          startYearBatch <- startYearBatch()
          endYearBatch <- endYearBatch()
          BatchDir <- inBatchDir()
          batchMeta <- batchMeta()
          nCoresBatch <- nCoresBatch()
        
          tmp = read.table(input$batchMeta$datapath,header=TRUE)
          
          # Display notification before processing
          showModal(modalDialog(
            title = "Important message",
            "Your indices are being calculated. Doing this for multiple stations can take time. On a typical computer each station takes ~1 minute to process per core.",
            br(),
            br(),
            paste0("You appear to have ",nrow(tmp)," stations and have requested ",nCoresBatch," cores and so this process should take ~",nrow(tmp)/nCoresBatch," minutes to complete."),
            br(),
            br(),
            "You will see a message printed at the bottom of the screen when processing is complete.",
            paste0("In the mean time, you should start to see your output appear in ",batchInDir,"."),
            footer = modalButton("OK, thanks.")
          ))

          disable("calculateBatchIndices")
          progress <<- shiny::Progress$new()
          on.exit(progress$close())
          progress$set(message="Processing data", value=0)
          
          source("climpact.batch.stations.r")
          batchMode <<- TRUE
		      cl <<- makeCluster(nCoresBatch)

          batch(input.directory=batchInDir,file.list.metadata=input$batchMeta$datapath,base.start=input$startYearBatch,base.end=input$endYearBatch)
          enable("calculateBatchIndices")
          
          paste0("Done. Output created in ",batchInDir,". Results for each station are stored in separate directories. See *error.txt files for stations that had problems.")
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
      
    # Index calculation has been requested by the user.
    output$indiceCalculationError <- eventReactive(input$calculateIndices, {
      # ------------------------------------------------------------------ #
      # Validate inputs
      # ------------------------------------------------------------------ #
      validate(
        need(input$wsdin<=10,message="WSDId requires d to be between 0 and 10"),
        need(input$wsdin>0,message="WSDId requires d to be between 0 and 10"),
        need(input$csdin<=10,message="CSDId requires d to be between 0 and 10"),
        need(input$csdin>0,message="CSDId requires d to be between 0 and 10"),
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

        # Call into ClimPACT to calculate indices.
        error <- draw.step2.interface(progress, plot.title, wsdi_ud, csdi_ud,
                                      rx_ui, txtn_ud, rnnmm_ud, Tb_HDD, Tb_CDD,
                                      Tb_GDD, custom_SPEI, var.choice, op.choice,
                                      constant.choice)
        return("")
    })

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
    outputOptions(output, "qualityControlError", suspendWhenHidden=FALSE)
    outputOptions(output, "sectorCorrelationError", suspendWhenHidden=FALSE)

    # toggle state of buttons depending on certain criteria
    observe(toggleState('doQualityControl', !is.null(input$dataFile)))
    observe(toggleState('calculateIndices', !is.null(input$dataFile)))
    observe(toggleState('calculateSectorCorrelation', !is.null(input$dataFile) & !is.null(input$sectorDataFile)))
}
