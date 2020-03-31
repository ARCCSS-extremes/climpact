box(title = "Process Single Station", status = "primary", width = 12, solidHeader = TRUE,
  tabBox(id = "process_single_station", width = 12,        
    tabPanel(title = "1. Load Dataset",
        id = "process_single_station_step_1",
        value = "process_single_station_step_1",
        wellPanel(
            h4("Load station data"),
            fileInput('dataFile', NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
            uiOutput("loadDatasetText")
        ),
        wellPanel(
            h4("Provide metadata"),
            textInput("stationName", "Station name (used in output file names):"),
            numericInput("stationLat", "Latitude (decimal degrees eg -40.992):", 0, min = -90, max = 90),
            numericInput("stationLon", "Longitude (decimal degrees eg 148.346):", 0, min = -180, max = 180),
            numericInput("startYear", "Base Period Start year:", 1971, min = 0),
            numericInput("endYear", "Base Period End year:", 2000, min = 0)
        ),
        br(),
        actionButton("btn_next_process_single_station_step_1", label = "Next", icon = icon("chevron-circle-right"))
    ),
    tabPanel(title = "2. Quality Control",
        id = "process_single_station_step_2",
        value = "process_single_station_step_2",
            htmlOutput("dataFileLoadedWarning"),
            conditionalPanel(
                condition = 'output.dataFileLoaded',
                wellPanel(
                    actionButton("doQualityControl", "Check Quality"),
                    htmlOutput("qualityControlError")
                ),
                conditionalPanel(
                    condition = "output.qualityControlError == ''",
                    wellPanel(h4("Evaluate Quality Control output"),
                        uiOutput("qcLink")
                    )
                )
            ),
            br(),
            actionButton("btn_next_process_single_station_step_2", label = "Next", icon = icon("chevron-circle-right"))
    ),
    tabPanel(title = "3. Calculate Climate Indices",
        id = "process_single_station_step_3",
        value = "process_single_station_step_3",
        conditionalPanel(
            condition = "output.qualityControlError != ''",
            wellPanel(HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span> Please check data quality</div>"))
        ),
        conditionalPanel(
            condition = "output.qualityControlError == ''",
            wellPanel(
                h4("Provide User Parameters"),
                fluidRow(
                    column(6,
                        textInput("plotTitle", "Plot title:")
                    )
                ),
                fluidRow(
                    column(12, uiOutput("loadParamHelpText"))
                ),
                wellPanel(
                    fluidRow(
                        column(4,
                            numericInput("wsdin", "d for WSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
                            numericInput("csdin", "d for CSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
                            numericInput("rxnday", "d for Rxdday Days (d >= 1):", 3, min = 1),
                            numericInput("txtn", "d for TXdTNd and TXbdTNbd (d >= 1):", 2, min = 1)
                        ),
                        column(4,
                            numericInput("hdd", "Base temperature for HDDHeat (°C):", 18),
                            numericInput("cdd", "Base temperature for CDDHeat (°C):", 18),
                            numericInput("gdd", "Base temperature for GDDgrow (°C):", 10),
                            numericInput("rnnmm", "Number of days precip >= nn (Rnnmm; nn >= 0):", 30, min = 0),
                            numericInput("spei", "SPEI/SPI custom monthly time scale (must be a positive number):", 24, min = 1)
                        ),
                        column(4,
                            wellPanel(
                                h4("Specify custom thresholds"),
                                strong("Custom index counting days above or below a given threshold (e.g. number of days where TX > 40, named TXgt40)"),
                                br(),
                                selectInput("custVariable", label = "Variable:",
                                    choices = list("TN", "TX", "TM", "PR", "DTR"),
                                    selected = "TN"
                                ),
                                selectInput("custOperation", label = "Operation:",
                                    choices = list(">", ">=", "<", "<="),
                                    selected = ">"
                                ),
                                numericInput("custThreshold", "Threshold:", 0)
                            )
                        )
                    )
                )
            ),
            wellPanel(
                fluidRow(
                    column(6,
                        conditionalPanel(
                            condition = "output.qualityControlError == ''",
                            actionButton("calculateIndices", "Calculate Indices"),
                            textOutput("indiceCalculationError")
                        ),
                        conditionalPanel(
                            condition = "output.qualityControlError != ''",
                            wellPanel("Please load data and perform Quality Control check.")
                        )
                    )
                ),
                fluidRow(
                    column(6,
                        conditionalPanel(
                            condition = "output.indiceCalculationError == ''",
                            h4("View Indices"),
                            uiOutput("indicesLink")
                        )
                    )
                )
            )
        ),
        br(),
        actionButton("btn_next_process_single_station_step_3", label = "Next", icon = icon("chevron-circle-right"))            
    ),
    tabPanel(title = "4. Sector Correlation",
        id = "process_single_station_step_4",
        value = "process_single_station_step_4",
        fluidRow(
            column(6,
                h4('Load sector data'),
                wellPanel(
                    fileInput('sectorDataFile', NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                    uiOutput("loadSectorDataText")
                ),
                h4('Specify chart title'),
                wellPanel(
                    textInput("sectorPlotName", "Chart title:"),
                    checkboxInput("detrendCheck", "Detrend data", value = TRUE, width = NULL)
                )
            )
        ),
        fluidRow(
            column(6,
                h4('Make correlation plots'),
                conditionalPanel(
                    condition = "output.indiceCalculationError != ''",
                    wellPanel(HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'></span> Please complete previous step - Calculate Climate Indices.</div>"))
                ),
                conditionalPanel(
                    condition = "output.indiceCalculationError == ''",
                    wellPanel(
                        actionButton("calculateSectorCorrelation", "Calculate correlations"),
                        textOutput("sectorCorrelationError")
                    )
                ),
                h4('View correlation'),
                conditionalPanel(
                    condition = "output.sectorCorrelationError== ''",
                    wellPanel(
                        uiOutput("sectorCorrelationLink")
                    )
                ),
                conditionalPanel(
                    condition = "output.sectorCorrelationError != ''",
                    wellPanel(
                        "Correlation plots available here after calculations completed."
                    )
                )
            )
        )
    ) 
  )
)