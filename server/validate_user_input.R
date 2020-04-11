    # Validate sector dataset
    sectorDataFile <- reactive({
        validate(
            need(!is.null(input$sectorDataFile), message="Please load a dataset")
        )
        input$sectorDataFile
    })

    plotTitleMissing <- reactive({
        validate(
            need(input$plotTitle != "", message="Please enter a plot title")
        )
        ""
    })

    sectorPlotTitleMissing <- reactive({
      validate(
        need(input$sectorPlotName != "", message="Please enter a plot title")
      )
      ""
    })
 
    # output$qualityControlError <- eventReactive(input$doQualityControl, {
    #     stationName()
    # })
    # dataFile <- function () { "" }
    # output$qualityControlError <- eventReactive(input$calculateIndices, {
    #     dataFile()
    # })

    output$indiceCalculationError <- eventReactive(input$calculateIndices, {
        plotTitleMissing()
    })
    
    output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
      sectorPlotTitleMissing()
    })