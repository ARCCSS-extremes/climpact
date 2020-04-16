#' Quality control step
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep2UI <- function (id) {
  ns <- NS(id)
  return(tagList(conditionalPanel(
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
      )
    ),
    br(),
    actionButton(ns("btn_next_step_2"), label = "Next", icon = icon("chevron-circle-right"))
  ))
}