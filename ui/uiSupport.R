# Global property bag
source("models/climpactUI.R")
climpactUI <- climpactUI("ui")


# Global functions

#' Returns first parameter if running locally or second parameter value if running remotely
#' 
#' @param localLink character The value to return if code is executing locally.
#' @param remoteLink character The value to return if code is executing remotely.
localOrRemoteLink <- function (localLink, remoteLink) {
  result <- remoteLink
  if (isLocal) { result <- localLink }
  return(result)
}

#' Returns link HTML for specified filePath, with text as the specified linkText
#' 
#' @param filePath character The path to a resource. Spaces will be replaced with %20, the HTML encoding for a space.
#' @param linkText character The text to display for the link.
getLinkFromPath <- function (filePath, linkText) {
  return (paste0("<a target=\"_blank\" href=", gsub(" ","%20",filePath), ">", linkText, "</a>"))
}
