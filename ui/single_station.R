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
        singleStationStep4UI("ui")
    )
  )
)