# write.index.csv
# takes a time series of a given index and writes to file
write.index.csv <- function(index = NULL, 
                            index.name = NULL, 
                            freq = "annual", 
                            header = "", 
                            metadata,
                            climdexInputParams,
                            outputFolders,
                            return_dates = FALSE) {
  if (is.null(index) | all(is.na(index))) { print(paste0("NO DATA FOR ", index.name, ". NOT WRITING .csv FILE."), quote = FALSE); return() }

  if (index.name == "tx95t") { freq = "DAY" }
  else {
    if (freq == "monthly") { freq = "MON" }
    else if (freq == "annual") { freq = "ANN" }
  }
  if (index.name == "wsdin") { tmp.name = paste("wsdi", climdexInputParams$wsdi_ud, sep = "") }
  else if (index.name == "csdid") { tmp.name = paste("csdi", climdexInputParams$csdi_ud, sep = "") }
  else if (index.name == "rxdday") { tmp.name = paste("rx", climdexInputParams$rx_ud, "day", sep = "") }
  else if (index.name == "rnnmm") { tmp.name = paste("r", climdexInputParams$rnnmm_ud, "mm", sep = "") }
  else if (index.name == "txdtnd") { tmp.name = paste("tx", climdexInputParams$txtn_ud, "tn", climdexInputParams$txtn_ud, sep = "") }
  else if (index.name == "txbdtnbd") { tmp.name = paste("txb", climdexInputParams$txtn_ud, "tnb", climdexInputParams$txtn_ud, sep = "") }
  else { tmp.name = index.name }

  nam1 <- paste(outputFolders$outinddir, paste(metadata$stationName, "_", tmp.name, "_", freq, ".csv", sep = ""), sep = "/")
  
  write_header(nam1, header, metadata)

  # column names are manually inserted into the columns (as the first element). This was to avoid some problem I've long forgotten.
  # Probably should look into something far more elegant.
  if (return_dates == FALSE) {
    index = c(tmp.name, index)
    names(index)[1] = "time"
    # calculate normalised values
    norm = array(NA, (length(index) - 1))
    avg = mean(as.numeric(index[2:length(index)]), na.rm = TRUE)
    stddev = sd(as.numeric(index[2:length(index)]), na.rm = TRUE)
    norm = (as.numeric(index[2:length(index)]) - avg) / stddev

    norm = c("standardised values (using all years)", norm)
    norm[norm == "NaN"] <- NA # "NaN" is returned, instead of NA, when there is no data in a month at all. Change these.
    index[index == "NaN"] <- NA
    new.index = cbind(names(index),index, norm)
  } else {
    index[index == "NaN"] <- NA
    index = rbind(NA,index)
    for (col in names(index)) { index[[col]][1] = col }
    new.index = cbind(rownames(index),index)
    new.index[,1][1] = "time"
  }

  write.table(new.index, file = nam1, append = TRUE, sep = ", ", na = "-99.9", col.names = FALSE, row.names = FALSE, quote = FALSE)
}

# write.hw.csv
# takes a time series of hw and writes to file
write.hw.csv <- function(index = NULL, cio=NULL, index.name = NULL, header = "", metadata, outputFolders) {
  if (is.null(index)) stop("Need heatwave data to write CSV file.")

  aspect.names <- list("magnitude", "amplitude", "number", "duration", "frequency")
  aspect.shortforms <- list("HWM","HWA","HWN","HWD","HWF")
  for (asp in 1:length(aspect.names)) {
	aspect_name = aspect.names[asp]
    aspect_short = aspect.shortforms[asp]
	nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_TX90",aspect_name,"_ANN.csv"))
	write_header(nam1, paste0("TX90 heatwave ",aspect_name, " (",aspect_short,")"), metadata)
	write.table(c("time",aspect_name), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
	write.table(cbind((metadata$date.years), index[['hw_indices']][1,asp,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
	  
	# write Tn90 heatwave data 
	nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_TN90",aspect_name,"_ANN.csv"))
	write_header(nam1, paste0("TN90 heatwave ",aspect_name, " (",aspect_short,")"), metadata)
	write.table(c("time",aspect_name), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
	write.table(cbind((metadata$date.years), index[['hw_indices']][2,asp,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  }
}

# write.hwEHF.csv
# takes a time series of hw data related to EHF strictly as per Nairn and Fawcett (2015), and writes to file
write.hwEHF.csv <- function(index = NULL, cio=NULL, index.name = NULL, header = "", metadata, outputFolders) {
	if (is.null(index)) stop("Need EHF heatwave data to write CSV files.")

	# write EHF HWPS data
	nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWPS_ANN.csv"))
	write_header(nam1, "Heatwave peak severity (HWPS): Mean of the maximum severity of each EHF heatwave.", metadata)
	write.table(list("time", "HWPS"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
	write.table(cbind((metadata$date.years), index[['hwps']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write EHF HWPI data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWPI_ANN.csv"))
    write_header(nam1, "Heatwave peak intensity (HWPI): Mean of the maximum intensity of each EHF heatwave.", metadata)
    write.table(list("time", "HWPI"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwpi']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

    # write EHF HWLS data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWLS_ANN.csv"))
    write_header(nam1, "Heatwave load severity (HWLS): Sum of daily EHF heatwave severities.", metadata)
    write.table(list("time", "HWLS"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwls']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

    # write EHF HWLI data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWLI_ANN.csv"))
    write_header(nam1, "Heatwave load intensity (HWLI): Sum of daily EHF heatwave intensities.", metadata)
    write.table(list("time", "HWLI"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwli']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write EHF HWD data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWD_ANN.csv"))
    write_header(nam1, "Heatwave duration (HWD): Duration of the longest EHF heatwave.", metadata)
    write.table(list("time", "HWD"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwd']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write EHF HWMD data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWMD_ANN.csv"))
    write_header(nam1, "Heatwave mean duration (HWMD): Mean EHF heatwave duration.", metadata)
    write.table(list("time", "HWMD"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwmd']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write EHF HWN data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWN_ANN.csv"))
    write_header(nam1, "Heatwave number (HWN): Number of EHF heatwaves.", metadata)
    write.table(list("time", "HWN"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwn']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write EHF HWF data
    nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHF-HWF_ANN.csv"))
    write_header(nam1, "Heatwave frequency (HWF): Number of days contributing to EHF heatwaves.", metadata)
    write.table(list("time", "HWF"), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
    write.table(cbind((metadata$date.years), index[['hwf']]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

	# write daily EHF values
	nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_EHFdaily.csv"))
	write_header(nam1, "EHF daily values. Note that 29th February is omitted from this calculation.", metadata)
	write.table(cbind(as.character(index$hw_dates), index$EHF_daily_values), file = nam1, append = TRUE, quote = FALSE, sep = ",", na = "-99.9", row.names = FALSE, col.names = c("date","Excess Heat Factor"))
	
	# write daily ECF values
	nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_ECFdaily.csv"))
	write_header(nam1, "ECF daily values. Note that 29th February is omitted from this calculation.", metadata)
	write.table(cbind(as.character(index$hw_dates), index$ECF_daily_values), file = nam1, append = TRUE, quote = FALSE, sep = ",", na = "-99.9", row.names = FALSE, col.names = c("date","Excess Cold Factor"))
}
