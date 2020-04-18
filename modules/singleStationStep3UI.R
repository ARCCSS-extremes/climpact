#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep3UI <- function(id) {
  ns <- NS(id)
  return(tagList(conditionalPanel(
  condition = "output.loadDataError != ''",
  ns = ns,
  wellPanel(
    HTML("<div class= 'alert alert-warning' role='alert'>
      <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
      <span class='sr-only'></span> Please load station data.</div>"
    )
    )
  ),
  conditionalPanel(
    condition = "output.loadDataError == '' && output.qualityControlError != ''",
    ns = ns,
    wellPanel(
      HTML("<div class= 'alert alert-warning' role='alert'>
        <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
        <span class='sr-only'></span>Please check data quality.</div>"
      )
    )
  ),
  conditionalPanel(
    condition = "output.loadDataError == '' && output.qualityControlError == ''",
    ns = ns,
    wellPanel(
      h4("Provide User Parameters"),
      fluidRow(
        column(6,
          textInput(ns("plotTitle"), "Plot title:")
        )
      ),
      fluidRow(
        column(12, uiOutput(ns("loadParamHelpText")))
      ),
      wellPanel(
        fluidRow(
          column(4,
            numericInput(ns("wsdin"), "d for WSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
            bsTooltip(id = paste0(id, "-", "wsdin"), title = "Number of days contributing to a warm period (where the minimum length is user-specified) - value is the number of consecutive days", placement = "left", trigger = "hover"),
            numericInput(ns("csdin"), "d for CSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
            bsTooltip(id = paste0(id, "-", "csdin"), title = "Number of days contributing to a cold period (where the period has to be at least 6 days long) - value is the number of consecutive days", placement = "left", trigger = "hover"),
            numericInput(ns("rxnday"), "d for Rxdday Days (d >= 1):", 3, min = 1),
            bsTooltip(id = paste0(id, "-", "rxnday"), title = "Maximum amount of rain that falls in a user-specified period - value is the number of consecutive days", placement = "left", trigger = "hover"),
            numericInput(ns("txtn"), "d for TXdTNd and TXbdTNbd (d >= 1):", 2, min = 1),
            bsTooltip(id = paste0(id, "-", "txtn"), title = "Total consecutive hot days and hot nights (TXdTNd) or cold days and cold nights (TXbdTNbd) - value is the number of consecutive days", placement = "left", trigger = "hover")
          ),
          column(4,
            numericInput(ns("hdd"), "Base temperature for HDDHeat (°C):", 18),
            bsTooltip(id = paste0(id, "-", "hdd"), title = "HDDHeat: Heating Degree Days", placement = "left", trigger = "hover"),
            numericInput(ns("cdd"), "Base temperature for CDDHeat (°C):", 18),
            bsTooltip(id = paste0(id, "-", "cdd"), title = "CDDcold: Cooling Degree Days", placement = "left", trigger = "hover"),
            numericInput(ns("gdd"), "Base temperature for GDDgrow (°C):", 10),
            bsTooltip(id = paste0(id, "-", "gdd"), title = "GDDgrow: Growing Degree Days", placement = "left", trigger = "hover"),
            numericInput(ns("rnnmm"), "Number of days precip >= nn (Rnnmm; nn >= 0):", 30, min = 0),
            bsTooltip(id = paste0(id, "-", "rnnmm"), title = "Rnnmm: Number of customised rain days (when rainfall is at least user-specified number of millimetres)", placement = "left", trigger = "hover"),
            numericInput(ns("spei"), "SPEI/SPI custom monthly time scale (must be a positive number):", 24, min = 1),
            bsTooltip(id = paste0(id, "-", "spei"), title = "SPEI:Standardised Precipitation-Evapotranspiration Index. SPI:Standardized Precipitation Index ", placement = "left", trigger = "hover")
          ),
          column(4,
            wellPanel(
              h4("Specify custom thresholds"),
              strong("Custom index counting days above or below a given threshold (e.g. number of days where TX > 40, named TXgt40)"),
              br(),
              selectInput(ns("custVariable"), label = "Variable:",
                choices = list("TN", "TX", "TM", "PR", "DTR"),
                selected = "TN"
              ),
              selectInput(ns("custOperation"), label = "Operation:",
                choices = list(">", ">=", "<", "<="),
                selected = ">"
              ),
              numericInput(ns("custThreshold"), "Threshold:", 0)
            )
          )
        )
      )
    ),
    wellPanel(
      fluidRow(
        column(12,
          conditionalPanel(
            condition = "output.qualityControlError == ''",
            ns = ns,
            actionButton(ns("calculateIndices"), "Calculate Indices"),
            textOutput(ns("indexCalculationError"))
          )
        )
      ),
      fluidRow(
        column(12,
          conditionalPanel(
            condition = "output.indexCalculationError == ''",
            ns = ns,
            uiOutput(ns("indicesLink")),
            tags$ul(tags$li(HTML("The <i>plots</i> subdirectory contains an image file for each index.")),
              tags$li(HTML("The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index")),
              tags$li(HTML("The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.")),
              tags$li(HTML("The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables.")),
              tags$li(HTML("The <i>qc</i> subdirectory contains quality control diagnostic information.")),
              tags$li(HTML("If you have chosen to calculate and plot correlations ",
                "between annual sector data you supply and the indices ClimPACT has calculated, ",
                "the <i>corr</i> subdirectory will contain plots and .csv files containing the correlations.")))
          )
        )
      )
    )
  ),
  br(),
  actionButton(ns("btn_next_step_3"), label = "Next", icon = icon("chevron-circle-right"))
  ))
  observe(toggleState("btn_next_step_3", indexCalculationStatus() == "Done"))
}