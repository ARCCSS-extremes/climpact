box(title = "Process Single Station", status = "primary", width = 12, solidHeader = TRUE,
  tabBox(id = "process_single_station", width = 12,        
    tabPanel(title = "1. Load",
        id = "process_single_station_step_1",
        value = "process_single_station_step_1",
        singleStationStep1UI("ui")        
    ),
    tabPanel(title = "2. Check",
        id = "process_single_station_step_2",
        value = "process_single_station_step_2",
        singleStationStep2UI("ui")
    ),
    tabPanel(title = "3. Calculate",
        id = "process_single_station_step_3",
        value = "process_single_station_step_3",
        singleStationStep3UI("ui")                      
    ),
    tabPanel(title = "4. Correlate",
        id = "process_single_station_step_4",
        value = "process_single_station_step_4",
        fluidRow(
            column(6,
                h4('Load sector data'),
                wellPanel(
                    fileInput('sectorDataFile', NULL, accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                    uiOutput("loadSectorDataText"),
                    "<a target=\"_blank\" href=sample_data/wheat_yield_nsw_1922-1999.csv>  wheat_yield_nsw_1922-1999.csv</a>"
                ),
                h4('Specify chart title'),
                wellPanel(
                    textInput("sectorPlotName", "Chart title:"),
                    checkboxInput("detrendCheck", "Detrend data", value = TRUE, width = NULL)
                )
            )
        ),
        fluidRow(
            column(12,
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