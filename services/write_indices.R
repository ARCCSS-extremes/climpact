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
    for (i in 2:length(index)) { norm[i - 1] = (as.numeric(index[i]) - avg) / stddev }
    norm = c("standardised values (using all years)", norm)
    norm[norm == "NaN"] <- NA # "NaN" is returned, instead of NA, when there is no data in a month at all. Change these.
    index[index == "NaN"] <- NA
    new.index = cbind(index, norm)
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

  # print each definition in a separate .csv. Thus each .csv will have columns of time, HWA, HWM, HWF, HWD, HWN.
  aspect.names <- list("time", "HWM", "HWA", "HWN", "HWD", "HWF")
  aspect.names.ECF <- list("time", "CWM", "CWA", "CWN", "CWD", "CWF")

  # write Tx90 heatwave data
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_tx90_heatwave_ANN.csv"))
  write_header(nam1, header, metadata)
  write.table(aspect.names, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind((metadata$date.years), aperm(index[['hw_indices']][1,,], c(2, 1))), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write Tn90 heatwave data
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_tn90_heatwave_ANN.csv"))
  write_header(nam1, header, metadata)
  write.table(aspect.names, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind((metadata$date.years), aperm(index[['hw_indices']][2,,], c(2, 1))), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write EHF heatwave data
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_ehf_heatwave_ANN.csv"))
  write_header(nam1, header, metadata)
  write.table(aspect.names, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind((metadata$date.years), aperm(index[['hw_indices']][3,,], c(2, 1))), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write ECF coldwave data
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_ecf_heatwave_ANN.csv"))
  write_header(nam1, header, metadata)
  write.table(aspect.names.ECF, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind((metadata$date.years), aperm(index[['hw_indices']][4,,], c(2, 1))), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write daily EHF values
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_ehf_daily_data.csv"))
  write_header(nam1, "EHF daily values. Note that 29th February is omitted from this calculation.", metadata)
  write.table(cbind(as.character(index[['hw_dates']]), index[["EHF_daily_values"]]), file = nam1, append = TRUE, quote = FALSE, sep = ",", na = "-99.9", row.names = FALSE, col.names = c("date","Excess Heat Factor"))

  # write daily ECF values
  nam1 <- file.path(outputFolders$outinddir, paste0(metadata$stationName, "_ecf_daily_data.csv"))
  write_header(nam1, "ECF daily values. Note that 29th February is omitted from this calculation.", metadata)
  write.table(cbind(as.character(index[['hw_dates']]), index[["ECF_daily_values"]]), file = nam1, append = TRUE, quote = FALSE, sep = ",", na = "-99.9", row.names = FALSE, col.names = c("date","Excess Cold Factor"))
}
