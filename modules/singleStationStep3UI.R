#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep3UI <- function (id) {
  ns <- NS(id)
  return(tagList(conditionalPanel(
                    condition = "output.qualityControlError != ''",
                    wellPanel(HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span> Please check data quality</div>"))
                ),
                conditionalPanel(
                    condition = "output.qualityControlError == ''",
                    wellPanel(
                        h4("Provide User Parameters"),
                        fluidRow(
                            column(6,
                                textInput("plotTitle", "Plot title:")
                            )
                        ),
                        fluidRow(
                            column(12, uiOutput("loadParamHelpText"))
                        ),
                        wellPanel(
                            fluidRow(
                                column(4,
                                    numericInput("wsdin", "d for WSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
                                    bsTooltip(id = "wsdin", title = "Number of days contributing to a warm period (where the minimum length is user-specified) - value is the number of consecutive days", placement = "left", trigger = "hover"),
                                    numericInput("csdin", "d for CSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
                                    bsTooltip(id = "csdin", title = "Number of days contributing to a cold period (where the period has to be at least 6 days long) - value is the number of consecutive days", placement = "left", trigger = "hover"),
                                    numericInput("rxnday", "d for Rxdday Days (d >= 1):", 3, min = 1),
                                    bsTooltip(id = "rxnday", title = "Maximum amount of rain that falls in a user-specified period - value is the number of consecutive days", placement = "left", trigger = "hover"),
                                    numericInput("txtn", "d for TXdTNd and TXbdTNbd (d >= 1):", 2, min = 1),
                                    bsTooltip(id = "txtn", title = "Total consecutive hot days and hot nights (TXdTNd) or cold days and cold nights (TXbdTNbd) - value is the number of consecutive days", placement = "left", trigger = "hover")
                                ),
                                column(4,
                                    numericInput("hdd", "Base temperature for HDDHeat (°C):", 18),
                                    bsTooltip(id = "hdd", title = "HDDHeat: Heating Degree Days", placement = "left", trigger = "hover"),
                                    numericInput("cdd", "Base temperature for CDDHeat (°C):", 18),
                                    bsTooltip(id = "cdd", title = "CDDcold: Cooling Degree Days", placement = "left", trigger = "hover"),
                                    numericInput("gdd", "Base temperature for GDDgrow (°C):", 10),
                                    bsTooltip(id = "gdd", title = "GDDgrow: Growing Degree Days", placement = "left", trigger = "hover"),
                                    numericInput("rnnmm", "Number of days precip >= nn (Rnnmm; nn >= 0):", 30, min = 0),
                                    bsTooltip(id = "rnnmm", title = "Rnnmm: Number of customised rain days (when rainfall is at least user-specified number of millimetres)", placement = "left", trigger = "hover"),
                                    numericInput("spei", "SPEI/SPI custom monthly time scale (must be a positive number):", 24, min = 1),
                                    bsTooltip(id = "spei", title = "SPEI:Standardised Precipitation-Evapotranspiration Index. SPI:Standardized Precipitation Index ", placement = "left", trigger = "hover")
                                ),
                                column(4,
                                    wellPanel(
                                        h4("Specify custom thresholds"),
                                        strong("Custom index counting days above or below a given threshold (e.g. number of days where TX > 40, named TXgt40)"),
                                        br(),
                                        selectInput("custVariable", label = "Variable:",
                                            choices = list("TN", "TX", "TM", "PR", "DTR"),
                                            selected = "TN"
                                        ),
                                        selectInput("custOperation", label = "Operation:",
                                            choices = list(">", ">=", "<", "<="),
                                            selected = ">"
                                        ),
                                        numericInput("custThreshold", "Threshold:", 0)
                                    )
                                )
                            )
                        )
                    ),
                    wellPanel(
                        fluidRow(
                            column(6,
                                conditionalPanel(
                                    condition = "output.qualityControlError == ''",
                                    actionButton("calculateIndices", "Calculate Indices"),
                                    textOutput("indiceCalculationError")
                                ),
                                conditionalPanel(
                                    condition = "output.qualityControlError != ''",
                                    wellPanel("Please load data and perform Quality Control check.")
                                )
                            )
                        ),
                        fluidRow(
                            column(6,
                                conditionalPanel(
                                    condition = "output.indiceCalculationError == ''",
                                    h4("View Indices"),
                                    uiOutput("indicesLink")
                                )
                            )
                        )
                    )
                ),
                br(),
                actionButton("btn_next_process_single_station_step_3", label = "Next", icon = icon("chevron-circle-right"))
                )
        )  
}