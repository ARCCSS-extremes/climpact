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
          uiOutput("batchIntroText"),
          br(),
          fileInput("batchMeta", NULL, accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"))
        ),
        h4("2. Input data"),
        wellPanel(
          uiOutput("batchFolderText"),
          fileInput("batchCsvs",
          label="Station data",
          accept=c("text/csv", "text/comma-separated-values,text/plain", ".txt"),
          placeholder="Select multiple space delimited ASCII text files",
          multiple = TRUE)
        ),
        h4("3. Base period and compute cores"),
        wellPanel(
          numericInput("startYearBatch", "Base Period Start year:", 1970, min = 0),
          numericInput("endYearBatch", "Base Period End year:", 2010, min = 0),
          numericInput("nCoresBatch", 
            paste0("Number of cores to use (your computer has ", detectCores(), " cores):"),
            value = 1, min = 1, max = detectCores())
        ),
        h4("4. Calculate"),
        wellPanel(
          actionButton("calculateBatchIndices", "Calculate indices"),
          htmlOutput("ncPrintBatch")
        )
      )
    )
  ))
}