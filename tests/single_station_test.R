app <- ShinyDriver$new("../", loadTimeout = 15000)
app$snapshotInit("single_station_test", screenshot = FALSE)

justthethings <- list(
  input = c("process_single_station", "ui-baseEnd", "ui-baseStart",
    "ui-stationName", "ui-stationLat", "ui-stationLon", "ui-dataFile"),
  output = c("ui-indexCalculationErrors", "ui-indexCalculationStatus",
    "ui-qcLink", "ui-qcStatus",
    "ui-sectorCorrelationError", "ui-sectorCorrelationLink", "ui-sectorCorrelationStatus",
    "ui-sectorDataFile", "ui-sectorPlotTitle", "ui-y_axis_label")
)
app$snapshot(item = justthethings)
app$uploadFile(`ui-dataFile` = "../www/sample_data/sydney_observatory_hill_1936-2015.txt") # <-- This should be the path to the file, relative to the app's tests/ directory
# app$waitForValue("ui-stationName", ignore = "")
app$snapshot(item = justthethings)
app$setInputs(`ui-btn_next_step_1` = "click")
app$setInputs(`ui-doQualityControl` = "click", wait_ = FALSE, values_ = FALSE)
Sys.sleep(10)
app$snapshot(item = justthethings)
app$setInputs(`ui-btn_next_step_2` = "click")
app$snapshot(item = justthethings)
app$setInputs(`ui-calculateIndices` = "click", wait_ = FALSE, values_ = FALSE)
Sys.sleep(45)
app$snapshot(item = justthethings)
app$setInputs(`ui-btn_next_step_3` = "click")
app$snapshot(item = justthethings)
app$uploadFile(`ui-sectorDataFile` = "../www/sample_data/wheat_yield_nsw_1922-1999.csv") # <-- This should be the path to the file, relative to the app's tests/ directory
app$snapshot(item = justthethings)
app$setInputs(`ui-calculateSectorCorrelation` = "click", wait_ = FALSE, values_ = FALSE)
Sys.sleep(30)
app$snapshot(item = justthethings)
