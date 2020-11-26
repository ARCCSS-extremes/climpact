#' weatherObservationsRequest constructor
#' 
#' new_weatherObservationsRequest isn't intended for external use.
#' Instead, use @seealso [weatherObservationsRequest()] which will validate arguments.
#' 
new_weatherObservationsRequest <- function(stationName = character(),
                                      latitude = double(),
                                      longitude = double(),
                                      dataFile,
                                      basePeriodStartYear = integer(),
                                      basePeriodEndYear = integer()) {
  # basic type validation
  stopifnot(is.character(stationName))
  stopifnot(is.double(latitude))
  stopifnot(is.double(longitude))
  stopifnot(is.integer(basePeriodStartYear))
  stopifnot(is.integer(basePeriodEndYear))

  value <- structure(list(stationName = stationName,
                      latitude = latitude,
                      longitude = longitude,
                      dataFile = dataFile,
                      basePeriodStartYear = basePeriodStartYear,
                      basePeriodEndYear = basePeriodEndYear),
                      class = "weatherObservationsRequest"
                    )
  return(value)
}

#' weatherObservationsRequest validator
#' 
#' This function will be called by @seealso [weatherObservationsRequest()] 
#' when creating a new weatherObservationsRequest.
#' 
#' Checks that request attributes are valid.
#' @param r A weatherObservationsRequest to validate
#' 
#' @return If all attributes are valid, the weatherObservationsRequest is returned. 
#' Otherwise an error is returned describing the problem with validation.
validate_weatherObservationsRequest <- function(r) {
  if(length(r$stationName) == 0) {
    stop("Station name must not be empty.")
  }
  if (r$latitude > 90 || r$latitude < -90) {
    stop("Latitude must be between -90 and 90.")
  }
  if (r$longitude > 180 || r$longitude < -180) {
    stop("Longitude must be between -180 and 180")
  }
  return(r)


}


#' weatherObservationsRequest constructor for consumers
#' 
#' Creates a new weatherObservationsRequest and validates all attributes are valid.
#' 
#' @param   stationName         character Station name
#' @param   latitude            double    Station latitude in decimal degrees
#' @param   longitude           double    Station longitude in decimal degrees
#' @param   dataFile            dataframe Describes (via name, size, type, datapath) the file containing weather observations provided by the user @seealso [shiny::fileInput()]
#' @param   basePeriodStartYear integer   First year to use in calculations. Must be equal or greater than first year in file.
#' @param   basePeriodEndYear   integer   Last year to use in calculations. Must be equal or lesser than last year in file.
#' 
#' @return  A weatherObservationsRequest object if all attributes are valid or otherwise, executes error action.
weatherObservationsRequest <- function(stationName = character(),
                                      latitude = double(),
                                      longitude = double(),
                                      dataFile,
                                      basePeriodStartYear = integer(),
                                      basePeriodEndYear = integer()) {
  latitude <- as.double(latitude)
  longitude <- as.double(longitude)
  basePeriodStartYear <- as.integer(basePeriodStartYear)
  basePeriodEndYear <- as.integer(basePeriodEndYear)
  r <- new_weatherObservationsRequest(stationName, latitude, longitude, dataFile, basePeriodStartYear, basePeriodEndYear)
  validate_weatherObservationsRequest(r)  
}