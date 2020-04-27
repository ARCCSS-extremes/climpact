server <- function(input, output, session) {

  # Everything within this function is instantiated separately for each session.
  # REF: https://shiny.rstudio.com/articles/scoping.html
  source("models/outputFolders.R")
  source("server/climpact.GUI-functions.r")
  source("services/quality_control_checks.R")
  source("services/calculate_indices.R")

  source("models/stationWizardState.R", local = TRUE)
  singleStationState <- stationWizardState()

  # modules called with second parameter being namespace id for corresponding UI
  # climpactUI from ui_support.R, sourced in app.R
  # passing session here so that modules can update tabSetPanel/tabBox (value = "process_single_station") in this session
  stationStep1 <- callModule(singleStationStep1, climpactUI$ns, session, singleStationState)
  stationStep2 <- callModule(singleStationStep2, climpactUI$ns, session, climpactUI, stationStep1$singleStationState)
  stationStep3 <- callModule(singleStationStep3, climpactUI$ns, session, climpactUI, stationStep2$singleStationState)
  stationStep4 <- callModule(singleStationStep4, climpactUI$ns, climpactUI, stationStep3$singleStationState)
  batchStep1   <- callModule(batchStep1, climpactUI$ns, climpactUI)
  if (isLocal) {
    griddedStep1 <- callModule(griddedStep1, climpactUI$ns, climpactUI)
    griddedStep2 <- callModule(griddedStep2, climpactUI$ns, climpactUI)
    output$griddedMenuItem <- renderMenu({
      if (isLocal) {
        menuItem("Gridded data", tabName = "gridded", icon = icon("cube"),
          menuSubItem("Calculate Gridded Indices", tabName = "gridded-indices", icon = icon("cube")),
          menuSubItem("Calculate Gridded Thresholds", tabName = "gridded-thresholds", icon = icon("cube"))
        )
      }
    })
  }

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
}
