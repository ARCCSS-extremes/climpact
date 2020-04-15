batchStep1 <- function(input, output, session, climpactUI) {

  # now batchCsvs
  # observeEvent(input$selectInDirBatch,{
  #   batchInDir <<- dchoose()
  #   output$inDirPrintBatch <- renderText({print(paste("Input directory: ",batchInDir,sep=""))})
  # })

  output$batchIntroText <- renderText({
    HTML("A text file must be created with information for each station. Refer to ",
                "<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#batch>section 5</a>",
                " of the user guide and use ",
                "<a target=\"_blank\" href=sample_data/climpact.sample.batch.metadata.txt>this file</a>",
                " as a template. Once done supply ClimPACT with the file below.")
  })

  output$batchFolderText <- renderText({
    HTML("Select all the ClimPACT formatted station text files that you would like to process",
      " from the dialog window that opens when you click Browse... below.<br />",
      "These must be formatted according to ", climpactUI$appendixBLink, " of the user guide.<br />")
  })

  startYearBatch <- reactive({
    validate(
      need(input$startYearBatch, message = "Please specify start year of base period.")
    )
    input$startYearBatch
  })

  endYearBatch <- reactive({
    validate(
      need(input$endYearBatch, message = "Please specify end year of base period.")
    )
    input$endYearBatch
  })

  nCoresBatch <- reactive({
    validate(
      need(input$nCoresBatch > 0, message = "You require a minimum of 1 core to perform this operation."),
      need(input$nCoresBatch <= detectCores(), message = paste0("You cannot select more than ", detectCores(), " on this computer."))
    )
    input$nCoresBatch
  })

  batchMeta <- reactive({
    validate(
      need(input$batchMeta, message = "Please specify the name of metadata text file (Step 1).")
    )
    input$batchMeta
  })

  batchCsvs <<- reactive({
    validate(
      need(input$batchCsvs, message = "Please upload files to process (Step 2).")
    )
    input$batchCsvs
  })

  batchProcessingModal <- function(msg) {
    modalDialog(
      title = "Important message",
      paste0("Your indices will be calculated after closing this window.",
        " Doing this for multiple stations can take time. On a typical computer each station takes ~1 minute to process per core."),
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

    batchMode <- TRUE
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
    batchZipFilePath <- batch(metadatafilepath, metadatafilename, batchfiles, input$startYearBatch, input$endYearBatch)
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

    modalMessage <- paste0("You appear to have ", nrow(tmp)," stations and have requested ",
                            nCoresBatch, " cores and so this process should take ~", nrow(tmp)/nCoresBatch, " minutes to complete.")
    # Display notification before processing
    showModal(batchProcessingModal(modalMessage))


  })

  observe(toggleState("calculateBatchIndices", !is.null(input$batchMeta) && !is.null(input$batchCsvs)))
}