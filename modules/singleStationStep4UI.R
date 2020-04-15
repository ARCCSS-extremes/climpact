#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep4UI <- function(id) {
  ns <- NS(id)
  return(tagList(
      fluidRow(
        column(6,
          h4("Load sector data"),
          wellPanel(
              fileInput(ns("sectorDataFile"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
              uiOutput(ns("loadSectorDataText"))
          ),
          h4("Specify chart title"),
          wellPanel(
              textInput(ns("sectorPlotName"), "Chart title:"),
              checkboxInput(ns("detrendCheck"), "Detrend data", value = TRUE, width = NULL)
          )
        )
      ),
      fluidRow(
        column(12,
          h4("Make correlation plots"),
          conditionalPanel(
              condition = "output.indiceCalculationError != ''",
              wellPanel(
                HTML("<div class= 'alert alert-warning' role='alert'>
                      <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
                      <span class='sr-only'></span> Please complete previous step - Calculate Climate Indices.</div>"
                )
              )
          ),
          conditionalPanel(
              condition = "output.indiceCalculationError == ''",
              wellPanel(
                  actionButton(ns("calculateSectorCorrelation"), "Calculate correlations"),
                  textOutput(ns("sectorCorrelationError"))
              )
          ),
          h4("View correlation"),
          conditionalPanel(
              condition = "output.sectorCorrelationError== ''",
              wellPanel(
                  uiOutput(ns("sectorCorrelationLink"))
              )
          ),
          conditionalPanel(
              condition = "output.sectorCorrelationError != ''",
              wellPanel("Correlation plots available here after calculations completed.")
          )
        )
      )
    )
  )
}