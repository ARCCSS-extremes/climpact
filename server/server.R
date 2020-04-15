server <- function(input, output, session) {
  # Everything within this function is instantiated separately for each session.
  # REF: https://shiny.rstudio.com/articles/scoping.html

  source("server/session_vars.R", local = TRUE) # local req'd to use input, output, session
  source("models/stationWizardState.R", local = TRUE)
  singleStationState <- stationWizardState()

  # these were originally sourced in singleStationStep2.R
  # seeing if it works with them sourced here
  source("server/climpact.GUI-functions.r")
  source("server/quality_control_checks.r")
  source("server/quality_control/quality_control.r")
  source("models/outputFolders.R")
  source("services/calculate_indices.R")
  # modules called with second parameter being namespace id for corresponding UI
  # climpactUI from ui_support.R, sourced in app.R
  stationStep1 <- callModule(singleStationStep1, climpactUI$ns, singleStationState)
  stationStep2 <- callModule(singleStationStep2, climpactUI$ns, climpactUI, stationStep1$singleStationState)
  stationStep3 <- callModule(singleStationStep3, climpactUI$ns, climpactUI, stationStep2$singleStationState)
  stationStep4 <- callModule(singleStationStep4, climpactUI$ns, climpactUI, stationStep3$singleStationState)
  griddedStep1 <- callModule(griddedStep1, climpactUI$ns)
  batchStep1 <- callModule(batchStep1, climpactUI$ns)

  output$griddedMenuItem <- renderMenu({
    if (isLocal) {
      menuItem("Gridded data", tabName = "gridded", icon = icon("cube"),
        menuSubItem("Calculate Gridded Indices", tabName = "gridded-indices", icon = icon("cube")),
        menuSubItem("Calculate Gridded Thresholds", tabName = "gridded-thresholds", icon = icon("cube"))
      )
    }
  })

  output$loadParamHelpText <- renderText({
      indexParamLink <- paste0("<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#calculate_indices> Section 3.3</a>")
      HTML(paste0("The following fields change user-definable parameters in several ClimPACT indices. Leave as default unless you are interested
                  in these indices. See ", indexParamLink, " of the ", climpactUI$userGuideLink, " for guidance."))
  })

  # output$sliders <- renderUI({
  #   numStations <- as.integer(input$nStations)
  #   lapply(1:numStations, function(i) {
  #     fluidRow(
  #       column(1,
  #             textInput("stationFile", "Station filename:")
  #       ),
  #       column(1,
  #             textInput("stationLat", "Latitude of station:")
  #       ),
  #         uiOutput("sliders")
  #       )
  #   })
  # })

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

    # toggle state of buttons depending on certain criteria
    # Single station
    # observe(toggleState('btn_next_step_1', !is.null(input$dataFile)))
    # observe(toggleState('btn_next_step_2', !is.null(input$dataFile) && qualityControlErrorText()==''))
    # observe(toggleState('btn_next_step_3', indexCalculationStatus()=='Done'))

    # observe(toggleState('doQualityControl', !is.null(input$dataFile)))
    # observe(toggleState('calculateIndices', !is.null(input$dataFile)))


    observeEvent(input$btn_next_step_1, {
      tabName <- "process_single_station_step_2"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })

    observeEvent(input$btn_next_step_2, {
      tabName <- "process_single_station_step_3"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })
    
    observeEvent(input$btn_next_step_3, {
      tabName <- "process_single_station_step_4"
      session$sendCustomMessage("enableTab", tabName)
      updateTabsetPanel(session, "process_single_station", selected = tabName)
    })

    # observeEvent(qualityControlErrorText(), {
    #   session$sendCustomMessage("enableTab", "process_single_station_step_3")
    # })

}
