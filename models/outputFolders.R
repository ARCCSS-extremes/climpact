# outputFolders constructor
new_outputFolders <- function(baseFolder = character(), stationName = character()) {
  # basic type validation
  stopifnot(is.character(baseFolder))
  stopifnot(is.character(stationName))

  outinddir <- file.path(baseFolder, stationName, "indices")
  outlogdir <- file.path(baseFolder, stationName, "qc")
  outjpgdir <- file.path(baseFolder, stationName, "plots")
  outtrddir <- file.path(baseFolder, stationName, "trend")
  outqcdir <- file.path(baseFolder, stationName, "qc") # save results from extraqc
  outthresdir <- file.path(baseFolder, stationName, "thres") # to save *_thres.csv files
  zipfile <- file.path(baseFolder, stationName, ".zip")
  corrdir <- file.path(baseFolder, stationName, "corr") # save correlation files

  # create structure
  value <- structure(list(baseFolder  = baseFolder,
                          stationName = stationName,
                          outinddir   = outinddir,
                          outlogdir   = outlogdir,
                          outjpgdir   = outjpgdir,
                          outtrddir   = outtrddir,
                          outqcdir    = outqcdir,
                          outthresdir = outthresdir,
                          zipfile     = zipfile,
                          corrdir     = corrdir),
                          class = "outputFolders"
                    )
  return(value)
}

# outputFolders validator
validate_outputFolders <- function(s) {
  if (length(s$baseFolder) == 0) {
    stop("baseFolder must not be empty.")
  }
  if (length(s$stationName) == 0) {
    stop("stationName must not be empty.")
  }
  return(s)
}

# Helper function for consumers
outputFolders <- function(baseFolder = character(), stationName = character()) {
  f <- new_outputFolders(baseFolder, stationName)
  validate_outputFolders(f)
  createFolders(f)
  return(f)
}

createFolders <- function(outputFolders) {
  # Create subdirectories if non-existent
  if (!file.exists(outputFolders$outinddir)) { dir.create(outputFolders$outinddir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$outlogdir)) { dir.create(outputFolders$outlogdir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$outjpgdir)) { dir.create(outputFolders$outjpgdir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$outtrddir)) { dir.create(outputFolders$outtrddir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$outqcdir)) { dir.create(outputFolders$outqcdir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$outthresdir)) { dir.create(outputFolders$outthresdir, showWarnings = FALSE, recursive = TRUE) }
  if (!file.exists(outputFolders$corrdir)) { dir.create(outputFolders$corrdir, showWarnings = FALSE, recursive = TRUE) }
}