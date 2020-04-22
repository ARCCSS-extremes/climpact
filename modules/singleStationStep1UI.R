#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep1UI <- function (id) {
  ns <- NS(id)
  return(tagList(
    fluidRow(column(8,
      h4("Station data"),
      HTML(climpactUI$sampleText,
          "<a target=\"_blank\" href=sample_data/sydney_observatory_hill_1936-2015.txt> sydney_observatory_hill_1936.txt</a></p>"),
      fileInput(ns("dataFile"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      h4("Metadata"),
      textInput(ns("stationName"), "Station name (used in output file names):"),
      numericInput(ns("stationLat"), "Latitude (decimal degrees eg -40.992):", 0, min = -90, max = 90),
      numericInput(ns("stationLon"), "Longitude (decimal degrees eg 148.346):", 0, min = -180, max = 180),
      numericInput(ns("startYear"), "Base period start year:", 1971, min = 0),
      numericInput(ns("endYear"), "Base period end year:", 2000, min = 0),
      br(),
      uiOutput(ns("fileUploaded")),
      actionButton(ns("btn_next_step_1"), label = "Next", icon = icon("chevron-circle-right"))
    ),
      column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("1. Station data"),
        HTML("Select a station text file. Climpact will calculate indices for this data.<br />"),
        HTML(climpactUI$sampleText,
          "<a target=\"_blank\" href=sample_data/sydney_observatory_hill_1936-2015.txt> sydney_observatory_hill_1936.txt</a></p>"),
        h4("2. Metadata"),
        tags$p("Specify the station name.",
          "Climpact will attempt to determine this automatically for you based on the uploaded station data file name.",
          "This must be some text."),
        HTML("<p>Specify the station latitude and longitude in decimal degrees<br />eg -40.992 or 148.346.<br />",
        "Latitude must be between -90 and 90<br />",
        "Longitude must be between -180 and 180.</p>"),
        HTML("<p>Specify valid values for the base period start year and end year.<br />",
        "These values must be within the limits of the dates in the station data provided.</p>"),
        h4("Next"),
        HTML("Click the Next button or the tab labelled '2. Check' to proceed to the next step.")
      )
    )
    )
  ))
}