
# Define global variables. The use of global variables is undesirable from a programming point of view
# but for historical purposes is still used in this code.
#global.vars <- function() {
  # Nullify objects globally to avoid warning messages.
  # reading.pb <- process.pb <- pb <- orig.name.user <- qc.yes <- outthresdir <- NULL
  # quantiles <- cio <- ofilename <- infor1 <- orig.name <- title.station <- NULL
  # outlogdir <- thres.calc <- add.data <- add.data.name <- out <- ref.start <- NULL
  # ts.end <- basetmin <- basetmax <- baseprec <- start.but <- cal.but <- ttmp <- NULL
  
# minimum number of data points for plotting a linear trend
#}

# Creates an array of strings, each string containing a folder in the path to the user's file.
# Globally assigns two variables: the array of strings and the final string (i.e. the file name)
# This should be improved in the future (global variables should not be relied on)
# get_file_path <- function(user.file, ofilename) {
#   outdirtmp <- strsplit(user.file, "/|\\\\")[[1]]
#   file.name = outdirtmp[length(outdirtmp)]
#   e = strsplit(file.name, "\\.")[[1]]
#   if (ofilename == "") {
#     ofilename = substr(file.name, start = 1, stop = nchar(file.name) - nchar(e[length(e)]) - 1)
#   }
#   outdirtmp <- outdirtmp[-length(outdirtmp)]
#   outdirtmp = paste(outdirtmp, sep = "/", collapse = "/")
#   outdirtmp = paste(outdirtmp, ofilename, sep = "/")

# }
