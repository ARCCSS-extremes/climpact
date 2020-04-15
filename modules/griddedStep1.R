griddedStep1 <- function(input, output, session, climpactUI) {

      observeEvent(input$selectNcFiles,{
        gridNcFiles <<- fchoose(filters=ncFilter)
        output$ncFilePrint <- renderText({print(paste0("Input file(s): ",paste0(gridNcFiles,collapse=", ")))})
      })

      observeEvent(input$selectOutDir,{
        gridOutDir <<- dchoose()
        output$outDirPrint <- renderText({print(paste("Output directory: ",gridOutDir,sep=""))})
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

}