#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#' was gridded_data_thresholds.R
griddedStep2UI <- function(id) {
  ns <- NS(id)
  return(tagList(
      column(8,
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
        div(style = "margin-top: 3em; display: block;"),
        actionBttn(ns("calculateGriddedThresholds"),
        label = "Calculate NetCDF Thresholds", style = "jelly", color = "warning", icon = icon("play-circle", "fa-2x")),
        textOutput(ns("ncPrintThresh")),
        textOutput(ns("ncGriddedThreshDone"))
      ),
      column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("1. Select input file(s)"),
        tags$p("Select the netCDF file with the daily maximum and minimum temperatures and daily precipitation. "),
        tags$p("You are not required to include all three variables in this file. ",
        "ClimPACT will only calculate thresholds for the provided variables and the variables can be stored in separate files.<br />",
        "To provide separate files, you can select multiple files by holding CTRL and clicking the left-mouse button when the dialog box appears."),
        h4("2. Enter input dataset information"),
        tags$p("You will need to provide the names of the three variables as they are stored in the provided input file(s)."),
        h4("3. Enter output parameters"),
        tags$p("Institute name and ID are required for metadata."),
        tags$p("The base period start and end years are required."),
        h4("4. Enter other parameters"),
        tags$p("The number of computer cores to use can be modified from the default of 1."),
        h4("5. Calculate"),
        tags$p("Click the 'Calculate NetCDF Thresholds' button. ",
          "If you have provided all the required information as described above, ",
          "a dialog box will appear reminding you that calcuating gridded thresholds usually takes a long time.<br />",
          "Once you select 'Calculate Thresholds' processing will commence.<br />",
          "If you are unsure, click 'Cancel' to return to this screen.")
      )
    )
  ))
}