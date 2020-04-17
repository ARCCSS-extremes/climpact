#' File input and basic parameter collection for index calculations and plot generation
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
batchStep1UI <- function(id) {
  ns <- NS(id)
  return(tagList(
    fluidRow(
      column(12,
        div("This page allows you to calculate the indices for multiple station text files.",
            "Any errors will be reported after processing. This process can take a long time (~1 minute per file)."),
        h4("1. Metadata"),
        wellPanel(
          uiOutput(ns("batchIntroText")),
          br(),
          fileInput(ns("batchMeta"), NULL, accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"))
        ),
        h4("2. Input data"),
        wellPanel(
          uiOutput(ns("batchFolderText")),
          fileInput(ns("batchData"),
          label="Station data",
          accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
          placeholder="Select multiple space delimited ASCII text files",
          multiple = TRUE)
        ),
        h4("3. Base period and compute cores"),
        wellPanel(
          numericInput(ns("startYearBatch"), "Base Period Start year:", 1970, min = 0),
          numericInput(ns("endYearBatch"), "Base Period End year:", 2010, min = 0),
          conditionalPanel(
            condition = paste0(tolower(isLocal)),
            ns = ns,
            numericInput(ns("nCoresBatch"),
              paste0("Number of cores to use (your computer has ", detectCores(), " cores):"),
              value = 1, min = 1, max = detectCores())
          )
        ),
        h4("4. Calculate"),
        wellPanel(
          actionButton(ns("calculateBatchIndices"), "Calculate Indices"),
          htmlOutput(ns("ncPrintBatch")),
          htmlOutput(ns("batchLink")),
          tags$p("Results for each station are stored in separate directories. See *error.txt files for stations that had problems."),
          tags$ul(tags$li(HTML("The <i>plots</i> subdirectory contains an image file for each index.")),
              tags$li(HTML("The <i>indices</i> subdirectory contains a .csv file with the plotted values for each index")),
              tags$li(HTML("The <i>trend</i> subdirectory contains a .csv file containing linear trend information for each index.")),
              tags$li(HTML("The <i>thres</i> subdirectory contains two .csv files containing threshold data calculated for various variables.")),
              tags$li(HTML("The <i>qc</i> subdirectory contains quality control diagnostic information.")),
              tags$li(HTML("If you have chosen to calculate and plot correlations between annual sector data you supply and the indices ClimPACT has calculated, the <i>corr</i> subdirectory will contain plots and .csv files containing the correlations.")))

                          

        )
      )
    )
  ))
}