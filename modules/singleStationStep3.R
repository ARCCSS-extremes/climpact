singleStationStep3 <- function(input, output, session, parentSession, climpactUI, singleStationState) {

  output$slickRIndices <- renderSlickR({
    imgs <- list()
    if (!is.null(singleStationState$outputFolders())) {
      watchPath <- singleStationState$outputFolders()$outplotsdir
      imgs <- list.files(watchPath, pattern=".png", full.names = TRUE)
    }
    bottom_opts <- settings(arrows = FALSE, slidesToShow = 5, slidesToScroll = 1, centerMode = TRUE, focusOnSelect = TRUE, initialSlide = 0)
    main <- slickR(imgs, slideId = "slickRIndicesMain", height = 600)
    nav <-  (slickR(imgs, slideId = "slickRIndicesNav", height = 100) + bottom_opts)
    main %synch% nav
  })

  singleStationState$indexCalculationStatus <- reactiveVal("Not Started")
  folderToZip <- reactiveVal("")
  indicesZipLink <- reactiveVal("")

  observeEvent(singleStationState$metadata(), {
    updateTextInput(session, "plotTitle", value=singleStationState$metadata()$title.station)
  })

  output$qualityControlErrorStep3 <- reactive({
    errorHTML <- ""
    if (singleStationState$qualityControlErrors() != "") {
      errorHTML <- HTML("<br /><div class= 'alert alert-danger' role='alert'>
                        <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span></div>")
    }
    return(errorHTML)
  })

  output$loadParamHelpText <- renderUI({
      indexParamLink <- paste0("<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#calculate_indices> Section 3.3</a>")
      HTML(paste0("<p>The following fields change user-definable parameters in several ClimPACT indices.",
                  "<br />Leave as default unless you are interested in these indices. See ",
                  indexParamLink, " of the ", climpactUI$userGuideLink, " for guidance.</p>"))
  })

  output$indexCalculationError <- reactive({
    # currently always ""
    input$dataFile # trigger refresh on update
    singleStationState$indexCalculationErrors()
  })

  output$indexCalculationStatus <- reactive({
    input$dataFile # trigger refresh on update
    singleStationState$indexCalculationStatus()
  })

  # Index calculation has been requested by the user.
  observeEvent(input$calculateIndices, {
    # ------------------------------------------------------------------ #
    # Validate inputs
    # ------------------------------------------------------------------ #
    validate(
        need(input$plotTitle != "", message = "Please enter a plot title"),
        need(input$wsdin <= 10, message = "WSDId: value must be between 1 and 10"),
        need(input$wsdin > 0, message = "WSDId: value must be between 1 and 10"),
        need(input$csdin <= 10, message = "CSDId: value must be between 1 and 10"),
        need(input$csdin > 0, message = "CSDId: value must be between 1 and 10"),
        need(input$rxnday >= 1, message = "RXnDAY: value must be a positive number"),
        need(input$txtn >= 1, message = "TXdTNd and TXbdTNbd: value must be a positive number"),
        need(input$rnnmm >= 0, message = "Rnnmm: value must be greater than or equal to zero"),
        need(input$spei >= 1, message = "Custom SPEI/SPI time scale value must be a positive number")
    )

    disable("calculateIndices")

    params <- climdexInputParams(wsdi_ud          = input$wsdin,
                                  csdi_ud         = input$csdin,
                                  rx_ud           = input$rxnday,
                                  txtn_ud         = input$txtn,
                                  Tb_HDD          = input$hdd,
                                  Tb_CDD          = input$cdd,
                                  Tb_GDD          = input$gdd,
                                  rnnmm_ud        = input$rnnmm,
                                  custom_SPEI     = input$spei,
                                  var.choice      = input$custVariable,
                                  op.choice       = input$custOperation,
                                  constant.choice = input$custThreshold
                                  )
    singleStationState$climdexInputParams(params)

    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Calculating indices", value = 0)

    singleStationState$indexCalculationStatus("In Progress")
    # singleStationState$indexCalculationErrors("")

    index.calc(progress, 2, singleStationState$metadata(),
      singleStationState$climdexInput(), singleStationState$outputFolders(),
      singleStationState$climdexInputParams())

    # Create a zip file containing all of the results.
    folderToZip(singleStationState$outputFolders()$outputdir)
    pathToZipFile <- zipFiles(folderToZip(), excludePattern = "*.zip",
      destinationFolder = singleStationState$outputFolders()$baseFolder,
      destinationFileName = singleStationState$stationName())
    indicesZipLink(getLinkFromPath(pathToZipFile, "here"))

    enable("calculateIndices")
    # singleStationState$indexCalculationErrors("")
    singleStationState$indexCalculationStatus("Done")
  })

  output$indicesLink <- renderText({
    if (singleStationState$indexCalculationStatus() == "Done") {
      if (isLocal) {
        HTML("<b>Calculated Indices</b><br /><p>Please view the output in the following directory: <b>", folderToZip(), "</b></p>")
      } else {
        HTML("<b>Calculated Indices</b><br /><p>Calculated Indices available ", indicesZipLink(), "</p>")
      }
    } else {
      ""
    }
  })

  observeEvent(singleStationState$indexCalculationStatus(), {
    if (singleStationState$indexCalculationStatus() == "Done") {
      session$sendCustomMessage("enableTab", "process_single_station_step_4")
    }
  })

  observeEvent(input$btn_next_step_3, {
    tabName <- "process_single_station_step_4"
    session$sendCustomMessage("enableTab", tabName)
    updateTabsetPanel(parentSession, "process_single_station", selected = tabName)
  })

  outputOptions(output, "indexCalculationError", suspendWhenHidden = FALSE)
  outputOptions(output, "indexCalculationStatus", suspendWhenHidden = FALSE)
  outputOptions(output, "slickRIndices", suspendWhenHidden = TRUE) # otherwise renders incorrectly initially

  observe(toggleState("btn_next_step_3", singleStationState$indexCalculationStatus() == "Done"))

  return(list(singleStationState = singleStationState))
}