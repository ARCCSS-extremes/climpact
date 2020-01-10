tabPanel(title="Sector Data Correlation", fluidPage(
    fluidRow(
        column(6,
          h4('9. Load Sector Data'),
          wellPanel(
            fileInput('sectorDataFile', NULL,accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
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
               "Please complete step 11: ",
               tags$b("Calculate Correlation.")
             )
           )
        )
    )
))
