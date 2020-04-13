    # Validate sector dataset
    sectorDataFile <- reactive({
        validate(
            need(!is.null(input$sectorDataFile), message="Please load station data")
        )
        input$sectorDataFile
    })


    sectorPlotTitleMissing <- reactive({
      validate(
        need(input$sectorPlotName != "", message="Please enter a plot title")
      )
      ""
    })
     
    output$sectorCorrelationError <- eventReactive(input$calculateSectorCorrelation, {
      sectorPlotTitleMissing()
    })
    
    # output$qualityControlError <- eventReactive(input$doQualityControl, {
    #     stationName()
    # })
    # dataFile <- function () { "" }
    # output$qualityControlError <- eventReactive(input$calculateIndices, {
    #     dataFile()
    # })

    # output$indiceCalculationError <- eventReactive(input$calculateIndices, {
    #     plotTitleMissing()
    # })
