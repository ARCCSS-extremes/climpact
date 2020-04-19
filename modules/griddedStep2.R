griddedStep2 <- function(input, output, session, climpactUI) {

      observeEvent(input$selectNcFilesThresh,{
        gridNcFilesThresh <<- fchoose(filters=ncFilter)
        output$ncFilePrintThresh <- renderText({print(paste0("Input file(s): ",paste0(gridNcFilesThresh,collapse=", ")))})
      })

      observeEvent(input$selectOutDirThresh,{
        gridOutDirThresh <<- dchoose()
        output$outDirPrintThresh <- renderText({print(paste("Output directory: ",gridOutDirThresh,sep=""))})
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
              actionButton("proceedGriddedThresh", "Calculate Thresholds")
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

}