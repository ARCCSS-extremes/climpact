#' sectorInputParams constructor
#'
#' new_sectorInputParams isn't intended for external use.
#' Instead, use @seealso [sectorInputParams()] which will validate arguments.
#'
#' @param sectorDataFile  dataframe Describes the sector data provided by the user @seealso [shiny::fileInput()]
#' @param detrendData     logical   Determines if a detrended data column is calculated and used.
#' @param sectorPlotTitle character Title to display on plots
#'
#' @return A sectorInputParams object.
new_sectorInputParams <- function(sectorDataFile = NULL,
                                  sectorPlotTitle = "",
                                  detrendData = logical(),
                                  y_axis_label = "") {
  stopifnot(is.character(sectorPlotTitle))
  stopifnot(is.logical(detrendData))
  stopifnot(is.character(y_axis_label))

  value <- structure(list(sectorDataFile  = reactiveVal(sectorDataFile),
                          sectorPlotTitle = reactiveVal(sectorPlotTitle),
                          detrendData     = reactiveVal(detrendData),
                          y_axis_label    = reactiveVal(y_axis_label)
                      ),
                      class = "sectorInputParams"
                    )
  return(value)
}

#' sectorInputParams validator
#'
#' This function will be called by @seealso [sectorInputParams()]
#' when creating a new sectorInputParams.
#'
#' Checks that request attributes are valid.
#' @param r A sectorInputParams to validate
#'
#' @return If all attributes are valid, the sectorInputParams is returned.
#' Otherwise an error is returned describing the problem with validation.
validate_sectorInputParams <- function(p) {
  message <- ""
  if (is.null(p$sectorDataFile)) {
    message <- "Sector data file must be provided."
  }
  if (p$sectorPlotTitle() == "") {
    message <- paste(message, "Plot title must be provided.")
  }
  if (message != "") {
    stop(message)
  }
  return(p)
}

#' sectorInputParams constructor for consumers
#'
#' Creates a new sectorInputParams and validates all attributes are valid.
#'
#' @param sectorDataFile  dataframe Describes the sector data provided by the user @seealso [shiny::fileInput()]
#' @param detrendData     logical   Determines if a detrended data column is calculated and used.
#' @param sectorPlotTitle character Title to display on plots
#'
#' @return  A sectorInputParams object if all attributes are valid or otherwise, executes error action.
sectorInputParams <- function(sectorDataFile = NULL, sectorPlotTitle = "", detrendData = logical(), y_axis_label = "") {
  detrendData <- as.logical(detrendData)
  p <- new_sectorInputParams(sectorDataFile, sectorPlotTitle, detrendData, y_axis_label)
  validate_sectorInputParams(p)
}