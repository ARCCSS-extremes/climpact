#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep4UI <- function(id) {
  ns <- NS(id)
  return(tagList(
    fluidRow(column(8,
    conditionalPanel(# show if no station data
      condition = "output.loadDataError != ''",
      ns = ns,
        HTML("<div class= 'alert alert-info' role='alert'>
          <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
          <span class='sr-only'>Info</span> Please load station data.</div>"
        )
      ),
      conditionalPanel(# show if station data, and quality control done and failed or quality control not done
        condition = "output.loadDataError == '' && ((output.qcStatus == 'Done' && output.qualityControlError != '') || output.qcStatus != 'Done')",
        ns = ns,
        HTML("<div class= 'alert alert-info' role='alert'>
          <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
          <span class='sr-only'>Info</span> Please check data quality.</div>"
        )
      ),
      conditionalPanel(
        condition = "output.loadDataError == '' && ((output.qcStatus == 'Done' && output.qualityControlError == '')) && output.indexCalculationStatus != 'Done'",
        ns = ns,
        HTML("<div class= 'alert alert-info' role='alert'>
                <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>
                <span class='sr-only'></span> Please calculate climate indices.</div>")
    ),
    conditionalPanel(
      condition = "output.loadDataError == '' && output.qcStatus == 'Done' && output.qualityControlError == '' && output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == ''",
      ns = ns,
      h4("4. Calculate and plot sector correlations"),
      wellPanel(
        h4("Sector data"),
        fileInput(ns("sectorDataFile"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
        HTML(climpactUI$sampleText,
          "<a target=\"_blank\" href=sample_data/wheat_yield_nsw_1922-1999.csv>wheat_yield_nsw_1922-1999.csv</a>"),    
        h4("Plot attributes"),
        textInput(ns("sectorPlotTitle"), "Title:"),
        textInput(ns("y_axis_label"), "Label for y axis:"),
        checkboxInput(ns("detrendCheck"), "Detrend data", value = TRUE, width = NULL)
      ),
      div(style = "margin-top: 3em; display: block;"),
      actionBttn(ns("calculateSectorCorrelation"),
                label = "Calculate Correlations", style = "jelly", color = "warning", icon = icon("play-circle", "fa-2x"))
    ),
    conditionalPanel(
        condition = "output.loadDataError == '' && output.qcStatus == 'Done' && output.qualityControlError == '' && output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == '' && output.sectorCalculationStatus == 'Done' && output.sectorCorrelationError != ''",
        ns = ns,
        textOutput(ns("sectorCorrelationError"))
    ),
    conditionalPanel(
        condition = "output.loadDataError == '' && output.qcStatus == 'Done' && output.qualityControlError == '' && output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == '' && output.sectorCalculationStatus == 'Done' && output.sectorCorrelationError == ''",
        ns = ns,
        div(
          h4("Plots of calculated indices"),
          p("Sector correlation plots are displayed below and available for download
           on this page using the link in the blue info box under Instructions.")
        ),
        slickROutput(ns("slickRCorr"), width="900px")
    )
  ), # Right hand column below
     column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("Sector data"),
        HTML("<p>ClimPACT can calculate and plot correlations between annual sector data ",
        "the user has and the indices it has calculated.<br />",
        "Currently, ClimPACT only calculates correlations for annual sector data.</p>",
        "<p>Note that the indices must have been calculated in the current session of ClimPACT. ",
        "So, if you have closed ClimPACT and wish to calculate correlations with sector data, ",
        "you must repeat the process from the beginning.</p>"),
        h4("Plot attributes"),
        HTML("<p>Select sector data file for correlating with indices. See ", climpactUI$appendixBLink, " for guidance on formatting this file.</p>"),
        HTML("<p>ClimPACT will attempt to automatically determine a title and label for the y axis of the plots from the file name loaded.</p>"),
        HTML("<p>You can override these values by entering your preferred values in the relevant boxes.</p>"),
        HTML("<p>Leave the 'Detrend data' checkbox checked if you would like ",
        "the sector and index data to be detrended prior to calculating the correlations.</p>"),
         h4("Calculate Correlations"),
         HTML("<p>Once you have reviewed the above parameters, select the 'Calculate Correlations' button.<br />",
         "A window and progress bar will appear providing an indication of progess as correlations proceed.</p>"),
         tags$p("Once processing is complete you can view the plots generated",
         "and you will be provided with a link to all the correlation outputs that ClimPACT has produced."),        
        conditionalPanel(
            condition = "output.loadDataError == '' && output.qcStatus == 'Done' && output.qualityControlError == '' && output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == '' && output.sectorCalculationStatus == 'Done' && output.sectorCorrelationError == '' && output.sectorCorrelationLink != ''",
            ns = ns,
            HTML("<div class= 'alert alert-info' role='alert'>
          <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'>
          </span><span class='sr-only'></span>"),
          uiOutput(ns("sectorCorrelationLink")),
          HTML("</div>")
        )
       )
    )
    )
    ))
}