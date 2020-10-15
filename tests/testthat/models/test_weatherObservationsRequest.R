context("Validate weatherObservationsRequest")
source("../../../models/weatherObservationsRequest.R")

# Given user specified inputs
given_name <- "demo station"
given_latitude <- -42.0
given_longitude <- 143.3
given_dataFile <- data.frame()
given_basePeriodStartYear <- 1989L
given_basePeriodEndYear <- 2010L

# When weatherObservationsRequest created
result <- weatherObservationsRequest(given_name, 
                                given_latitude,
                                given_longitude,
                                given_dataFile,
                                given_basePeriodStartYear,
                                given_basePeriodEndYear
)

# Then all the things are correct
expect_equal(result$stationName, given_name)
expect_equal(result$latitude, given_latitude)
expect_equal(result$longitude, given_longitude)
expect_equal(result$dataFile, given_dataFile)
expect_equal(result$basePeriodStartYear, given_basePeriodStartYear)
expect_equal(result$basePeriodEndYear, given_basePeriodEndYear)

