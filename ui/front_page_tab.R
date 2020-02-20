tabPanel(title="ClimPACT",value="frontPage",
  fluidPage(
    fluidRow(
      column(12, HTML('<a href="https://github.com/ARCCSS-extremes/climpact" target="_blank"><img src="user_guide/images/ClimPACT_logo_50pc.png"></a>'),align="center")
    ),
    br(),br(),br(),
    includeMarkdown(file.path("ui", "getting_started.md")),
    br(),br(),br(),br(),br(),br()
  )
)
