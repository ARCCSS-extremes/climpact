tabPanel(title="Calculate Climate Indices", value="calculateIndices", fluidPage(
    h4('6. Input User Parameters'),
    wellPanel(
    fluidRow(
        column(6,
            textInput("plotTitle", "Plot title:")
        )
    ),
    hr(),
    fluidRow(
        column(12,
            uiOutput("loadParamHelpText"),
            br(),
            br()
        )
    ),
    fluidRow(
        column(4,
            numericInput("wsdin", "d for WSDId Days (1 =< d <= 10):", 1, min = 1, max = 10),
            numericInput("csdin", "d for CSDId Days (1 =< d <= 10):", 1, min = 1,max = 10),
            numericInput("rxnday", "d for Rxdday Days (d >= 1):", 3, min = 1),
            numericInput("txtn", "d for TXdTNd and TXbdTNbd (d >= 1):", 2, min = 1)
        ),
        column(4,
            numericInput("hdd", "Base temperature for HDDHeat:", 18),
            numericInput("cdd", "Base temperature for CDDHeat:", 18),
            numericInput("gdd", "Base temperature for GDDgrow:", 10),
            numericInput("rnnmm", "Number of days precip >= nn (Rnnmm; nn >= 0):", 30, min = 0),
            numericInput("spei", "SPEI/SPI custom monthly time scale (must be a positive number):", 24, min = 1)
        ),
        column(4,
            strong("Custom index counting days above or below a given threshold (e.g. number of days where TX > 40, named TXgt40)"),
            br(),
            selectInput("custVariable", label="Variable:",
                choices = list("TN", "TX", "TM", "PR", "DTR"),
                selected = "TN"
            ),
            selectInput("custOperation", label="Operation:",
                choices = list(">", ">=", "<", "<="),
                selected = ">"
            ),
            numericInput("custThreshold", "Threshold:", 0)
        )
    )),
    fluidRow(
        column(6,
            h4('7. Calculate Indices'),
            conditionalPanel(
                condition = "output.qualityControlError == ''",
                wellPanel(
                    actionButton("calculateIndices", "Calculate Indices"),
                    textOutput("indiceCalculationError")
                )
            ),
            conditionalPanel(
                condition = "output.qualityControlError != ''",
                wellPanel(
                    "Please complete ",
                    tags$b("Load and Check Data")
                )
            )
        ),
        column(6,
            h4('8. View Indices'),
            conditionalPanel(
                condition = "output.indiceCalculationError == ''",
                wellPanel(
                    uiOutput("indicesLink")
                )
            ),
            conditionalPanel(
                condition = "output.indiceCalculationError != ''",
                wellPanel(
                    "Please complete step 7: ",
                    tags$b("Calculate Indices.")
                )
            )
        )
    )
))

