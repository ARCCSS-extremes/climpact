tabPanel(title="Process multiple stations",
         fluidPage(
            fluidRow(
              column(12,
                    h3("Batch processing multiple station files"),
                    h4('This page allows you to calculate the indices for multiple station text files. Any errors will be reported after processing. This process can take a long time (~1 minute per file).')
              )
            ),
            fluidRow(
              column(6,
                br(),
                h4("1. Metadata"),
                wellPanel(
                  uiOutput("batchIntroText"),
                  br(),
                  fileInput('batchMeta', NULL,accept=c('text/csv', 'text/comma-separated-values,text/plain', '.txt'))
                ),
                h4("2. Input data"),
                wellPanel(
                  uiOutput("batchFolderText"),
                  actionButton("selectInDirBatch", "Select input directory"),
                  textOutput("inDirPrintBatch")
                )
              ),
              column(6,
                br(),
                h4("3. Base period and compute cores"),
                wellPanel(
                  numericInput("startYearBatch", "Base Period Start year:", 1970, min = 0),
                  numericInput("endYearBatch", "Base Period End year:", 2010, min = 0),
                  numericInput("nCoresBatch", paste0("Number of cores to use (your computer has ",detectCores()," cores):"),value=1,min=1,max=detectCores())
                ),
                h4("4. Calculate"),
                wellPanel(
                  actionButton("calculateBatchIndices", "Calculate indices"),
                  textOutput("ncPrintBatch")
                )
              )
            )
        )
)