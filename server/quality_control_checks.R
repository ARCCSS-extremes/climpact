# Preps data and creates the climdex.input object based on the R package climdex.pcic
create_climdex_input <- function(user.data, metadata) {
  date.seq <- data.frame(list(time = seq(metadata$dates[1], metadata$dates[length(metadata$dates)], by = "day")))
  data_raw = data.frame(list(time = as.Date(metadata$dates, format = "%Y-%m-%d"), prec = user.data[, 4], tmax = user.data[, 5], tmin = user.data[, 6]))
  merge_data = merge(data_raw, date.seq, all = TRUE)

  days <- as.Date(as.character(merge_data[, 1], format = "%Y-%m-%d")) - as.Date("1850-01-01")
  seconds <- as.numeric(days * 24 * 60 * 60)
  ts.origin = "1850-01-01" # arbitarily chosen origin to create time-series object with. This needs to be made global
  pcict.dates <- as.PCICt(seconds, cal = "gregorian", origin = as.character(ts.origin))

  # unused date.months <- unique(format(as.character((merge_data[, 1]), format = "%Y-%m")))
  metadata$date.years <- unique(format(as.character((merge_data[, 1]), format = "%Y")))

  # create a climdex input object
  # The only quantiles object is the global var. Which is never assigned a value, so will be NULL.
  cio <- climdexInput.raw(tmin = merge_data[, 4], tmax = merge_data[, 3], prec = merge_data[, 2], 
                          tmin.dates = pcict.dates, tmax.dates = pcict.dates, prec.dates = pcict.dates, 
                          base.range = c(metadata$base.start, metadata$base.end), prec.qtiles = prec.quantiles,
                          temp.qtiles = temp.quantiles, quantiles = NULL)

  # add diurnal temperature range
  cio@data$dtr = cio@data$tmax - cio@data$tmin

  return(cio)
}

# This function runs QC functionality on the user specified input data. It requres as input;
#    - metadata: output of create.metadata()
#    - data: output of convert.user.file
# Error checking on inputs has already been complete by the GUI.
QC.wrapper <- function(progress, metadata, user.data, user.file, outputFolders, quantiles) {

  if (!is.null(progress)) progress$inc(0.05, detail = "Checking dates...")

  # Check base period is valid when no thresholds loaded
  # JMC This is always NULL as quantiles is never set...
  if (is.null(quantiles)) {
    if (metadata$base.start < format(metadata$dates[1], format = "%Y") | metadata$base.end > format(metadata$dates[length(metadata$dates)], format = "%Y") | metadata$base.start > metadata$base.end) {
      return(paste("Base period must be between ", format(metadata$dates[1], format = "%Y"), " and ", format(metadata$dates[length(metadata$dates)], format = "%Y"), ". Please correct."))
    }
  } else {
    browser()  
    # just testing that this is never called
  }

  # Check there are no missing dates by constructing a time series based on the first and last date provided by user and see if its length
  # is longer than the length of the user's data.
  length.of.user.data = length(user.data$year)
  first.date = as.Date(paste(user.data$year[1], user.data$month[1], user.data$day[1], sep = "-"), "%Y-%m-%d")
  last.date = as.Date(paste(user.data$year[length.of.user.data], user.data$month[length.of.user.data], user.data$day[length.of.user.data], sep = "-"), "%Y-%m-%d")
  date.series = seq(first.date, last.date, "day")
  user.date.series = as.Date(paste(user.data$year, user.data$month, user.data$day, sep = "-"))
  missing.dates = date.series[!date.series %in% user.date.series]
  # Write out the missing.dates to a text file. Report the filename to the user.
  missingDatesFileName <- paste0(metadata$stationName, ".missing_dates.txt")
  missingDatesFilePath <- file.path(outputFolders$outqcdir, missingDatesFileName)

  if (file_test("-f", missingDatesFilePath)) { file.remove(missingDatesFilePath) }
  if (length(date.series[!date.series %in% user.date.series]) > 0) {
    write.table(date.series[!date.series %in% user.date.series], sep = ",", file = missingDatesFilePath, append = FALSE, row.names = FALSE, col.names = FALSE)
    error_msg = paste0("You seem to have missing dates. See <a href='output/", metadata$stationName, "/qc/", missingDatesFileName, "' target='_blank'> here </a> for a list of missing dates. Fill these with observations or missing values (-99.9) before continuing with quality control.")
    skip <<- TRUE

    warning(error_msg)
    return(error_msg)
  }

  # Check for ascending order of years
  if (!all(user.data$year == cummax(user.data$year))) {
    return("Years are not in ascending order, please check your input file.")
  }

  ##############################
  # Create climdex object
  # NICK: After this point all references to data should be made to the climdex input object 'cio'. One exception is the allqc function,
  # which still references the INPUT to the climdex.input function.
  if (!is.null(progress)) progress$inc(0.05, detail = "Creating climdex object...")

  cio <- create_climdex_input(user.data, metadata)
  print("climdex input object created.", quote = FALSE)

  ##############################
  if (!is.null(progress)) progress$inc(0.05, detail = "Calculating thresholds...")
  # Calculate and write out thresholds
  tavgqtiles <- get.outofbase.quantiles(cio@data$tavg, cio@data$tmin, tmax.dates = cio@dates, tmin.dates = cio@dates, base.range = c(metadata$base.start, metadata$base.end), temp.qtiles = temp.quantiles, prec.qtiles = NULL)
  cio@quantiles$tavg$outbase <- tavgqtiles$tmax$outbase # while this says tmax it is actually tavg, refer to above line.

  # heat wave thresholds
  tavg <- (cio@data$tmax + cio@data$tmin) / 2
  Tavg90p <- suppressWarnings(get.outofbase.quantiles(tavg, cio@data$tmin, tmax.dates = cio@dates, tmin.dates = cio@dates, base.range = c(metadata$base.start, metadata$base.end), n = 15, temp.qtiles = 0.9, prec.qtiles = NULL,
                                                                  min.base.data.fraction.present = 0.1))
  TxTn90p <- suppressWarnings(get.outofbase.quantiles(cio@data$tmax, cio@data$tmin, tmax.dates = cio@dates, tmin.dates = cio@dates, base.range = c(metadata$base.start, metadata$base.end), n = 15, temp.qtiles = 0.9, prec.qtiles = NULL,
                                                                  min.base.data.fraction.present = 0.1))
  tn90p <- TxTn90p$tmin$outbase
  tx90p <- TxTn90p$tmax$outbase
  tavg90p <- Tavg90p$tmax$outbase

  # write to file
  thres <- c(cio@quantiles$tmax$outbase, cio@quantiles$tmin$outbase, cio@quantiles$tavg$outbase, cio@quantiles$prec, as.list(tn90p), as.list(tx90p), as.list(tavg90p)) #,cio@dates,cio@data)#$tmin,cio@data$tmax,cio@data$prec)
  nam1 <- file.path(paste(outputFolders$outthresdir, paste0(outputFolders$stationName, "_thres.csv")))
  write.table(as.data.frame(thres), file = nam1, append = FALSE, quote = FALSE, sep = ", ", na = "NA", col.names = c(paste("tmax", names(cio@quantiles$tmax$outbase), sep = "_"), paste("tmin", names(cio@quantiles$tmin$outbase), sep = "_"),
  paste("tavg", names(cio@quantiles$tavg$outbase), sep = "_"), paste("prec", names(cio@quantiles$prec), sep = "_"), "HW_TN90", "HW_TX90", "HW_TAVG90"), row.names = FALSE)

  if (!is.null(progress)) progress$inc(0.05)

  # write raw tmin, tmax and prec data for future SPEI/SPI calcs
  yeardate2 <- format(cio@dates, format = "%Y")
  dates <- format(cio@dates, format = "%Y-%m-%d")
  base.dates <- dates[which(yeardate2 >= metadata$base.start & yeardate2 <= metadata$base.end)]
  thres2 <- list(dates = base.dates, tmin = cio@data$tmin[which(yeardate2 >= metadata$base.start & yeardate2 <= metadata$base.end)], tmax = cio@data$tmax[which(yeardate2 >= metadata$base.start & yeardate2 <= metadata$base.end)],
  prec = cio@data$prec[which(yeardate2 >= metadata$base.start & yeardate2 <= metadata$base.end)])
  nam2 <- file.path(outputFolders$outthresdir, paste0(outputFolders$stationName, "_thres_spei.csv"))
  write.table(as.data.frame(thres2), file = nam2, append = FALSE, quote = FALSE, sep = ", ", na = "NA", col.names = c("Base_period_dates", "Base_period_tmin", "Base_period_tmax", "Base_period_prec"), row.names = FALSE)

  ##############################
  # Set some text options
  if (metadata$lat < 0) lat_text = "°S" else lat_text = "°N"
  if (metadata$lon < 0) lon_text = "°W" else lon_text = "°E"
  Encoding(lon_text) <- "UTF-8" # to ensure proper plotting of degree symbol in Windows (which uses Latin encoding by default)
  Encoding(lat_text) <- "UTF-8"
  metadata$title.station <- paste0(metadata$stationName, " [", metadata$lat, lat_text, ", ", metadata$lon, lon_text, "]")
  
  ##############################
  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting precipitation...")
  nam1 <- file.path(outputFolders$outlogdir, paste0(outputFolders$stationName, "_prcpPLOT.pdf"))
  check_open(nam1)
  pdf(file = nam1)
  prcp <- cio@data$prec[cio@data$prec >= 1 & !is.na(cio@data$prec)]
  if (length(prcp) > 30) {
    hist(prcp, main = paste("Histogram for Station:", metadata$stationName, " of PRCP>=1mm", sep = ""), breaks = c(seq(0, 40, 2), max(prcp)), xlab = "", col = "green", freq = FALSE)
    lines(density(prcp, bw = 0.2, from = 1), col = "red")
  }
  pplotts(var = "prcp", tit = metadata$stationName, cio = cio, metadata = metadata)
  dev.off()

  ##############################
  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting tmax...")
  nam1 <- file.path(outputFolders$outlogdir, paste0(outputFolders$stationName, "_tmaxPLOT.pdf"))
  check_open(nam1)
  pdf(file = nam1)
  pplotts(var = "tmax", type = "l", tit = metadata$stationName, cio = cio, metadata = metadata)
  dev.off()

  ##############################
  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting tmin...")
  nam1 <- file.path(outputFolders$outlogdir, paste0(outputFolders$stationName, "_tminPLOT.pdf"))
  check_open(nam1)
  pdf(file = nam1)
  pplotts(var = "tmin", type = "l", tit = metadata$stationName, cio = cio, metadata = metadata)
  dev.off()

  ##############################
  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting dtr...")
  nam1 <- file.path(outputFolders$outlogdir, paste0(metadata$stationName, "_dtrPLOT.pdf"))
  check_open(nam1)
  pdf(file = nam1)
  pplotts(var = "dtr", type = "l", tit = metadata$stationName, cio = cio, metadata = metadata)
  dev.off()

  ##############################
  # Call the ExtraQC functions.
  print("TESTING DATA, PLEASE WAIT...", quote = FALSE)

  temp.file <- paste0(user.file, ".temporary") #"test.tmp"#tempfile()
  file.copy(user.file, temp.file)

  errors <- allqc(progress, master = temp.file, output = outputFolders$outqcdir, metadata = metadata, outrange = 3) #stddev.crit)

  ##############################
  # Write out NA statistics.
  write.NA.statistics(cio, outputFolders, metadata)

  ##############################
  # Remove temporary file
  file.remove(temp.file)

  qcWrapperResult <- list(errors = errors, cio = cio)
  return(qcWrapperResult)

}
# end of QC.wrapper()

read_and_qc_check <- function(progress, user.data, user.file, latitude, longitude, stationName, base.year.start, base.year.end, outputFolders) {
  if (!is.null(progress)) progress$inc(0.05, detail = "Checking dates...")
  user.data.ts <- check.and.create.dates(user.data)
  metadata <- create.metadata(latitude, longitude, base.year.start, base.year.end, user.data.ts$dates, stationName)
  qcResult <- QC.wrapper(progress, metadata, user.data.ts, user.file, outputFolders, NULL)
  return(qcResult)
}

# creates a list of metadata
create.metadata <- function(latitude, longitude, base.year.start, base.year.end, dates, stationName, date.years = NULL, title.station = NULL) {
  return(list(lat = latitude, lon = longitude, base.start = base.year.start, base.end = base.year.end, year.start = as.numeric(format(dates[1], format = "%Y")), year.end = as.numeric(format(dates[length(dates)], format = "%Y")), dates = dates, stationName = stationName, date.years = date.years, title.station = title.station))
}
