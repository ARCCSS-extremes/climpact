#' Zip files in folder and return file path to zip file created.
#' 
#' @param folderToZip     character The folder to zip
#' @param excludePattern  character Exclude matching directories or files from zip file created.
#' 
#' @return zipFilePath    character The path to the generated zip file
zipFiles <- function (folderToZip, excludePattern = "") {
  fileName <- paste0(basename(folderToZip), ".zip")
  folderName <- dirname(folderToZip)
  zipFilePath <- file.path(folderName, fileName)
  filesToZip <- dir(folderToZip)
  originalwd <- getwd()
  setwd(folderToZip)
  if (excludePattern == "") {
    zip(zipfile = zipFilePath, files = filesToZip)
  } else {
    zip(zipfile = zipFilePath, files = filesToZip, extras = paste0("-x ", excludePattern))
  }
  setwd(originalwd)
  stationName = basename(folderName)
  return(zipFilePath)
}