#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
singleStationStep1UI <- function (id) {
  ns <- NS(id)
  return(tagList(
            wellPanel(
              h4("Load station data"),
              fileInput(ns("dataFile"), NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
              HTML("<p>The dataset <strong>must</strong> use the format described in ",
                  "<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm#appendixB>Appendix B</a>",  # link to Appendix B of user guide
                  " of the ", 
                  "<a target=\"_blank\" href=user_guide/ClimPACT_user_guide.htm>ClimPACT User Guide</a>.</p>",   # link to of user guide
                  "<p>For a sample dataset look at ",
                  "<a target=\"_blank\" href=sample_data/sydney_observatory_hill_1936-2015.txt> sydney_observatory_hill_1936.txt</a></p>"), # link to sample file
              wellPanel(
                  h4("Provide metadata"),
                  textInput(ns("stationName"), "Station name (used in output file names):"),
                  numericInput(ns("stationLat"), "Latitude (decimal degrees eg -40.992):", 0, min = -90, max = 90),
                  numericInput(ns("stationLon"), "Longitude (decimal degrees eg 148.346):", 0, min = -180, max = 180),
                  numericInput(ns("startYear"), "Base Period Start year:", 1971, min = 0),
                  numericInput(ns("endYear"), "Base Period End year:", 2000, min = 0)
              ),
              br(),
              actionButton(ns("btn_next_process_single_station_step_1"), label = "Next", icon = icon("chevron-circle-right"))
            )
          )
        )  
}