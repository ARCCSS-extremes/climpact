batchStep1 <- function(input, output, session, climpactUI) {

  # now batchData
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

  batchData <- reactive({
    validate(
      need(input$batchData, message = "Please upload files to process (Step 2).")
    )
    input$batchData
  })
  
  batchZipFilePath <- reactiveVal("")
  batchZipLink <- reactiveVal("")

  batchProcessingModal <- function(msg) {
    ns <- session$ns
    localMessage <- ""
    if (isLocal) {
      localMessage <- HTML("<p>Doing this for multiple stations can take some time. ",
        "On a typical computer each station takes ~1 minute to process per core.</p>", msg)
    }

    modalDialog(title = "Important message",
      HTML("<p>Your indices will be calculated after closing this window.</p>", localMessage,
        "<p>You will see a message displayed on screen when processing is complete.</p>"),
      # paste0("In the meantime, you should start to see your output appear in ",batchInDir,"."),
      footer = tagList(modalButton("Cancel"), actionButton(ns("ok"), "OK"))
    )
  }

  # handle calculateBatchIndices click
  observeEvent(input$calculateBatchIndices, {

    # ------------------------------------------------------------------ #
    # Validate inputs
    # ------------------------------------------------------------------ #
    startYearBatch <- startYearBatch()
    endYearBatch <- endYearBatch()
    batchData <- batchData()
    batchMeta <- batchMeta()

    if (isLocal) {
      nCoresBatch <- nCoresBatch()
      tmp <- read.table(input$batchMeta$datapath, header = TRUE)
      modalMessage <- HTML("<p>You appear to have ", nrow(tmp), " stations and have requested ",
        nCoresBatch, " cores and so this process should take ~", nrow(tmp) / nCoresBatch, " minutes to complete.</p>")
    }
    # Display notification before processing
    showModal(batchProcessingModal(modalMessage))
  })

  # handle modal window ok button click
  observeEvent(input$ok, {
    removeModal()
    disable("calculateBatchIndices")

    progress <<- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Processing data", value = 0.01)

    nCoresBatch <- nCoresBatch()
    source("climpact.batch.stations.r")

    # cat(file=stderr(), "input$batchMeta$datapath:", input$batchMeta$datapath, "\n")
    # assign("file.list.metadata.global",input$batchMeta$datapath,envir=.GlobalEnv)
    # cat(file=stderr(), "file.list.metadata.global:", file.list.metadata.global, "\n")

    batchMode <- TRUE
    cl <- makeCluster(nCoresBatch)

    cat(file = stderr(), "about to call testvariables___ functions.", "\n")
    # Assign value with <<- operator as we are calling out of a reactive function
    metadatafilepath <- input$batchMeta$datapath
    metadatafilename <- input$batchMeta$name
    batchfiles <- input$batchData

    # This function is where the work is done
    zipPath <- batch(metadatafilepath, metadatafilename, batchfiles, input$startYearBatch, input$endYearBatch)
    batchZipLink(getLinkFromPath(zipPath, "here"))
    batchZipFilePath(zipPath)

    enable("calculateBatchIndices")
  })

  output$batchLink <- renderText({
    localLink <- paste0("Batch files directory: <b>", batchZipFilePath(), "</b>")
    remoteLink <- paste0("<div class= 'alert alert-info' role='alert'>",
        "<span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
        "Please view the output: ", batchZipFileLink(), "</div>")

    HTML("Batch output has been created. ", localOrRemoteLink(localLink, remoteLink))

  })

  observe(toggleState("calculateBatchIndices", !is.null(input$batchMeta) && !is.null(input$batchData)))
}
