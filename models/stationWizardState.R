#' stationWizardState constructor
#' 
#' new_stationWizardState isn't intended for external use.
#' Instead, use @seealso [stationWizardState()] which will validate arguments.
#' 
new_stationWizardState <- function(stationName = character(),
                                      latitude = double(),
                                      longitude = double(),
                                      dataFile = NULL,
                                      startYear = integer(),
                                      endYear = integer(),
                                      qualityCheckErrors = character(),
                                      climdexInput = NULL) {
  # basic type validation
  stopifnot(is.character(stationName))
  stopifnot(is.double(latitude))
  stopifnot(is.double(longitude))
  stopifnot(is.integer(startYear))
  stopifnot(is.integer(endYear))

  value <- structure(list(stationName = stationName,
                          latitude = latitude,
                          longitude = longitude,
                          dataFile = dataFile,
                          startYear = startYear,
                          endYear = endYear,
                          qualityCheckErrors = character(),
                          climdexInput = NULL,
                          outputFolders = list()
                      ),
                      validate = validate_stationWizardState,
                      class = "stationWizardState"
                    )
  return(value)
}

#' stationWizardState validator
#' 
#' This function will be called by @seealso [stationWizardState()] 
#' when creating a new stationWizardState.
#' 
#' Checks that request attributes are valid.
#' @param r A stationWizardState to validate
#' 
#' @return If all attributes are valid, the stationWizardState is returned. 
#' Otherwise an error is returned describing the problem with validation.
validate_stationWizardState <- function(r) {
  if(length(r$stationName) == 0) {
    stop("Station name must not be empty.")
  }
  if (r$latitude > 90 || r$latitude < -90) {
    stop("Latitude must be between -90 and 90.", call. = FALSE)
  }
  if (r$longitude > 180 || r$longitude < -180) {
    stop("Longitude must be between -180 and 180", call. = FALSE)
  }
  return(r)


}


#' stationWizardState constructor for consumers
#' 
#' Creates a new stationWizardState and validates all attributes are valid.
#' 
#' @param   stationName         character Station name
#' @param   latitude            double    Station latitude in decimal degrees
#' @param   longitude           double    Station longitude in decimal degrees
#' @param   dataFile            dataframe Describes (via name, size, type, datapath) the file containing weather observations provided by the user @seealso [shiny::fileInput()]
#' @param   startYear           integer   First year to use in calculations. Must be equal or greater than first year in file.
#' @param   endYear             integer   Last year to use in calculations. Must be equal or lesser than last year in file.
#' @param   qualityCheckErrors  character All errors obtained performing quality checks on dataFile
#' @param   climdexInput        object    Climdex input object created from dataFile using climdex.pcic package
#'
#' @return  A stationWizardState object if all attributes are valid or otherwise, executes error action.
stationWizardState <- function(stationName = character(),
                                latitude = double(),
                                longitude = double(),
                                dataFile = NULL,
                                startYear = integer(),
                                endYear = integer(),
                                qualityCheckErrors = character(),
                                climdexInput = NULL) {
  latitude <- as.double(latitude)
  longitude <- as.double(longitude)
  startYear <- as.integer(startYear)
  endYear <- as.integer(endYear)
  
  r <- new_stationWizardState(stationName, latitude, longitude, dataFile, 
                              startYear, endYear, qualityCheckErrors, climdexInput)
  # don't call validate_stationWizardState(r) now
}