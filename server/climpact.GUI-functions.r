source("services/check/boxseries.R", local = TRUE)
source("services/check/duplivals.R", local = TRUE)
source("services/check/flatline_tn.R", local = TRUE)
source("services/check/flatline_tx.R", local = TRUE)
source("services/check/fourboxes.R", local = TRUE)
source("services/check/humongous.R", local = TRUE)
source("services/check/jumps_tn.R", local = TRUE)
source("services/check/jumps_tx.R", local = TRUE)
source("services/check/plot_qc.R", local = TRUE)
source("services/check/roundcheck.R", local = TRUE)
source("services/check/tmaxmin.R", local = TRUE)
source("services/check/plot_qc.R", local = TRUE)

# A function that should be called before any .csv file is written. It appends some basic information that should be stored in each file for
# the user's record.
write_header <- function(filename, header = "", metadata) {
  if (is.null(filename)) { stop("Filename not passed to function 'write_header'") }

  header = cbind("Description: ", header)
  # No error checking here, file access is guaranteed because ClimPACT has own copy.
  write.table(header, sep = ",", file = filename, append = FALSE, row.names = FALSE, col.names = FALSE)

  first_lines = cbind(c("Station: ", "Latitude: ", "Longitude: ", "ClimPACT_version: ", "Date_of_calculation: "), c(metadata$stationName, metadata$lat, metadata$lon, version.climpact, toString(Sys.Date())))
  write.table(first_lines, sep = ",", file = filename, append = TRUE, row.names = FALSE, col.names = FALSE)

}

check_open <- function(filename) {
  # No error checking here, file access is guaranteed because ClimPACT has own copy.
  write.table("test text", sep = ",", file = filename, append = FALSE, row.names = FALSE, col.names = FALSE)
}
# End of Prohom and Aguilar code.

write.NA.statistics <- function(cio, outputFolders, metadata) {
  naprec = array(NA, dim = c(length(unique(cio@date.factors$annual))))
  naprec = tapply.fast(cio@data$prec, cio@date.factors$annual, function(x) { return(sum(is.na(x))) })
  natx = tapply.fast(cio@data$tmax, cio@date.factors$annual, function(x) { return(sum(is.na(x))) })
  natn = tapply.fast(cio@data$tmin, cio@date.factors$annual, function(x) { return(sum(is.na(x))) })

  nam1 <- file.path(outputFolders$outqcdir, paste0(outputFolders$stationName, "_nastatistics.csv"))
  write_header(nam1, "", metadata = metadata)
  # Suppress warning about column names in files
  suppressWarnings(write.table(cbind.data.frame(unique(cio@date.factors$annual), naprec, natx, natn), file = nam1, sep = ",", append = TRUE, quote = FALSE, row.names = FALSE, col.names = c("Year", "Prec", "TX", "TN")))
}

# returns a date time-series from user data, removes any non-gregorian dates and corresponding data in the process
create_user_data_ts <- function(user_data) {
  yyymmdd <- paste(user_data[, 1], user_data[, 2], user_data[, 3], sep = "-")
  user.dates <- as.Date(yyymmdd, format = "%Y-%m-%d")

  year <- user_data$year[!is.na(user.dates)]
  month <- user_data$month[!is.na(user.dates)]
  day <- user_data$day[!is.na(user.dates)]
  prcp <- user_data$prcp[!is.na(user.dates)]
  tmax <- user_data$tmax[!is.na(user.dates)]
  tmin <- user_data$tmin[!is.na(user.dates)]

  user_data_ts <- data.frame(year = year, month = month, day = day, precp = prcp, tmax = tmax, tmin = tmin)
  user_data_ts$dates <- user.dates[!is.na(user.dates)]
  
  return(user_data_ts)
}

# Given a user's RClimdex text file path, read in, convert -99.9 to NA and
# return contents as array of 6 columns.
read_user_file <- function(user_file_path) {
  temp_filename = tempfile()
  sub <- tryCatch({      
    raw.table = readLines(user_file_path)
    newtext = gsub(",", "\t", raw.table)
    cat(newtext, file = temp_filename, sep = "\n")    
  },
  error = function(cond) {
    readUserFileError(paste("Error creating temporary file",cond$message), cond)
  })

  out <- tryCatch({
    data <- read.table(temp_filename, header = F, col.names = c("year", "month", "day", "prcp", "tmax", "tmin"), colClasses = rep("real", 6))
    # Replace -99.9 data with NA
    if (!is.null(data)) {
      print(str(data))
      data$prcp[data$prcp == -99.9] = NA
      data$tmax[data$tmax == -99.9] = NA
      data$tmin[data$tmin == -99.9] = NA
    }
    return(data)
  },
  error = function(cond) {
    readUserFileError(paste("Error reading table data in file",cond$message), cond)
  })
  return(out)
}

# return True (T) if leapyear, esle F
leapyear <- function(year) {
  remainder400 <- trunc(year - 400 * trunc(year / 400));
  remainder100 <- trunc(year - 100 * trunc(year / 100));
  remainder4 <- trunc(year - 4 * trunc(year / 4));
  if (remainder400 == 0) leapyear <- TRUE else {
    if (remainder100 == 0) leapyear <- FALSE else {
      if (remainder4 == 0) leapyear <- TRUE else leapyear <- FALSE;
    }
  }
}

# Check for required packages and install if necessary
package.check <- function() {
  packages <- c("abind", "bitops", "Rcpp", "caTools", "PCICt", "SPEI", "climdex.pcic", "ncdf4", "snow", "udunits2", "functional", "proj4", "foreach", "doParallel", "doSNOW", "zoo", "zyp", "tcltk2",
                "shiny", "shinythemes", "markdown", "servr", "dplyr", "corrplot", "ggplot2", "shinyjs")
  new.packages <- packages[!(packages %in% installed.packages()[, "Package"])]

  # Install/update packages needed for ClimPACT
  if (length(new.packages)) {
    print("******************************")
    print(paste("The following packages are not installed...", new.packages, sep = ""))
    print("Running master install script (this only needs to occur once).")
    # source("services/climpact.master.installer.r")
    print("Continuing with ClimPACT execution...")
    print("******************************")
  }
}
