#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
batchStep1UI <- function(id) {
  ns <- NS(id)
  return(tagList(
    column(8,
      div(HTML("This page allows you to calculate the indices for multiple station text files.<br />",
          "Any errors will be reported after processing. This process can take a long time (~1 minute per file).")),
          h4("1. Metadata"),
          fileInput(ns("batchMeta"), NULL, accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt")),
          h4("2. Station data"),
          fileInput(ns("batchData"),
            NULL,
            accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
            placeholder="Select or drop multiple station files",
            multiple = TRUE),
          h4("3. Parameters"),
            numericInput(ns("startYearBatch"), "Base period start year:", 1970, min = 0),
            numericInput(ns("endYearBatch"), "Base period end year:", 2010, min = 0),
            conditionalPanel(
              condition = paste0(tolower(isLocal)),
              ns = ns,
              numericInput(ns("nCoresBatch"),
                paste0("Number of cores to use (your computer has ", detectCores(), " cores):"),
                value = 1, min = 1, max = detectCores())
            ),
            h4("4. Calculate"),
            actionButton(ns("calculateBatchIndices"), "Calculate Indices"),
            htmlOutput(ns("batchLink")),
            conditionalPanel(
              condition = "output.batchLink != ''",
              ns = ns,
                tags$p(HTML("Results for each station are stored in separate directories.<br />",
                            "See *error.txt files for stations that had problems.")),
                tags$ul(tags$li(HTML("The <i>plots</i> subdirectory contains an image file for each index.")),
                  tags$li(HTML("The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index")),
                  tags$li(HTML("The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.")),
                  tags$li(HTML("The <i>thres</i> subdirectory contains two .csv files containing ",
                              "threshold data calculated for various variables.")),
                  tags$li(HTML("The <i>qc</i> subdirectory contains quality control diagnostic information.")))
              )
    ),
      column(4, class = "instructions",
      box(title = "Instructions", width = 12,
        h4("1. Metadata"),
        uiOutput(ns("batchIntroText")),
        HTML("Upload a file with information for each station. Each file of input data uploaded at step 2 must be included in tihs file."),
        h4("2. Station data"),
        uiOutput(ns("batchFolderText")),
        h4("3. Parameters"),
        HTML("Specify valid values for base period."),
        h4("4. Calculate"),
        HTML("The 'Calculate Indices' button will be enabled when you have specified all required inputs, including: ",
          "metadata, station data and parameters.")
      )
    )
  ))
}