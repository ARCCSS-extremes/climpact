#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
griddedStep1UI <- function(id) {
  ns <- NS(id)
  return(tagList(
        column(8,
            div("This page allows you to calculate the indices on netCDF files."),
            h4("1. Select input file(s)"),
            wellPanel(
              fileInput(ns("dataFiles"),
              NULL,
              accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
              placeholder="Select or drop one or more NetCDF files",
              multiple = TRUE)
            ),
            h4("2. Enter input dataset information"),
            wellPanel(
              textInput(ns("prName"), "Name of precipitation variable:", value = "precip"),
              textInput(ns("txName"), "Name of maximum temperature variable:", value = "tmax"),
              textInput(ns("tnName"), "Name of minimum temperature variable:", value = "tmin")
            ),
            h4("3. Enter output parameters"),
            wellPanel(
              textInput(ns("outputFileNamePattern"),
                "Output filename format (must use CMIP5 filename convention. e.g. 'var_daily_climpact.sample_historical_NA_1991-2010.nc'):",
                value = "var_daily_climpact.sample_historical_NA_1991-2010.nc"),
              textInput(ns("instituteName"), "Enter your institute's name:"),
              textInput(ns("instituteID"), "Enter your institute's ID:"),
              numericInput(ns("baseStart"), "Start year of base period:", value = 1991),
              numericInput(ns("baseEnd"), "End year of base period:", value = 2010)
            ),
            h4("4. Enter other parameters"),
            wellPanel(
              numericInput(ns("nCores"),
                paste0("Number of cores to use (your computer has ", detectCores(), " cores):"),
                value = 1, min = 1, max = detectCores()),
              textInput(ns("indicesToCalculate"),
                paste0("Indices to calculate. Leave empty to calculate all indices,",
                "otherwise provide a comma-separated list of index names in lower case (e.g. txxm, tn90p)):")),
              fileInput(ns("thresholdFiles"),
                NULL,
                accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
                placeholder="Select or drop one or more threshold files",
                multiple = TRUE),
              selectInput(ns("ehfDefinition"), label = ("Select EHF calculation: "),
                choices=list("Perkins & Alexander (2013)" = "PA13", "Nairn & Fawcett (2013)" = "NF13"), selected = 1),
              textInput(ns("maxVals"), "Number of data values to process at once (do not change unless you know what you are doing):", value = 10)
            ),
            h4("5. Calculate"),
            wellPanel(
              actionButton(ns("calculateGriddedIndices"), "Calculate NetCDF Indices"),
              textOutput(ns("ncPrint")),
              textOutput(ns("ncGriddedDone"))
            )
        ),
      column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("1. Select input file(s)"),
        tags$p("Select the netCDF file with the daily maximum and minimum temperatures and daily precipitation. "),
        tags$p("You are not required to include all three variables in this file. ",
        "ClimPACT will only calculate indices that use the provided variables and the variables can be stored in separate files.<br />",
        "To provide separate files, you can select multiple files by holding CTRL and clicking the left-mouse button when the dialog box appears."),
        h4("2. Enter input dataset information"),
        tags$p("You will need to provide the names of the three variables as they are stored in the provided input file(s)."),
        h4("3. Enter output parameters"),
        tags$p("The output filename convention should also be specified - this must follow CMIP5 conventions like the default provided."),
        tags$p("Institute name and ID are required for metadata."),
        tags$p("The base period start and end years are required."),
        h4("4. Enter other parameters"),
        tags$p("The number of computer cores to use can be modified from the default of 1."),
        tags$p("If you wish to choose which indices to calculate, enter these, otherwise leave blank to calculate all."),
        tags$p("Optionally, select a threshold file that will be used for thresholds rather than calculating thresholds from the input file.<br />",
          " You might want to do this if you wish to calculate gridded indices based on future climate simulations",
          " using thresholds calculated from historical simulations."),
        tags$p("The type of Excess Heat Factor (EHF) calculation can be chosen. You should not change this unless you are familiar with the EHF."),
        tags$p("It is possible to change the number of data values to process at once, but do not change this unless you know what you are doing."),
        h4("5. Calculate"),
        tags$p("Click the 'Calculate NetCDF Indices' button. ",
          "If you have provided all the required information as described above, ",
          "a dialog box will appear reminding you that calcuating gridded indices usually takes a long time.<br />",
          "Once you select 'Calculate Indices' processing will commence.<br />",
          "If you are unsure, click 'Cancel' to return to this screen.")
      )
    )
  ))
}