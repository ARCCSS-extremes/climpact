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
          condition = "output.qcStatus != 'Done'",
          ns = ns,
          div(style = "margin-top: 3em; display: block;"),
          actionBttn(ns("doQualityControl"), label = " Check Data Quality", style = "jelly", color = "warning", icon = icon("play-circle", "fa-3x"))
        ),
        conditionalPanel(
          condition = "output.qcStatus == 'Done'",
          ns = ns,
          h4("2. Check data quality"),
          div("Quality control plots are displayed below and available for download on this page using the link in the blue info box under Instructions."),
          htmlOutput(ns("qualityControlError")),
          slickROutput(ns("slickRQC"), width = "850px")
        )
      )
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