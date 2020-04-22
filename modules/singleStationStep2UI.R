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
        wellPanel(actionButton(ns("doQualityControl"), "Check Quality"),
          htmlOutput(ns("qualityControlError"))
        ),
        conditionalPanel(
          condition = "output.qcLink != ''",
          ns = ns,
          wellPanel(h4("Evaluate Quality Control output"),
            uiOutput(ns("qcLink"))
          )
        ),
        conditionalPanel(
          condition = "output.qcLink != ''",
          ns = ns,
          slickROutput(ns("slickr"), width="500px")
        )
      ),
      br(),
      actionButton(ns("btn_next_step_2"), label = "Next", icon = icon("chevron-circle-right"))
    ),
        column(4, class = "instructions",
        box(title = "Instructions", width = 12,
          h4("Check Quality"),
          tags$p("Click 'Check Quality' button. ClimPACT will commence quality control checks."),
          tags$p("Once processing is complete you will be provided with a link to ",
            "the quality control diagnostics output that ClimPACT has produced."),
          tags$p("It is recommended that you inspect the output to ensure no errors are present in the station data.")
        )
      )
    )
  ))
  observe(toggleState('btn_next_step_2', !is.null(input$dataFile) && qualityControlErrorText()==''))
}