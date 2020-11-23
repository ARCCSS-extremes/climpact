#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep3UI <- function(id) {
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
      # # User specified parameters
    conditionalPanel(# show if quality control done and no errors
      condition = "output.qcStatus == 'Done' && output.qualityControlError == ''",
      ns = ns,
      h4("3. Calculate and plot indices"),
      wellPanel(
        fluidRow(
          column(12,
            textInput(ns("plotTitle"), "Plot title:")
          )
        ),
        fluidRow(
          column(12,
            h4("User Parameters"),
            uiOutput(ns("loadParamHelpText")))
        ),
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
            numericInput(ns("hdd"), "Base temperature for HDDheat (°C):", 18),
            bsTooltip(id = paste0(id, "-", "hdd"), title = "HDDheat: Heating Degree Days", placement = "left", trigger = "hover"),
            numericInput(ns("cdd"), "Base temperature for CDDcold (°C):", 18),
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
              h4("Create a custom threshold index"),
              strong("Create an index that counts the number of days above or below a given threshold (e.g. number of days where TX > 40, named TXgt40)"),
              br(),br(),
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
      )), #wellPanel + close out conditionalPanel
      conditionalPanel(# show if quality control done and no errors (as for panel above, but splitting into two for layout elements eg wellPanel)
      condition = "output.loadDataError == '' && output.qcStatus == 'Done' && output.qualityControlError == ''",
      ns = ns,
        fluidRow(
          column(12,
            div(style = "margin-top: 3em; display: block;"),
            actionBttn(ns("calculateIndices"), label = "Calculate Indices", style = "jelly", color = "warning", icon = icon("play-circle", "fa-2x"))
          )
        )
      ), # Error message
      conditionalPanel(
        condition = "output.indexCalculationStatus == 'Done' && output.indexCalculationErrors != ''",
        ns = ns,
        textOutput(ns("indexCalculationErrors"))
      ), # Plots
      conditionalPanel(
        condition = "output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == ''",
        ns = ns,
        div(
          h4("Plots of calculated indices"),
          p("Plots are displayed below and available for download on this page using the link in the blue info box under Instructions.")
        ),
        fluidRow(
          column(12, slickROutput(ns("slickRIndices"), width = "850px"))
        )
      )
     ), # Right hand column below
     column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("Plot title"),
        HTML("Enter a plot title. This will be included on all plots generated.<br />",
          " Climpact will generate a title for you automatically ",
          "based on the station name and coordinates provided when loading data, but you can override this here."),
        h4("User parameters"),
          HTML("You may also change the following default parameters that relate to several indices (see ",
          "<a href='user_guide/Climpact_user_guide.htm#appendixA' target='_blank'>Appendix A</a> for index definitions):"),
          tags$ul(tags$li(HTML("<b>WSDId Days</b> sets the number of days which need to occur consecutively ",
            "with a TX > 90th  percentile to be counted in the WSDId index.")),
            tags$li(HTML("<b>CSDId Days</b> sets the number of days which need to occur consecutively ",
            "with a TN < 10th  percentile to be counted in the CSDId index.")),
            tags$li(HTML("<b>Rxdday Days</b> sets the monthly maximum consecutive d-day precipitation to be recorded by the Rxdday index.")),
            tags$li(HTML("<b>d for TXdTNd and TXbdTNbd</b> sets the number of consecutive days required to be counted as a run of hot or cold day and nights for the TXdTNd and TXbdTNbd indices.")),
            tags$li(HTML("<b>Base temperature</b> for <b>HDDheat</b>, <b>CDDcold</b> and <b>GDDgrow</b> ",
              "set the temperatures to be used in calculating these indices.")),
            tags$li(HTML("<b>Count the number of days where precipitation >= nn (Rnnmm)</b> allows the user to calculate the number of days with ",
              "precipitation greater than or equal to a set amount. ",
              "This index will be called 'rnnmm', where 'nn' is the precipitation set by the user.")),
           ),
           HTML("<p><b>Custom index</b> gives the user the option to create their own index ",
             "based on the number of days crossing a specified threshold for </p>",
             "<ul><li>daily maximum temperature (TX),</li>",
             "<li>minimum temperature (TN), </li>",
             "<li>diurnal temperature range (DTR) or</li>",
             "<li>precipitation (PR).</li></ul>",
             "<p>To calculate a custom index, the user must select ",
             "one of these variables, an operator (<,<=,>,>=) and a constant.</p>",
             "<p>For example, selecting TX, the '>=' operator and specifying 40 as a constant ",
             "will calculate an index representing the number of days where TX is greater than or equal to 40C.</p>",
             "<p>Climpact will output this index as TXge40. ",
             "Operators are abbreviated in text with lt, le, gt and ge for <, <=, > and >=, respectively.</p>"),
         h4("Calculate Indices"),
         HTML("<p>Once you have reviewed the above parameters, select the 'Calculate Indices' button.<br />",
         "A window and progress bar will appear providing an indication of progess as calculations proceed.</p>"),
         tags$p("Once processing is complete you can view the plots generated",
         "and you will be provided with a link to all the outputs that Climpact has produced."), # Results below
          conditionalPanel(
            condition = "output.indexCalculationStatus == 'Done' && output.indexCalculationErrors == ''",
            ns = ns,
            HTML("<div class= 'alert alert-info' role='alert'>
                <span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'>
                </span><span class='sr-only'></span>"),
                uiOutput(ns("indicesLink")),
            tags$ul(tags$li(HTML("The <i>plots</i> subdirectory contains an image file for each index.")),
              tags$li(HTML("The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index")),
              tags$li(HTML("The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.")),
              tags$li(HTML("The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables.")),
              tags$li(HTML("The <i>qc</i> subdirectory contains quality control diagnostic information.")),
              tags$li(HTML("If you have chosen to calculate and plot correlations ",
                "between annual sector data you supply and the indices Climpact has calculated, ",
                "the <i>corr</i> subdirectory will contain plots and .csv files containing the correlations."))),
            HTML("</div>")
          ),
         tags$p("Click the Next button or the tab labelled '4. Compare' to proceed to the next step.")
       )
    )
    ),
    fluidRow(
      column(4, # left
      ),
      column(4, # right
        div(align = "right", style = "padding-top: 2em;",
          actionBttn(ns("btn_next_step_3"), label = "Next", style = "jelly", color = "primary", icon = icon("chevron-circle-right"))
        )
      ),
      column(4, # under instructions
      )
    )
  ))
}
