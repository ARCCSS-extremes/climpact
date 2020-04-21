#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
griddedStep1UI <- function(id) {
  ns <- NS(id)
  return(tagList(
    fluidRow(
        column(12,
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
        )
    )
  ))
}