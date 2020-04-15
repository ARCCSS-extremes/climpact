singleStationStep3 <- function(input, output, session, climpactUI, singleStationState) {

  indexCalculationStatus <- reactiveVal("Not Started")

  output$qualityControlErrorStep3 <- reactive({
    errorHTML <- ""
    if (singleStationState$qualityControlErrors() != "") {
      errorHTML <- HTML("<br /><div class= 'alert alert-danger' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span></div>")
    }
    return(errorHTML)
  })

  folderToZip <- reactiveVal("")
  indicesZipLink <- reactiveVal("")

  # Index calculation has been requested by the user.
  output$indexCalculationError <- eventReactive(input$calculateIndices, {
    # ------------------------------------------------------------------ #
    # Validate inputs
    # ------------------------------------------------------------------ #
    validate(
        need(input$plotTitle != "", message = "Please enter a plot title"),
        need(input$wsdin <= 10, message = "WSDId requires d to be between 1 and 10"),
        need(input$wsdin > 0, message = "WSDId requires d to be between 1 and 10"),
        need(input$csdin <= 10, message = "CSDId requires d to be between 1 and 10"),
        need(input$csdin > 0, message = "CSDId requires d to be between 1 and 10"),
        need(input$rxnday >= 1, message = "RXnDAY requires n to be a positive number"),
        need(input$txtn >= 1, message = "TXdTNd and TXbdTNbd requires d to be a positive number"),
        need(input$rnnmm >= 0, message = "Rnnmm requires nn to be greater than or equal to zero"),
        need(input$spei >= 1, message = "Custom SPEI/SPI time scale must be a positive number")
    )

    # Get inputs.
    plot.title <- input$plotTitle
    params <- climdexInputParams(wsdi_ud <- input$wsdin,
                                  csdi_ud <- input$csdin,
                                  rx_ud <- input$rxnday,
                                  txtn_ud <- input$txtn,
                                  Tb_HDD <- input$hdd,
                                  Tb_CDD <- input$cdd,
                                  Tb_GDD <- input$gdd,
                                  rnnmm_ud <- input$rnnmm,
                                  custom_SPEI <- input$spei,
                                  var.choice <- input$custVariable,
                                  op.choice <- input$custOperation,
                                  constant.choice <- input$custThreshold
                                )
    singleStationState$climdexInputParams(params)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Calculating indices", value = 0)

    indexCalculationStatus("In Progress")

    index.calc(progress, singleStationState$metadata(), singleStationState$climdexInput(), singleStationState$outputFolders(), singleStationState$climdexInputParams())
    # Create a zip file containing all of the results.
    folderToZip(singleStationState$outputFolders()$outputdir)
    pathToZipFile <- zipFiles(folderToZip(), excludePattern = "*.zip")
    indicesZipLink(getLinkFromPath(pathToZipFile, "here"))

    indexCalculationStatus("Done")
    return("")
  })

  output$indicesLink <- renderText({
    if (indexCalculationStatus() == "Done") {
      if (isLocal) {
        HTML(paste0("<p>Please view the output in the following directory: <b>", folderToZip(), "</b></p>"))
      } else {
        HTML(paste0("<div class= 'alert alert-success' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span>",
                              " Calculated Indices available ", indicesZipLink(), "</div>"))
      }
    }
  })

  outputOptions(output, "indexCalculationError", suspendWhenHidden = FALSE)
  observeEvent(indexCalculationStatus(), {
    if (indexCalculationStatus()=="Done") {
      session$sendCustomMessage("enableTab", "process_single_station_step_4")
    }
  })

  # must use = not <- to get named values in list()
  return(list(singleStationState = singleStationState))
}