box(title = "Calculate Gridded Indices", status = "primary", width = 12, solidHeader = TRUE,
    fluidRow(
        column(12,
               div("This page allows you to calculate the indices on netCDF files."),

            h4("1. Select input file(s)"),
            wellPanel(
              actionButton("selectNcFiles", "Select NetCDF file(s)"),
              textOutput("ncFilePrint")),
            h4("2. Enter input dataset infomation"),
            wellPanel(
              textInput("prName", "Name of precipitation variable:",value="precip"),
              textInput("txName", "Name of maximum temperature variable:",value="tmax"),
              textInput("tnName", "Name of minimum temperature variable:",value="tmin")
            )
        ,
            h4("3. Enter output parameters"),
            wellPanel(
              textInput("fileConvention", "Output filename format (must use CMIP5 filename convention. e.g. 'var_daily_climpact.sample_historical_NA_1991-2010.nc'):",value="var_daily_climpact.sample_historical_NA_1991-2010.nc"),
              textInput("instituteName", "Enter your institute's name:"),
              textInput("instituteID", "Enter your institute's ID:"),
              numericInput("baseBegin", "Start year of base period:", value=1991),
              numericInput("baseEnd", "End year of base period:", value=2010),
              actionButton("selectOutDir", "Select output directory"),
              textOutput("outDirPrint")
        ),
            h4("4. Enter other parameters"),
            wellPanel(
              numericInput("nCores", paste0("Number of cores to use (your computer has ",detectCores()," cores):"),value=1,min=1,max=detectCores()),
              textInput("calcIndices", "Indices to calculate. Leave empty to calculate all indices, otherwise provide a comma-separated list of index names in lower case (e.g. txxm, tn90p)):"),
              actionButton("selectNcFilesThreshInput", "Select threshold file (OPTIONAL)"),
              textOutput("ncFilePrintThreshInput"),
              selectInput("EHFcalc",label=("Select EHF calculation: "),choices=list("Perkins & Alexander (2013)"="PA13","Nairn & Fawcett (2013)"="NF13"),selected=1),
              textInput("maxVals", "Number of data values to process at once (do not change unless you know what you are doing):",value=10)
            ),
            h4("5. Calculate"),
            wellPanel(
              actionButton("calculateGriddedIndices", "Calculate NetCDF indices"),
              textOutput("ncPrint"),
              textOutput("ncGriddedDone")
            )
        )
    )
)
