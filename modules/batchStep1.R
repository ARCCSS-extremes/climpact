batchStep1 <- function(input, output, session, climpactUI) {

  output$batchIntroText <- renderText({
    HTML("A text file must be created with information describing each station that you will provide as input data.",
        "<br> Refer to <a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#batch>section 5</a>",
        " of the user guide and use ",
        "<a target=\"_blank\" href=sample_data/climpact.sample.batch.metadata.txt>this file</a>",
        " as a template.")
  })

  output$batchFolderText <- renderText({
    HTML("Select all the ClimPACT formatted station text files that you would like to process",
      " from the dialog window that opens when you click Browse...<br />",
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
  batchZipFileLink <- reactiveVal("")

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

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Processing data", value = 0.01)

    source("server/batch_stations.R")

    # nCoresBatch <- nCoresBatch()
    # batchMode <- TRUE
    # cl <- makeCluster(nCoresBatch)
    # cl could be used within batch, just need to pass the info into batch() function

    metadatafilepath <- input$batchMeta$datapath
    metadatafilename <- input$batchMeta$name

    folderName <- strip_file_extension(metadatafilename)
    folderToZip(file.path(getwd(), "www", "output", folderName))

    # This function is where the work is done
    zipPath <- batch(progress, metadatafilepath, input$batchData, input$startYearBatch, input$endYearBatch, folderToZip())
    batchZipFilePath(zipPath)
    batchZipFileLink(getLinkFromPath(zipPath, "here"))

    enable("calculateBatchIndices")
  })

  folderToZip <- reactiveVal("")

  output$batchLink <- renderText({
    if (batchZipFileLink() != "") {
      if (isLocal) {
        HTML("<b>Batch output</b>",
        "<p>Please view the output in the following directory: <br /><b>", folderToZip(), "</b></p>")
      } else {
        HTML("<b>Batch output</b>",
        "<p>Batch output available: ", batchZipFileLink(), "</p>")
      }
    }
  })
  outputOptions(output, "batchLink", suspendWhenHidden = FALSE)
  observe(toggleState("calculateBatchIndices", !is.null(input$batchMeta) && !is.null(input$batchData)))
}
