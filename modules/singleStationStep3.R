singleStationStep3 <- function(input, output, session, climpactUI, singleStationState) {

  indexCalculationStatus <- reactiveVal("Not Started")

  output$qualityControlErrorStep3 <- reactive ({
    errorHTML <- ""
    if (singleStationState$qualityControlErrors() != "") {
      errorHTML <- HTML("<br /><div class= 'alert alert-danger' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span></div>")
    }
    return(errorHTML)
  })

  plotTitleMissing <- reactive({
    validate(
      need(input$plotTitle != "", message="Please enter a plot title")
    )
    ""
  })

  # Index calculation has been requested by the user.
  output$indiceCalculationError <- eventReactive(input$calculateIndices, {
    # ------------------------------------------------------------------ #
    # Validate inputs
    # ------------------------------------------------------------------ #
    validate(
        need(input$wsdin <= 10, message = "WSDId requires d to be between 1 and 10"),
        need(input$wsdin > 0, message = "WSDId requires d to be between 1 and 10"),
        need(input$csdin <= 10, message = "CSDId requires d to be between 1 and 10"),
        need(input$csdin > 0, message = "CSDId requires d to be between 1 and 10"),
        need(input$rxnday >= 1, message = "RXnDAY requires n to be a positive number"),
        need(input$txtn >= 1, message = "TXdTNd and TXbdTNbd requires d to be a positive number"),
        need(input$rnnmm >= 0, message = "Rnnmm requires nn to be greater than or equal to zero"),
        need(input$spei >= 1, message = "Custom SPEI/SPI time scale must be a positive number")
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
    progress$set(message = "Calculating indices", value = 0)

    indexCalculationStatus("In Progress")

    error <- draw.step2.interface(progress, singleStationState$climdexInput(), 
                                  plot.title, wsdi_ud, csdi_ud,
                                  rx_ui, txtn_ud, rnnmm_ud, Tb_HDD, Tb_CDD,
                                  Tb_GDD, custom_SPEI, var.choice, op.choice,
                                  constant.choice, singleStationState$outputFolders)
    
    indexCalculationStatus("Done")
    return("")
  })

    # and calls the index functions for calculation and plotting.
    # This function houses the beginning screen for "Step 2" in the GUI (i.e. calculating the indices). It reads in user preferences for the indices
  draw.step2.interface <- function(progress, singleStationState, plot.title, wsdi_ud, csdi_ud, rx_ud, txtn_ud, rnnmm_ud, Tb_HDD, Tb_CDD, Tb_GDD, custom_SPEI, var.choice, op.choice, constant.choice) {
    # TODO remove globalvars
    # assign('plot.title', plot.title, envir = .GlobalEnv)

    # assign("wsdi_ud", as.double(wsdi_ud), envir = .GlobalEnv) # wsdi wsdi_ud
    # assign("csdi_ud", as.double(csdi_ud), envir = .GlobalEnv) #  csdi_ud
    # assign("rx_ud", as.double(rx_ud), envir = .GlobalEnv) # 14 rx_ud
    # assign("txtn_ud", as.double(txtn_ud), envir = .GlobalEnv) # txtn_ud
    # assign("rnnmm_ud", as.double(rnnmm_ud), envir = .GlobalEnv) # txtn_ud
    # assign("Tb_HDD", as.double(Tb_HDD), envir = .GlobalEnv) # Tb for HDDheat
    # assign("Tb_CDD", as.double(Tb_CDD), envir = .GlobalEnv) # Tb for HDDcold
    # assign("Tb_GDD", as.double(Tb_GDD), envir = .GlobalEnv) # Tb for HDDgrow
    # assign("custom_SPEI", as.double(custom_SPEI), envir = .GlobalEnv) # custom SPEI/SPI time period

    # assign("var.choice", var.choice, envir = .GlobalEnv)
    # assign("op.choice", op.choice, envir = .GlobalEnv)
    # assign("constant.choice", constant.choice, envir = .GlobalEnv)

    metadata <- create_metadata(singleStationState$latitude, singleStationState$longitude, singleStationState$startYear, singleStationState$endYear, user.data.ts$dates, singleStationState$stationName)

    index.calc(progress, metadata, singleStationState$cio, singleStationState$outputFolders)

    # TODO - refactor to use common zipFiles function that is currently in server.R
    # Create a zip file containing all of the results.
    curwd <- getwd()
    setwd(outputFolders$baseFolder)
    filesToZip <- dir(basename(outputFolders$outdirtmp), full.names = TRUE)
    zipfilename <- basename(outputFolders$outdirtmp)
    zip(zipfile = zipfilename, files = filesToZip)
    setwd(curwd)
  }
  # end of draw.step2.interface

  output$indicesLink <- renderText({
    if (indexCalculationStatus() == "Done") {
      browser()
      # zip files and get link
      folderToZip <- file.path(getwd(), outinddir)
      pathToZipFile <- zipFiles(folderToZip)
      indicesZipLink <- getLinkFromPath(pathToZipFile, "here")
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

  outputOptions(output, "indiceCalculationError", suspendWhenHidden = FALSE)
  # observeEvent(indexCalculationStatus(), {
  #   if (indexCalculationStatus()=="Done") {
  #     session$sendCustomMessage("enableTab", "process_single_station_step_4")
  #   }
  # })

  # must use = not <- to get named values in list()
  return(list(singleStationState = singleStationState))
}