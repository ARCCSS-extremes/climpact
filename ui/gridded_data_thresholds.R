tabPanel(title="Calculate gridded thresholds",
         fluidPage(
           useShinyjs(),
           fluidRow(
             column(12,
               h3("Calculate gridded thresholds"),
               h4("This page allows you to calculate thresholds on netCDF files. For use in calculating gridded indices where the base period resides in a different file.")
             ),
             column(4,
                    h4('1. Select input file(s)'),
                    wellPanel(
                      #shinyFilesButton('ncFileThresh', "Please select input file(s): ","File select",multiple=TRUE,class = NULL),
                      actionButton("selectNcFilesThresh", "Select NetCDF file(s)"),
                      textOutput("ncFilePrintThresh")),
                    h4('2. Enter input dataset infomation'),
                    wellPanel(
                      textInput("prNameThresh", "Name of precipitation variable:",value="precip"),
                      textInput("txNameThresh", "Name of maximum temperature variable:",value="tmax"), 
                      textInput("tnNameThresh", "Name of minimum temperature variable:",value="tmin")
                    )),
             column(4,
                    h4("3. Enter output parameters"),
                    wellPanel(
                      textInput("instituteNameThresh", "Enter your institute's name:"),
                      textInput("instituteIDThresh", "Enter your institute's ID:"),
                      numericInput("baseBeginThresh", "Start year of base period:", value=1991),
                      numericInput("baseEndThresh", "End year of base period:", value=2010),
                      #shinyDirButton("outDirThresh", "Select output directory", "Please select a folder"),
                      actionButton("selectOutDirThresh", "Select output directory"),
                      textOutput("outDirPrintThresh"),
                      textInput("outFileThresh", "Output filename:",value="sample_data.thresholds.1991-2010.nc")
                    )),
             column(4,
                    br(),
                    br(),
                    wellPanel(
                      numericInput("nCoresThresh", paste0("Number of cores to use (your computer has ",detectCores()," cores):"),value=1,min=1,max=detectCores())
                    ),
                    h4("4. Calculate"),
                    wellPanel(
                      actionButton("calculateGriddedThresholds", "Calculate NetCDF thresholds"),
                      textOutput("ncPrintThresh"),
                      textOutput("ncGriddedThreshDone")
                    )
                    )
             )
         )
)
