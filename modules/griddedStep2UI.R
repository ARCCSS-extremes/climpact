#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#' was gridded_data_thresholds.R
griddedStep2UI <- function(id) {
  ns <- NS(id)
  return(tagList(
    fluidRow(
      column(12,
        div(paste0("This page allows you to calculate thresholds on netCDF files. ",
          "For use in calculating gridded indices where the base period resides in a different file.")),
        h4("1. Select input file(s)"),
        wellPanel(
          fileInput(ns("dataFilesThresh"),
          NULL,
          accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
          placeholder="Select or drop one or more NetCDF files",
          multiple = TRUE)
        ),
        h4("2. Enter input dataset information"),
        wellPanel(
          textInput(ns("prNameThresh"), "Name of precipitation variable:", value = "precip"),
          textInput(ns("txNameThresh"), "Name of maximum temperature variable:", value = "tmax"),
          textInput(ns("tnNameThresh"), "Name of minimum temperature variable:", value = "tmin")
        ),
        h4("3. Enter output parameters"),
        wellPanel(
          textInput(ns("instituteNameThresh"), "Enter your institute's name:"),
          textInput(ns("instituteIDThresh"), "Enter your institute's ID:"),
          numericInput(ns("baseStartThresh"), "Start year of base period:", value = 1991),
          numericInput(ns("baseEndThresh"), "End year of base period:", value = 2010),
          textInput(ns("outputFileNameThresh"), "Output filename:", value = "sample_data.thresholds.1991-2010.nc")
        ),
        h4("4. Other parameters"),
        wellPanel(
          numericInput(ns("nCoresThresh"),
            paste0("Number of cores to use (your computer has ", detectCores(), " cores):"), value = 1, min = 1, max = detectCores())
        ),
        h4("5. Calculate"),
        wellPanel(
          actionButton(ns("calculateGriddedThresholds"), "Calculate NetCDF thresholds"),
          textOutput(ns("ncPrintThresh")),
          textOutput(ns("ncGriddedThreshDone"))
        )
      )
    )
  ))
}