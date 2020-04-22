#' Quality control step
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep2UI <- function (id) {
  ns <- NS(id)
  return(tagList(fluidRow(
    column(8,
      conditionalPanel(
        condition = "output.loadDataError != ''",
        ns = ns,
        wellPanel(htmlOutput(ns("loadDataError")))
      ),
      conditionalPanel(
        condition = "output.loadDataError == ''",
        ns = ns,
        conditionalPanel(
          condition = "output.qcStatus != 'Not Started'",
          ns = ns,
          slickROutput(ns("slickr"), width="640px")
        ),
        wellPanel(actionButton(ns("doQualityControl"), "Check Data Quality"),
          htmlOutput(ns("qualityControlError"))
        )
      ),
      br(),
      actionButton(ns("btn_next_step_2"), label = "Next", icon = icon("chevron-circle-right"))
    ),
    column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("Check Data Quality"),
        tags$p("Click 'Check Quality' button. ClimPACT will commence quality control checks."),
        tags$p("Once processing is complete you can view quality control plots and you will be provided with a link to ",
          "the quality control diagnostics output that ClimPACT has produced."),
        tags$p("It is recommended that you inspect the output to ensure no errors are present in the station data."),
        conditionalPanel(
          condition = "output.qcLink != ''",
          ns = ns,
          uiOutput(ns("qcLink"))
        )
      )
    )
    )
  ))
  observe(toggleState('btn_next_step_2', !is.null(input$dataFile) && qualityControlErrorText()==''))
}