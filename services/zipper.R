#' Zip files in folder and return file path to zip file created.
zipFiles <- function (folderToZip) {
  fileName <- paste0(basename(folderToZip), ".zip")
  folderName <- dirname(folderToZip)
  zipFilePath <- file.path(folderName, fileName)
  filesToZip <- dir(folderToZip)
  originalwd <- getwd()
  setwd(folderToZip)
  zip(zipfile = zipFilePath, files = filesToZip)
  setwd(originalwd)
  stationName = basename(folderName)
  return(zipFilePath)
}