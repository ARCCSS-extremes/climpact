source("services/create_climdex_input.R", local = TRUE)

merge_data <- function(user_data, metadata) {
  date.seq <- data.frame(list(time = seq(metadata$dates[1], metadata$dates[length(metadata$dates)], by = "day")))
  data_raw = data.frame(list(time = as.Date(metadata$dates, format = "%Y-%m-%d"), prec = user_data[, 4], tmax = user_data[, 5], tmin = user_data[, 6]))
  return(merge(data_raw, date.seq, all = TRUE))
}

read_and_qc_check <- function(progress,
  user_data,
  user_file,
  latitude,
  longitude,
  stationName,
  base.year.start,
  base.year.end,
  outputFolders) {
  if (!is.null(progress)) progress$inc(0.05, detail = "Checking dates...")
  user_data_ts <- create_user_data_ts(user_data)
  metadata <- create_metadata(latitude, longitude, base.year.start, base.year.end, user_data_ts$dates, stationName)
  qcResult <- QC.wrapper(progress, metadata, user_data_ts, user_file, outputFolders, NULL)
  return(qcResult)
}

# This function runs QC functionality on the user specified input data. It requres as input;
#    - metadata: output of create_metadata()
#    - user_data: output of convert.user.file
# Error checking on inputs has already been complete by the GUI.
QC.wrapper <- function(progress, metadata, user_data, user_file, outputFolders, quantiles) {

  if (!is.null(progress)) progress$inc(0.05, detail = "Checking dates...")

  # Check base period is valid when no thresholds loaded
  # JMC This is always NULL as quantiles is never set...
  if (is.null(quantiles)) {
    if (metadata$base.start < format(metadata$dates[1], format = "%Y") | metadata$base.end > format(metadata$dates[length(metadata$dates)], format = "%Y") | metadata$base.start > metadata$base.end) {
      return(paste("Base period must be between ", format(metadata$dates[1], format = "%Y"), " and ", format(metadata$dates[length(metadata$dates)], format = "%Y"), ". Please correct."))
    }
  }

  # Check there are no missing dates by constructing a time series based on the first and last date provided by user and see if its length
  # is longer than the length of the user's data.
  user_data_length <- length(user_data$year)
  first.date <- as.Date(paste(user_data$year[1], user_data$month[1], user_data$day[1], sep = "-"), "%Y-%m-%d")
  last.date <- as.Date(paste(user_data$year[user_data_length], user_data$month[user_data_length], user_data$day[user_data_length], sep = "-"), "%Y-%m-%d")
  date.series <- seq(first.date, last.date, "day")
  user.date.series <- as.Date(paste(user_data$year, user_data$month, user_data$day, sep = "-"))
  missing.dates <- date.series[!date.series %in% user.date.series]
  # Write out the missing.dates to a text file. Report the filename to the user.
  missingDatesFileName <- paste0(metadata$stationName, ".missing_dates.txt")
  missingDatesFilePath <- file.path(outputFolders$outqcdir, missingDatesFileName)

  if (file_test("-f", missingDatesFilePath)) { file.remove(missingDatesFilePath) }
  if (length(date.series[!date.series %in% user.date.series]) > 0) {
    write.table(date.series[!date.series %in% user.date.series],
      sep = ",",
      file = missingDatesFilePath,
      append = FALSE,
      row.names = FALSE,
      col.names = FALSE)

    error_msg <- paste0("You seem to have missing dates. See <a href='output/",
      metadata$stationName,
      "/qc/",
      missingDatesFileName,
      "' target='_blank'> here </a> for a list of missing dates. ",
      "Fill these with observations or missing values (-99.9) before continuing with quality control.")

    skip <- TRUE
    warning(error_msg)
    return(error_msg)
  }

  # Check for ascending order of years
  if (!all(user_data$year == cummax(user_data$year))) {
    return("Years are not in ascending order, please check your input file.")
  }

  ##############################
  # Create climdex object
  # NICK: After this point all references to data should be made to the climdex input object 'cio'. One exception is the allqc function,
  # which still references the INPUT to the climdex.input function.
  if (!is.null(progress)) progress$inc(0.05, detail = "Creating climdex object...")

  merge_data <- merge_data(user_data, metadata)
  # unused date.months <- unique(format(as.character((merge_data[, 1]), format = "%Y-%m")))
  metadata$date.years <- unique(format(as.character((merge_data[, 1]), format = "%Y")))
  cio <- create_climdex_input(merge_data, metadata)
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
  if (metadata$lat < 0) {
    lat_text <- "°S"
  } else {
    lat_text <- "°N"
  }
  if (metadata$lon < 0) {
    lon_text <- "°W"
   } else {
     lon_text <- "°E"
   }
  Encoding(lon_text) <- "UTF-8" # to ensure proper plotting of degree symbol in Windows (which uses Latin encoding by default)
  Encoding(lat_text) <- "UTF-8"
  metadata$title.station <- paste0(metadata$stationName, " [", metadata$lat, lat_text, ", ", metadata$lon, lon_text, "]")

  createPlots(progress, outputFolders, metadata, "prcp", cio, "h")
  createPlots(progress, outputFolders, metadata, "tmax", cio, "l")
  createPlots(progress, outputFolders, metadata, "tmin", cio, "l")
  createPlots(progress, outputFolders, metadata, "dtr", cio, "l")

  ##############################
  # Call the ExtraQC functions.
  print("TESTING DATA, PLEASE WAIT...", quote = FALSE)

  temp.file <- paste0(user_file, ".temporary") #"test.tmp"#tempfile()
  file.copy(user_file, temp.file)

  errors <- allqc(progress, master = temp.file, output = outputFolders$outqcdir, metadata = metadata, outrange = 3) #stddev.crit)

  ##############################
  # Write out NA statistics.
  write.NA.statistics(cio, outputFolders, metadata)

  ##############################
  # Remove temporary file
  file.remove(temp.file)

  return(list(errors = errors, cio = cio, metadata = metadata))
}
# end of QC.wrapper()

createPlots <- function(progress, outputFolders, metadata, var, cio, type) {
  if (!is.null(progress)) progress$inc(0.05, detail = paste0("Plotting ", var, "..."))
  plotFileName <- file.path(outputFolders$outlogdir, paste0(metadata$stationName, "_", var, "PLOT"))
  plotToFile(plotFileName, "png", var = var, type = type, title = metadata$stationName, cio = cio, metadata = metadata)
  plotToFile(plotFileName, "pdf", var = var, type = type, title = metadata$stationName, cio = cio, metadata = metadata)
}

plotToFile <- function(plotFileName, mediaType, var, type, title, cio, metadata) {
  if (mediaType == "pdf") {
    plotFileName <- paste0(plotFileName, ".", mediaType)
    pdf(file = plotFileName)
  } else if (mediaType == "png") {
    # %d allows all pages to generate a separate file,
    # otherwise only last page is plotted in image.
    # needed here in QC, but not in calculations or correlations
    plotFileName <- paste0(plotFileName, "-%d.", mediaType)
    png(file = plotFileName, width = 800, height = 600)
  }

  # living with if statement to avoid a separate function just for prcp
  if (var == "prcp") {
    prcp <- cio@data$prec[cio@data$prec >= 1 & !is.na(cio@data$prec)]
    if (length(prcp) > 30) {
      hist(prcp,
        main = paste("Histogram for Station:", metadata$stationName, " of PRCP>=1mm", sep = ""),
        breaks = c(seq(0, 40, 2), max(prcp)),
        xlab = "",
        col = "green",
        freq = FALSE)
      lines(density(prcp, bw = 0.2, from = 1), col = "red")
    }
  }

  pplotts(var = var, type = type, tit = title, cio = cio, metadata = metadata)
  dev.off()
}

# creates a list of metadata
create_metadata <- function(latitude, longitude, base.year.start, base.year.end, dates, stationName) {
  if (latitude < 0) lat_text = "°S" else lat_text = "°N"
  if (longitude < 0) lon_text = "°W" else lon_text = "°E"
  Encoding(lon_text) <- "UTF-8" # to ensure proper plotting of degree symbol in Windows (which uses Latin encoding by default)
  Encoding(lat_text) <- "UTF-8"
  title.station <- paste0("Station: ", stationName, " [", latitude, lat_text, ", ", longitude, lon_text, "]")
  # date.years is set when creating climdex input object
  # no it's not, there are no reference behaviours here...
  # I need to add date.years to cio object returned from create_climdex_input function.

  # base.___ is the requested (start/end) year
  # year.___ is the actual (start/end) year in the data provided
  return(list(lat = latitude,
              lon = longitude,
              base.start = base.year.start,
              base.end = base.year.end,
              year.start = as.numeric(format(dates[1], format = "%Y")),
              year.end = as.numeric(format(dates[length(dates)], format = "%Y")),
              dates = dates,
              stationName = stationName,
              date.years = NULL,
              title.station = title.station
            ))
}

# This function calls the major routines involved in reading the user's file, creating the climdex object and running quality control
load_data_qc <- function(progress, user.file, latitude, longitude, stationName, base.year.start, base.year.end, outputFolders) {
  if (!is.null(progress)) progress$inc(0.05, detail = "Reading data file...")
  user.data <- read_user_file(user.file)
  qcResult <- read_and_qc_check(progress,
    user.data,
    user.file,
    latitude,
    longitude,
    stationName,
    base.year.start,
    base.year.end,
    outputFolders)
  return(qcResult)
}

# extraQC code, taken from the "rclimdex_extraqc.r" package,
# Quality Control procedures programed by Enric Aguilar (C3, URV, Tarragona, Spain) and
# and Marc Prohom, (Servei Meteorologic de Catalunya). Edited by nherold to output to .csv (Jan 2016).
allqc <- function(progress, master, output, metadata, outrange = 4) {
  output <- file.path(output, metadata$stationName)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting outliers...")
  # fourboxes will produce boxplots for non-zero precip, tx, tn, dtr using the IQR entered previously
  # the plot will go to series.name_boxes.pdf
  # outliers will be also listed on a file (series.name_outliers.txt)
  fourboxes(master, output, save = 1, outrange, metadata, "pdf")
  fourboxes(master, output, save = 1, outrange, metadata, "png")

  if (!is.null(progress)) progress$inc(0.1, detail = "Plotting rounding problems...")
  # Will plot a histogram of the decimal point to see rounding problems, for prec, tx, tn
  # The plot will go to series.name_rounding.pdf. Needs some formal arrangements (title, nice axis, etc)
  roundcheck(master, output, save = 1, "pdf")
  roundcheck(master, output, save = 1, "png")

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting tmax <= tmin...")
  # will list when tmax <= tmin. Output goes to series.name_tmaxmin.txt
  tmaxmin(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting excessively large values...")
  # will list values exceeding 200 mm or temperatures with absolute values over 50. Output goes to
  # series.name_toolarge.txt
  humongous(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting annual time series...")
  # 'Annual Time series' constructed with boxplots. Helps to identify years with very bad values
  # Output goes to series.name_boxseries.pdf
  boxseries(master, output, save = 1, "pdf")
  boxseries(master, output, save = 1, "png")

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding duplicate dates...")
  # Lists duplicate dates. Output goes to series.name_duplicates.txt
  duplivals(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding large jumps...")
  # The next two functions (by Marc Prohom, Servei Meteorologic de Catalunya) identify consecutive tx and tn values with differences larger than 20
  # Output goes to series.name_tx_jumps.txt and series.name_tn_jumps.txt. The first date is listed.
  jumps_tx(master, output, metadata)
  jumps_tn(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding repeated values...")
  # The next two functions (by Marc Prohom, Servei Meteorologic de Catalunya)
  # identify series of 3 or more consecutive identical values. The first date is listed.
  # Output goes to series.name_tx_flatline.txt  and series.name_tx_flatline.txt
  flatline_tx(master, output, metadata)
  flatline_tn(master, output, metadata)

  return("")
}
