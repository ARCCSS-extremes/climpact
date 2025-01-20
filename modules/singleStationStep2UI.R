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
        htmlOutput(ns("loadDataError"))
      ),
      conditionalPanel(
        condition = "output.loadDataError == ''",
        ns = ns,
        conditionalPanel(
          condition = "output.qcStatus == 'Done'",
          ns = ns,
          h4("2. Check data quality"),
          div("Quality control plots are displayed below."),
          conditionalPanel(
            condition = "output.qcLink != ''",
            ns = ns,
            uiOutput(ns("qcLinkTop"))
          ),
          htmlOutput(ns("qualityControlError")),
          slickROutput(ns("slickRQC"), width = "850px")
        ),
        conditionalPanel(
          condition = "output.loadDataError == ''",
          ns = ns,
          div(style = "margin-top: 3em; display: block;"),
          actionBttn(ns("doQualityControl"), label = " Check Data Quality", style = "jelly", color = "warning", icon = icon("play-circle", "fa-2x"))
        )
      ),
      conditionalPanel(
        condition = "output.loadDataError == ''",
        ns = ns,
        h4("Quality control parameters"),
        numericInput(ns("iqr_threshold_temp"), "Interquartile range (IQR) threshold for temperature outliers:", 3, min = 1, max = 10),
        bsTooltip(id = paste0(id, "-", "iqr_threshold_temp"), title = "The number of interquartile ranges used to identify temperature outliers", placement = "left", trigger = "hover"),
        numericInput(ns("iqr_threshold_prec"), "Interquartile range (IQR) threshold for precipitation outliers:", 5, min = 1, max = NA),
        bsTooltip(id = paste0(id, "-", "iqr_threshold_prec"), title = "The number of interquartile ranges used to identify precipitation outliers", placement = "left", trigger = "hover"),
        numericInput(ns("prec_threshold"), "Maximum daily rainfall threshold (mm):", 200, min = 0, max = 1500),
        bsTooltip(id = paste0(id, "-", "prec_threshold"), title = "Daily rainfall above this amount will be flagged for checking", placement = "left", trigger = "hover"),
        numericInput(ns("temp_threshold"), "Maximum absolute temperature threshold (°C):", 50, min = 0, max = 60),
        bsTooltip(id = paste0(id, "-", "temp_threshold"), title = "An absolute temperature above this value will be flagged for checking", placement = "left", trigger = "hover"),
        numericInput(ns("no_variability_threshold"), "Threshold number of days of no temperature variability:", 5, min = 3, max = 10),
        bsTooltip(id = paste0(id, "-", "no_variability_threshold"), title = "If minimum or maximum temperature remains the same for this many days in a row, it will be flagged for checking", placement = "left", trigger = "hover"),
        numericInput(ns("temp_change_threshold"), "Temperature change threshold (°C):", 20, min = 5, max = 30),
        bsTooltip(id = paste0(id, "-", "temp_change_threshold"), title = "If minimum or maximum temperature changes by this amount (or more) it will be flagged for checking", placement = "left", trigger = "hover"),
        br(),
      )
    ),
    column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("Check Data Quality"),
        tags$p("Click 'Check Quality' button. Climpact will commence quality control checks."),
        tags$p("Once processing is complete you can view quality control plots and you will be provided with a link to ",
          "the quality control output that Climpact has produced."),
        tags$p("It is necessary for you to inspect the output to ensure no errors are present in your station data."),
#        tags$p("Certain QC parameters are adjustable:"),
#        tags$p("
        conditionalPanel(
          condition = "output.qcLink != ''",
          ns = ns,
          HTML("<div class= 'alert alert-info' role='alert'>
          <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'>
          </span><span class='sr-only'></span>"),
          uiOutput(ns("qcLink")),
          HTML("</div>")
        )
      )
    )
    ),
    fluidRow(
          column(4, # left
          ),
          column(4, # right
            div(align = "right", style = "padding-top: 2em;",
              actionBttn(ns("btn_next_step_2"), label = "Next", style = "jelly", color = "primary", icon = icon("chevron-circle-right"))
            )
          ),
          column(4, # under instructions
          )
        )
  ))
}
