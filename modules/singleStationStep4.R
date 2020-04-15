singleStationStep4 <- function(input, output, session, climpactUI, singleStationState) {

  # sectorCorrelationChanges <- reactive({
  #   input$calculateSectorCorrelation
  # })

  # Validate sector dataset
  sectorDataFile <- reactive({
      validate(need(!is.null(input$sectorDataFile), message="Please load station data"))
      input$sectorDataFile
  })

  sectorPlotTitleMissing <- reactive({
    validate(need(input$sectorPlotName != "", message="Please enter a plot title"))
    ""
  })

  output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
    sectorPlotTitleMissing()
  })
 
  output$loadSectorDataText <- renderText({
    HTML(climpactUI$sampleText,
        "<a target=\"_blank\" href=sample_data/wheat_yield_nsw_1922-1999.csv>wheat_yield_nsw_1922-1999.csv</a>")
  })

  folderToZip <- reactiveVal("")
  corrZipLink <- reactiveVal("")
  correlationCalculationStatus <- reactiveVal("")

  output$sectorCorrelationLink <- renderText({
    if (correlationCalculationStatus() == "Done") {
      if (isLocal) {
        HTML(paste0("Correlation output has been created. ",
                    "Please view the output in the following directory: <br /><br /><b>",
                    folderToZip, "</b>"))
      } else {
        HTML(paste0("<div class= 'alert alert-success' role='alert'>
                    <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                    " Correlation output available ", corrZipLink, "</div>"))
      }
    }
  })

  # React to upload
  observeEvent(input$sectorDataFile, {
    val <- strsplit(input$sectorDataFile$name, "[_\\.]")[[1]][1]
    updateTextInput(session, "sectorPlotName", value=val)
  })

  # Handle calculation of correlation between climate/sector data
  output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {

    if (is.null(singleStationState$dataFile())) { return("Data file not provided.") }

    plotTitleMissing()

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message="Calculating correlation", value=0)

    correlationCalculationStatus("In Progress")

    error <- draw.correlation(progress,
                              singleStationState$dataFile()$datapath,
                              sectorDataFile()$datapath,
                              singleStationState$stationName(),
                              input$sectorPlotName,
                              input$detrendCheck)

    if (error == "") {
      # zip files and get link
      folderToZip(singleStationState$outputFolders()$corrdir)
      pathToZipFile <- zipFiles(folderToZip())
      corrZipLink(getLinkFromPath(pathToZipFile, "here"))
      correlationCalculationStatus("Done")
      return("")
    } else {
      correlationCalculationStatus("Error")
      return(error)
    }
  })

  observe(toggleState("calculateSectorCorrelation", !is.null(input$dataFile) & !is.null(input$sectorDataFile)))

  outputOptions(output, "sectorCorrelationError", suspendWhenHidden=FALSE)

}