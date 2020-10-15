box(title = "Process Single Station", status = "primary", width = 12, solidHeader = TRUE,
  tabBox(id = "process_single_station", width = 12,
    tabPanel(title = tagList(HTML("1. Load&nbsp;&nbsp;&nbsp;&nbsp;")),
        id = "process_single_station_step_1",
        value = "process_single_station_step_1",
        singleStationStep1UI("ui")
    ),
    tabPanel(title = tagList(icon("chevron-circle-right"), HTML("&nbsp;&nbsp;&nbsp;"), HTML("2. Check&nbsp;&nbsp;&nbsp;&nbsp;")),
        id = "process_single_station_step_2",
        value = "process_single_station_step_2",
        singleStationStep2UI("ui")
    ),
    tabPanel(title = tagList(icon("chevron-circle-right"), HTML("&nbsp;&nbsp;&nbsp;"), HTML("3. Calculate&nbsp;&nbsp;&nbsp;&nbsp;")),
        id = "process_single_station_step_3",
        value = "process_single_station_step_3",
        singleStationStep3UI("ui")
    ),
    tabPanel(title = tagList(icon("chevron-circle-right"), HTML("&nbsp;&nbsp;&nbsp;"), HTML("4. Correlate&nbsp;&nbsp;&nbsp;&nbsp;")),
        id = "process_single_station_step_4",
        value = "process_single_station_step_4",
        singleStationStep4UI("ui")
    )
  )
)