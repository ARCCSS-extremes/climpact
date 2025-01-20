#' ncdfInputParams constructor
#'
#' new_ncdfInputParams isn't intended for external use.
#' Instead, use @seealso [ncdfInputParams()] which will validate arguments.
#'
new_ncdfInputParams <- function(prColName             = "",
                                txColName             = "",
                                tnColName             = "",
                                outputFileNamePattern       = "",
                                instituteID           = "",
                                instituteName         = "",
                                baseStart             = integer(),
                                baseEnd               = integer(),
                                indicesToCalculate    = character(),
                                ehfDefinition         = character(),
                                numCores              = integer(),
                                maxVals               = integer(),
                                axisName              = character(),
                                fClimdexCompatible    = logical()) {
  # basic type validation
  stopifnot(is.character(prColName))
  stopifnot(is.character(txColName))
  stopifnot(is.character(tnColName))
  stopifnot(is.character(outputFileNamePattern))
  stopifnot(is.character(instituteID))
  stopifnot(is.character(instituteName))
  stopifnot(is.numeric(baseStart))
  stopifnot(is.numeric(baseEnd))
  stopifnot(is.character(indicesToCalculate))
  stopifnot(is.character(ehfDefinition))
  if (!(is.logical(numCores) || is.numeric(numCores))) {
    stop("'numCores' option must be logical or numeric.")
  }
  stopifnot(is.numeric(maxVals))
  stopifnot(is.character(axisName))
  stopifnot(is.logical(fClimdexCompatible))

  if (prColName == "") { prColName <- "precip" }
  if (txColName == "") { txColName <- "tmax" }
  if (tnColName == "") { tnColName <- "tmin" }

  # Output filename format. Must use CMIP5 filename convention. i.e. "var_timeresolution_model_scenario_run_starttime-endtime.nc"
  if (outputFileNamePattern == "") {
    outputFileNamePattern <- "var_daily_climpact.sample_historical_NA_1991-2010.nc"
  }

  if (numCores < 2) { numCores <- FALSE }

  variableNameMap <- c(prec = prColName, tmax = txColName, tmin = tnColName)
  baseRange <- c(baseStart, baseEnd)
  authorData <- list(institution = instituteName, institutionID = instituteID)
  if (indicesToCalculate == "") {
    indicesToCalculate <- NULL
  } else {
    indicesToCalculate <- strsplit(indicesToCalculate, ",")
  }


  value <- structure(list(prColName             = prColName,
                          txColName             = txColName,
                          tnColName             = tnColName,
                          outputFileNamePattern = outputFileNamePattern,
                          instituteID           = instituteID,
                          instituteName         = instituteName,
                          baseStart             = baseStart,
                          baseEnd               = baseEnd,
                          indicesToCalculate    = indicesToCalculate,
                          ehfDefinition         = ehfDefinition,
                          numCores              = numCores,
                          maxVals               = maxVals,
                          axisName              = axisName,
                          fClimdexCompatible    = fClimdexCompatible,
                          variableNameMap       = variableNameMap,
                          baseRange             = baseRange,
                          authorData            = authorData
                      ),
                      class = "ncdfInputParams"
                    )
  return(value)
}

#' ncdfInputParams validator
#'
#' This function will be called by @seealso [ncdfInputParams()]
#' when creating a new ncdfInputParams.
#'
#' Checks that request attributes are valid.
#' @param r A ncdfInputParams to validate
#'
#' @return If all attributes are valid, the ncdfInputParams is returned.
#' Otherwise an error is returned describing the problem with validation.
validate_ncdfInputParams <- function(p) {
  message <- ""

  if (message != "") {
    stop(message)
  }
  return(p)
}


#' ncdfInputParams constructor for consumers
#'
#' Creates a new ncdfInputParams and validates all attributes are valid.
#'

#' @param   op.choice       character
#' @param   constant.choice double
#'
#' @return  A ncdfInputParams object if all attributes are valid or otherwise, executes error action.
ncdfInputParams <- function(prColName             = "",
                            txColName             = "",
                            tnColName             = "",
                            outputFileNamePattern = "",
                            instituteID           = "",
                            instituteName         = "",
                            baseStart             = integer(),
                            baseEnd               = integer(),
                            indicesToCalculate    = "",
                            ehfDefinition         = "NF13",
                            numCores              = 1,
                            maxVals               = 10,
                            axisName              = "Y",
                            fClimdexCompatible    = FALSE) {


  baseStart <- as.integer(baseStart)
  baseEnd <- as.integer(baseEnd)
  numCores <- as.integer(numCores)
  maxVals <- as.integer(maxVals)
  fClimdexCompatible <- as.logical(fClimdexCompatible)

  # Directory where Climpact is stored. Use full pathname.
  # Leave as NULL if you are running this script from the Climpact directory
  # (where this script was initially stored).
  #root.dir <- NULL
  # axis to split data on. For chunking up of grid, leave this.
  axisName <- "Y"
  # output compatible with FCLIMDEX. Leave this.
  fClimdexCompatible <- FALSE

  p <- new_ncdfInputParams(prColName,
                            txColName,
                            tnColName,
                            outputFileNamePattern,
                            instituteID,
                            instituteName,
                            baseStart,
                            baseEnd,
                            indicesToCalculate,
                            ehfDefinition,
                            numCores,
                            maxVals,
                            axisName = axisName,
                            fClimdexCompatible = fClimdexCompatible
                          )
  validate_ncdfInputParams(p)
}
