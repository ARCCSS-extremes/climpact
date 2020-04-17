ui <- tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "climpact-ui.js")
  ),
  useShinyjs(),
  dashboardPage(
    header = dashboardHeader(title = "ClimPACT"),
    sidebar = dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "home", icon = icon("sun")),
        menuItem("Process single station", tabName = "single", icon = icon("table")),
        menuItem("Batch process stations", tabName = "batch", icon = icon("layer-group")),
        menuItemOutput("griddedMenuItem"),
        menuItem("Documentation", icon = icon("book"), href = "user_guide/ClimPACT_user_guide.htm")
      )
    ),
    body = dashboardBody(
      tabItems(
          tabItem(
          tabName = "home",
          source(file.path("ui", "landing_page.R"), local = TRUE)$value
        ),
        tabItem(
          tabName = "single",
          source(file.path("ui", "single_station.R"), local = TRUE)$value
        ),
        tabItem(
          tabName = "batch",
          box(title="Process multiple stations", status = "primary", width = 12, solidHeader = TRUE,
            batchStep1UI("ui")
          )
        ),
        tabItem(
          tabName = "gridded-indices",
          box(title = "Calculate Gridded Indices", status = "primary", width = 12, solidHeader = TRUE,
            griddedStep1UI("ui")
          )
        ),
        tabItem(
          tabName = "gridded-thresholds",
          box(title = "Calculate Gridded Thresholds", status = "primary", width = 12, solidHeader = TRUE,
            griddedStep2UI("ui")
          )
        )
      )
    )
  ),
  tags$footer(
    div(
      id = "footer-content",
      div(
        id = "sitemap",
        h4("Climpact 2.0.0"),
        p("Copyright © 2012–2020"),
        p("Climpact."),
        p("All Rights Reserved.")
      ),
      div(
        id = "logos",
        HTML("<a href=\"https://www.unsw.edu.au\"><img src=\"assets/logo-unsw-small.png\" alt=\"UNSW Sydney\"></a>"),
        HTML("<a href=\"https://www.climateextremes.org.au/\"><img src=\"assets/logo-clex-small.png\" alt=\"ARC Centre of Excellence for Climate Extremes\"></a>"),
        HTML("<a href=\"https://public.wmo.int/\"><img src=\"assets/logo-wmo.png\" alt=\"World Meteorological Organization\"></a>"),
        HTML("<a href=\"https://www.greenclimate.fund\"><img src=\"assets/logo-gcf.png\" alt=\"Green Climate Fund\"></a>")
      )
    )
  )#, tags$script(HTML("disableTab('process_single_station_step_2')")),
  # tags$script(HTML("disableTab('process_single_station_step_3')")),
  # tags$script(HTML("disableTab('process_single_station_step_4')"))
)
