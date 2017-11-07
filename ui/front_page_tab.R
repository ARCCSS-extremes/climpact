tabPanel(title="ClimPACT",value="frontPage",
  fluidPage(
    fluidRow(
      column(12, HTML('<a href="https://github.com/ARCCSS-extremes/climpact2"><img src="user_guide/images/ClimPACT_logo_50pc.png"></a>'),align="center")
    ),
    br(),br(),br(),
    includeMarkdown(file.path("ui", "getting_started.md")),
    br(),br(),br(),br(),br(),br(),
    fluidRow(
      column(12, HTML('<a href="https://www.unsw.edu.au/"><img src="unsw_sydney_30pc.png"></a>'),align="center")
    )
  )
)
