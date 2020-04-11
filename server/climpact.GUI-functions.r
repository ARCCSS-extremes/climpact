source("server/quality_control/boxseries.R", local = TRUE)
source("server/quality_control/duplivals.R", local = TRUE)
source("server/quality_control/flatline_tn.R", local = TRUE)
source("server/quality_control/flatline_tx.R", local = TRUE)
source("server/quality_control/fourboxes.R", local = TRUE)
source("server/quality_control/humongous.R", local = TRUE)
source("server/quality_control/jumps_tn.R", local = TRUE)
source("server/quality_control/jumps_tx.R", local = TRUE)
source("server/quality_control/plot_qc.R", local = TRUE)
source("server/quality_control/roundcheck.R", local = TRUE)
source("server/quality_control/tmaxmin.R", local = TRUE)
source("server/quality_control/plot_qc.R", local = TRUE)

# This file contains a lot - if not most - of the functionality needed to calculate the indices on station text files. Namely, quality control functions, manual SPEI/SPI calculations and the creation of
# of .csv and plots files.

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
check.and.create.dates <- function(user.data) {
  yyymmdd <- paste(user.data[, 1], user.data[, 2], user.data[, 3], sep = "-")
  user.dates <- as.Date(yyymmdd, format = "%Y-%m-%d")

  year <- user.data$year[!is.na(user.dates)]
  month <- user.data$month[!is.na(user.dates)]
  day <- user.data$day[!is.na(user.dates)]
  prcp <- user.data$prcp[!is.na(user.dates)]
  tmax <- user.data$tmax[!is.na(user.dates)]
  tmin <- user.data$tmin[!is.na(user.dates)]

  user.data.ts <- data.frame(year = year, month = month, day = day, precp = prcp, tmax = tmax, tmin = tmin)
  user.data.ts$dates <- user.dates[!is.na(user.dates)]
  
  return(user.data.ts)
}

# Given a user's RClimdex text file path, read in, convert -99.9 to NA and
# return contents as array of 6 columns.
read_user_file <- function(user.file.path) {
  temp.filename = tempfile()
  sub <- tryCatch({      
    raw.table = readLines(user.file.path)
    newtext = gsub(",", "\t", raw.table)
    cat(newtext, file = temp.filename, sep = "\n")    
  },
  error = function(cond) {
    readUserFileError(paste("Error creating temporary file",cond$message), cond)
  })

  out <- tryCatch({
    data <- read.table(temp.filename, header = F, col.names = c("year", "month", "day", "prcp", "tmax", "tmin"), colClasses = rep("real", 6))
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


# This function houses the beginning screen for "Step 2" in the GUI (i.e. calculating the indices). It reads in user preferences for the indices
# and calls the index functions for calculation and plotting.
draw.step2.interface <- function(progress, plot.title, wsdi_ud, csdi_ud, rx_ud, txtn_ud, rnnmm_ud, Tb_HDD, Tb_CDD, Tb_GDD, custom_SPEI, var.choice, op.choice, constant.choice, outputFolders) {
# TODO remove globalvars
  # assign('plot.title', plot.title, envir = .GlobalEnv)

  # assign("wsdi_ud", as.double(wsdi_ud), envir = .GlobalEnv) # wsdi wsdi_ud
  # assign("csdi_ud", as.double(csdi_ud), envir = .GlobalEnv) #  csdi_ud
  # assign("rx_ud", as.double(rx_ud), envir = .GlobalEnv) # 14 rx_ud
  # assign("txtn_ud", as.double(txtn_ud), envir = .GlobalEnv) # txtn_ud
  # assign("rnnmm_ud", as.double(rnnmm_ud), envir = .GlobalEnv) # txtn_ud
  # assign("Tb_HDD", as.double(Tb_HDD), envir = .GlobalEnv) # Tb for HDDheat
  # assign("Tb_CDD", as.double(Tb_CDD), envir = .GlobalEnv) # Tb for HDDcold
  # assign("Tb_GDD", as.double(Tb_GDD), envir = .GlobalEnv) # Tb for HDDgrow
  # assign("custom_SPEI", as.double(custom_SPEI), envir = .GlobalEnv) # custom SPEI/SPI time period

  # assign("var.choice", var.choice, envir = .GlobalEnv)
  # assign("op.choice", op.choice, envir = .GlobalEnv)
  # assign("constant.choice", constant.choice, envir = .GlobalEnv)

  index.calc(progress, metadata, outputFolders)

  # TODO - refactor to use common zipFiles function that is currently in server.R
  # Create a zip file containing all of the results.
  curwd <- getwd()
  setwd(outputFolders$baseFolder)
  filesToZip <- dir(basename(outputFolders$outdirtmp), full.names = TRUE)
  zipfilename <- basename(outputFolders$outdirtmp)
  zip(zipfile = zipfilename, files = filesToZip)
  setwd(curwd)
}
# end of draw.step2.interface

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
    # source("server/climpact.master.installer.r")
    print("Continuing with ClimPACT execution...")
    print("******************************")
  }
}
