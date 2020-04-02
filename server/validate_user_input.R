
    # These element validate and return user input values.
    # Validate latitude
    stationLat <- reactive({
        validate(
            need(input$stationLat >= -90 && input$stationLat <= 90, "Latitude must be between -90 and 90.")
        )
        input$stationLat
    })

    # Validate longitude
    stationLon <- reactive({
        validate(
            need(input$stationLon >= -180 && input$stationLon <= 180, "Longitude must be between -180 and 180")
        )
        input$stationLon
    })

    # Validate station name
    stationName <- reactive({
        validate(
            need(input$stationName != "", message="Please enter a station name")
        )
        input$stationName
    })

    # Validate climate dataset
    dataFile <- reactive({
        validate(
            need(!is.null(input$dataFile), message="Please load a dataset")
        )
        input$dataFile
    })

    # Validate sector dataset
    sectorDataFile <- reactive({
        validate(
            need(!is.null(input$sectorDataFile), message="Please load a dataset")
        )
        input$sectorDataFile
    })

    plotTitleMissing <- reactive({
        validate(
            need(input$plotTitle != "", message="Please enter a plotting title")
        )
        ""
    })

    sectorPlotTitleMissing <- reactive({
      validate(
        need(input$sectorPlotName != "", message="Please enter a plotting title")
      )
      ""
    })


    # Update UI with validation text
    output$dataFileLoadedWarning <- reactive({ 
        dataFileLoadedText <- ""
        if (is.null(input$dataFile)) {
          dataFileLoadedText <- HTML("<div class= 'alert alert-warning' role='alert'><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span><span class='sr-only'>Error:</span> Please load a dataset</div>")
        } 
        else {
          dataFileLoadedText <- ""
        }
        return (dataFileLoadedText)
    })

    output$dataFileLoaded <- reactive({
        !is.null(input$dataFile)
    })
        
    output$qualityControlError <- eventReactive(input$doQualityControl, {
        stationName()
    })

    output$qualityControlError <- eventReactive(input$calculateIndices, {
        dataFile()
    })

    output$indiceCalculationError <- eventReactive(input$calculateIndices, {
        plotTitleMissing()
    })
    
    output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
      sectorPlotTitleMissing()
    })


