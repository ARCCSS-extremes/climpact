box(title = "Process Single Station", status = "primary", width = 12,
    solidHeader = TRUE,
    tabBox(id = "process_single_station", width = 12,
        tabPanel(title = "1. Load Dataset",
            id = "process_single_station_step_1",
            value = "process_single_station_step_1",
            wellPanel(title = "Dataset",
                fileInput('dataFile', NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                uiOutput("loadDatasetText")),
            wellPanel(title = "Metadata",
                    textInput("stationName", "Station name (used in output file names):"),
                    numericInput("stationLat", "Latitude:", 0, min = -90, max = 90),
                    numericInput("stationLon", "Longitude:", 0, min = -180, max = 180),
                    numericInput("startYear", "Base Period Start year:", 1971, min = 0),
                    numericInput("endYear", "Base Period End year:", 2000, min = 0)
            ),
            br(),
            actionButton("btn_next_process_single_station_step_1", label = "Next >")
        ),
        tabPanel(title = "2. Quality Control",
            id = "process_single_station_step_2",
            value = "process_single_station_step_2",
                htmlOutput("dataFileLoadedWarning"),
                conditionalPanel(
                    condition = 'output.dataFileLoaded',
                    wellPanel(title = "Quality Control",
                        actionButton("doQualityControl", "Check Quality"),
                        textOutput("qualityControlError")
                    ),
                    conditionalPanel(
                        condition = "output.qualityControlError == ''",
                        wellPanel(title = "Evaluate Quality Control output",
                            uiOutput("qcLink")
                        )
                    )
                ),
                br(),
                actionButton("btn_next_process_single_station_step_2", label = "Next >")
        ),
        tabPanel(title = "3. Calculate Climate Indices",
            id = "process_single_station_step_3",
            value = "process_single_station_step_3",
            wellPanel(title = "Calculate",
                conditionalPanel(
                    condition = "output.qualityControlError != ''",
                    wellPanel("Please check data quality.")
                )
            ),
            br(),
            actionButton("btn_next_process_single_station_step_3", label = "Next >")
        ),
        tabPanel(title = "4. Sector Correlation",
            id = "process_single_station_step_4",
            value = "process_single_station_step_4",
            fluidRow(
                column(6,
                    h4('9. Load Sector Data'),
                    wellPanel(
                        fileInput('sectorDataFile', NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                        uiOutput("loadSectorDataText")
                    ),
                    h4('10. Sector Data Infomation'),
                    wellPanel(
                        textInput("sectorPlotName", "Plot name:"),
                        checkboxInput("detrendCheck", "Detrend data", value = TRUE, width = NULL)
                    )
                )
            ),
            fluidRow(
                column(6,
                    h4('11. Make correlation plots'),
                    conditionalPanel(
                        condition = "output.indiceCalculationError != ''",
                        wellPanel(
                            "Please complete step 7: ",
                            tags$b("Calculate Indices.")
                        )
                    ),
                    conditionalPanel(
                        condition = "output.indiceCalculationError == ''",
                        wellPanel(
                            actionButton("calculateSectorCorrelation", "Calculate correlations"),
                            textOutput("sectorCorrelationError")
                        )
                    ),
                    h4('12. View correlation'),
                    conditionalPanel(
                        condition = "output.sectorCorrelationError== ''",
                        wellPanel(
                        uiOutput("sectorCorrelationLink")
                        )
                    ),
                    conditionalPanel(
                        condition = "output.sectorCorrelationError != ''",
                        wellPanel(
                        "Please complete step 11: ", tags$b("Calculate Correlation.")
                        )
                    )
                )
            ) 
        )
    )
)