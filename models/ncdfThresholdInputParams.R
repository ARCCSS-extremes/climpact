#' ncdfThresholdInputParams constructor
#'
#' new_ncdfThresholdInputParams isn't intended for external use.
#' Instead, use @seealso [ncdfThresholdInputParams()] which will validate arguments.
#'
new_ncdfThresholdInputParams <- function(prColName             = "",
                                txColName             = "",
                                tnColName             = "",
                                outputFileName        = "",
                                instituteID           = "",
                                instituteName         = "",
                                baseStart             = integer(),
                                baseEnd               = integer(),
                                numCores              = integer(),
                                verbose               = logical(),
                                fClimdexCompatible    = logical()) {
  # basic type validation
  stopifnot(is.character(prColName))
  stopifnot(is.character(txColName))
  stopifnot(is.character(tnColName))
  stopifnot(is.character(outputFileName))
  stopifnot(is.character(instituteID))
  stopifnot(is.character(instituteName))
  stopifnot(is.numeric(baseStart))
  stopifnot(is.numeric(baseEnd))
  if (!(is.logical(numCores) || is.numeric(numCores))) {
    stop("'numCores' option must be logical or numeric.")
  }
  stopifnot(is.logical(verbose))
  stopifnot(is.logical(fClimdexCompatible))

  if (prColName == "") { prColName <- "precip" }
  if (txColName == "") { txColName <- "tmax" }
  if (tnColName == "") { tnColName <- "tmin" }
  if (numCores < 2) { numCores <- FALSE }

  variableNameMap <- c(prec = prColName, tmax = txColName, tmin = tnColName)
  baseRange <- c(baseStart, baseEnd)
  authorData <- list(institution = instituteName, institutionID = instituteID)

  value <- structure(list(prColName             = prColName,
                          txColName             = txColName,
                          tnColName             = tnColName,
                          outputFileName        = outputFileName,
                          instituteID           = instituteID,
                          instituteName         = instituteName,
                          baseStart             = baseStart,
                          baseEnd               = baseEnd,
                          numCores              = numCores,
                          verbose               = verbose,
                          fClimdexCompatible    = fClimdexCompatible,
                          variableNameMap       = variableNameMap,
                          baseRange             = baseRange,
                          authorData            = authorData
                      ),
                      class = "ncdfThresholdInputParams"
                    )
  return(value)
}

#' ncdfThresholdInputParams validator
#'
#' This function will be called by @seealso [ncdfThresholdInputParams()]
#' when creating a new ncdfThresholdInputParams.
#'
#' Checks that request attributes are valid.
#' @param r A ncdfThresholdInputParams to validate
#'
#' @return If all attributes are valid, the ncdfThresholdInputParams is returned.
#' Otherwise an error is returned describing the problem with validation.
validate_ncdfThresholdInputParams <- function(p) {
  message <- ""

  if (message != "") {
    stop(message)
  }
  return(p)
}


#' ncdfThresholdInputParams constructor for consumers
#'
#' Creates a new ncdfThresholdInputParams and validates all attributes are valid.
#'
#' @param   op.choice       character
#' @param   constant.choice double
#'
#' @return  A ncdfThresholdInputParams object if all attributes are valid or otherwise, executes error action.
ncdfThresholdInputParams <- function(prColName    = "",
                            txColName             = "",
                            tnColName             = "",
                            outputFileName        = "",
                            instituteID           = "",
                            instituteName         = "",
                            baseStart             = integer(),
                            baseEnd               = integer(),
                            numCores              = 1,
                            fClimdexCompatible    = FALSE) {


  baseStart <- as.integer(baseStart)
  baseEnd <- as.integer(baseEnd)
  numCores <- as.integer(numCores)
  #fClimdexCompatible <- as.logical(fClimdexCompatible)

  # output compatible with FCLIMDEX. Leave this.
  fClimdexCompatible <- FALSE

  p <- new_ncdfThresholdInputParams(prColName,
                            txColName,
                            tnColName,
                            outputFileName,
                            instituteID,
                            instituteName,
                            baseStart,
                            baseEnd,
                            numCores,
                            fClimdexCompatible = fClimdexCompatible
                          )
  validate_ncdfThresholdInputParams(p)
}
