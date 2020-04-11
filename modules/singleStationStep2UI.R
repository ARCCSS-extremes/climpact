#' Quality control step
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep2UI <- function (id) {
  ns <- NS(id)
  return(tagList(
            htmlOutput(ns("dataFileLoadedWarning")),
            conditionalPanel(
                condition = "output.dataFileLoadedWarning != ''",
                ns = ns,
                wellPanel(
                    HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span> Please load a dataset</div>")
                )
            ),
            conditionalPanel(
                condition = "output.dataFileLoadedWarning == ''",
                ns = ns,
                wellPanel(
                    actionButton(ns("doQualityControl"), "Check Quality"),
                    htmlOutput(ns("qualityControlError"))
            ),
            conditionalPanel(
                condition = "output.qualityControlError == ''",
                ns = ns,
                wellPanel(h4("Evaluate Quality Control output"),
                    uiOutput(ns("qcLink"))
                )
            )
        ),
        br(),
        actionButton(ns("btn_next_process_single_station_step_2"), label = "Next", icon = icon("chevron-circle-right"))
  )
  )
}