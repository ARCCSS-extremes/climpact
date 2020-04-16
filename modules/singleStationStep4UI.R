#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep4UI <- function(id) {
  ns <- NS(id)
  return(tagList(conditionalPanel(
    condition = "output.indexCalculationError == ''",
    ns = ns,
    wellPanel(h4("Load sector data"),
      fileInput(ns("sectorDataFile"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      HTML(climpactUI$sampleText,
        "<a target=\"_blank\" href=sample_data/wheat_yield_nsw_1922-1999.csv>wheat_yield_nsw_1922-1999.csv</a>"),    
      h4("Specify chart attributes"),
      textInput(ns("sectorPlotTitle"), "Chart title:"),
      textInput(ns("y_axis_label"), "Label for y axis:"),
      checkboxInput(ns("detrendCheck"), "Detrend data", value = TRUE, width = NULL)
    )),
    conditionalPanel(
        condition = "output.indexCalculationError != ''",
        ns = ns,
        wellPanel(
          HTML("<div class= 'alert alert-warning' role='alert'>
                <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
                <span class='sr-only'></span> Please complete previous step - Calculate Climate Indices.</div>")
        )
    ),
    conditionalPanel(
        condition = "output.indexCalculationError == ''",
        ns = ns,
        wellPanel(
            actionButton(ns("calculateSectorCorrelation"), "Calculate Correlations"),
            textOutput(ns("sectorCorrelationError"))
        )
    ),
    conditionalPanel(
        condition = "output.sectorCorrelationError== ''",
        ns = ns,
        wellPanel(
          HTML("<div class= 'alert alert-success show' role='alert'>
                <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
                <span class='sr-only'></span> "),
          uiOutput(ns("sectorCorrelationLink")),
          HTML("</div>")
        )
    )
  ))
}