tabPanel(title="Load and Check Data", fluidPage(
    fluidRow(
        column(4,
            h4('1. Load Dataset'),
            wellPanel(
                fileInput('dataFile', NULL,accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                uiOutput("loadDatasetText")
        )),
        column(4,
            h4('2. Enter Dataset Infomation'),
            wellPanel(
            textInput("stationName", "Station name (used in output file names):"),
            numericInput("stationLat", "Latitude:", 0, min = -90, max = 90),
            numericInput("stationLon", "Longitude:", 0, min = -180, max = 180),
            numericInput("startYear", "Base Period Start year:", 1971, min = 0),
            numericInput("endYear", "Base Period End year:", 2000, min = 0)
        )),
        fluidRow(
            column(4,
                h4('3. Process Data and Quality Control'),
                wellPanel(
                actionButton("doQualityControl", "Process"),
                textOutput("qualityControlError")
            )),
            column(4,
                h4('4. Evaluate Quality Control output'),
                conditionalPanel(
                    condition = "output.qualityControlError == ''",
                    wellPanel(
                        uiOutput("qcLink")
                    )
                ),
                conditionalPanel(
                    condition = "output.qualityControlError != ''",
                    wellPanel(
                        "Please complete step 3: ",
                        tags$b("Process Data and Quality Control")
                    )
                )
            ),
            column(4,
                h4('5. Calculate Climate Indices'),
                conditionalPanel(
                    condition = "output.qualityControlError == ''",
                    wellPanel(
                        actionLink("calculateIndicesTabLink",
                                   "Go to the Calculate Climate Indices tab")
                    )
                ),
                conditionalPanel(
                    condition = "output.qualityControlError != ''",
                    wellPanel(
                        "Please complete step 3: ",
                        tags$b("Process Data and Quality Control")
                    )
                )
            )
        )
    )
))

