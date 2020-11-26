#' Zip files in folder and return file path to zip file created.
#' 
#' @param folderToZip           character The folder to zip
#' @param excludePattern        character Exclude matching directories or files from zip file created.
#' @param destinationFolder     character Path to folder where zip file should be created.
#'                                        By default zipFiles will create the zip file in the parent folder of the folder to zip.
#'                                        This can be overridden by supplying a valid value for destinationFolder.
#' @param destionationFileName  character Name of the zip file to be created. If this is not supplied, the file name will be 
#'                                        the name of the folderToZip with a .zip extension.
#' 
#' @return zipFilePath    character The path to the generated zip file
zipFiles <- function (folderToZip, excludePattern = "", destinationFolder = "", destinationFileName = "") {
  if (destinationFolder == "") {
    folderName <- dirname(folderToZip)
  } else {
    folderName <- destinationFolder
  }
  if (destinationFileName == "") {
    parentName <- basename(dirname(folderToZip))
    fileName <- paste0(parentName, "_", basename(folderToZip), ".zip")
  } else {
    fileName <- destinationFileName
  }

  # get zipping
  zipFilePath <- ""
  filesToZip <- dir(folderToZip)
  if (length(filesToZip > 0)) {
    zipFilePath <- file.path(folderName, fileName)
    originalwd <- getwd()
    setwd(folderToZip)
    if (excludePattern == "") {
      zip(zipfile = zipFilePath, files = filesToZip)
    } else {
      zip(zipfile = zipFilePath,
        files = filesToZip,
        extras = paste0("-x ", excludePattern))
    }
    setwd(originalwd)

    cat("zipFilePath zipped to: ", zipFilePath, "\n")
    if (isLocal) {
      zipFilePath <- file.path(folderName, fileName)
    } else {
      # strip shinyapps.io path
      zipFilePath <- paste0("output/", fileName)
    }
    cat("isLocal", isLocal)
    cat("zipFilePath returned to page: ", zipFilePath, "\n")
  }
  return(zipFilePath)
}