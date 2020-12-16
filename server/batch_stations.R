# ------------------------------------------------
# This file contains functionality to batch process station files stored in "RClimdex format" (i.e. 6 column format, see www/sample_data/sydney_observatory_hill_1936-2015.txt for an example)
# ------------------------------------------------
# load and source and specify cores
library(foreach)
library(doSNOW)
library(climdex.pcic)
library(doParallel)
library(zoo)
library(zyp)

source("models/errors.R")
source("models/outputFolders.R")
source("services/calculate_indices.R")

# return station metadata
read.file.list.metadata <- function(metadata_filepath) {
    metadataTable <- read.table(metadata_filepath,
    header = TRUE,
    col.names = c("station_file", "latitude", "longitude", "wsdin",   "csdin",   "Tb_HDD", "Tb_CDD", "Tb_GDD", "rxnday",  "rnnmm", "txtn", "SPEI"),
    colClasses = c("character",   "real",     "real",      "integer", "integer", "real",   "real",   "real",   "integer", "real",  "real", "integer"))
  return(metadataTable)
}

strip_file_extension <- function(fileName) {
  file_parts <- strsplit(fileName, "\\.")[[1]]
  stripped <- substr(fileName, start = 1, stop = nchar(fileName) - nchar(file_parts[length(file_parts)]) - 1)
  print(paste0("input: ", fileName, " output: ", stripped))
  return(stripped)
}

# call QC and index calculation functionality for each file specified in metadata.txt
processBatch <- function(progress, metadata_filepath, batchFiles, base.start, base.end, batchOutputFolder) {

  batch_metadata <- read.file.list.metadata(metadata_filepath)

  if (!is.null(progress)) {
    # 0.5 below as we have two operations quality control and index calculations
    prog_int <- 0.5 / length(batch_metadata$station_file)
  }

  # set each row name in batch file to station name for indexing
  row.names(batchFiles) <- batchFiles$name
  batchFiles[1] <- NULL
  numfiles <- length(batch_metadata$station_file)
  for (file.number in 1:numfiles) {
    # set error log file name remove if present from a past run of climpact
    errorfile <- file.path(batchOutputFolder,paste0(strip_file_extension(batch_metadata$station_file[file.number]),".error.txt"))

    if(file_test("-f",errorfile)) { file.remove(errorfile) }

    currentFileName <- batch_metadata$station_file[file.number]
    msg <- paste("File", file.number, "of", numfiles, ":", currentFileName)
    print(msg)

    if (!is.null(progress)) progress$inc(detail = msg)
    currentFilePath <- batchFiles[currentFileName, "datapath"]
    if (!is.na(currentFilePath)) {
      fileName <- batch_metadata$station_file[file.number]
      stationName <- strip_file_extension(fileName)
      outputFolders <- outputFolders(batchOutputFolder,stationName)
      qcResult <- suppressWarnings(checkStation(progress, prog_int, batch_metadata, file.number, currentFilePath, stationName, base.start, base.end, outputFolders))
      if (qcResult$errors == "") {
        # do index calculations
        calculateStationIndices(progress, prog_int, batch_metadata, file.number, currentFilePath, stationName, qcResult$metadata, qcResult$cio, outputFolders,errorfile)
      } else {
        # we had an error with this file
	fileConn<-file(errorfile)
	writeLines(toString(qcResult$errors), fileConn)
	close(fileConn)
      }
    }
  }
}

checkStation <- function(progress, prog_int, batch_metadata, file.number, currentFilePath, stationName, base.start, base.end, outputFolders) {
  # cat(file = stderr(), "qc_and_calculateIndices(), working on :", fileName, "\n")

  lat <- as.numeric(batch_metadata$latitude[file.number])
  lon <- as.numeric(batch_metadata$longitude[file.number])
  qcResult <- load_data_qc(progress, prog_int, currentFilePath, lat, lon, stationName, base.start, base.end, outputFolders)
  # qcResult now has $errors, $cio, $metadata

  graphics.off()
  return(qcResult)
}

calculateStationIndices <- function(progress, prog_int, batch_metadata, file.number, currentFilePath, stationName, station_metadata, station_cio, outputFolders,errorfile) {
  print(paste0("Calculating station indices for:", currentFilePath))
  params <- climdexInputParams(wsdi_ud      = batch_metadata$wsdin[file.number],
                                csdi_ud     = batch_metadata$csdin[file.number],
                                rx_ud       = batch_metadata$rxnday[file.number],
                                txtn_ud     = batch_metadata$txtn[file.number],
                                Tb_HDD      = batch_metadata$Tb_HDD[file.number],
                                Tb_CDD      = batch_metadata$Tb_CDD[file.number],
                                Tb_GDD      = batch_metadata$Tb_GDD[file.number],
                                rnnmm_ud    = batch_metadata$rnnmm[file.number],
                                custom_SPEI = batch_metadata$SPEI[file.number]
                              )

  # calculate indices
  catchCalc <- tryCatch(index.calc(progress, prog_int, station_metadata, station_cio, outputFolders, params),
                        error = function(cond) {
                          fileConn <- file(errorfile)
                          writeLines(toString(cond$message), fileConn)
                          close(fileConn)
                          if (file_test("-f", paste0(currentFilePath, ".temporary"))) {
                            file.remove(paste0(currentFilePath, ".temporary"))
                          }
                        },
                        finally = {
                          # RJHD - NH addition for pdf error 2-aug-17
                          graphics.off()
                          print(paste0(currentFilePath, " done"))
                        }
                       )
  return(list(errors = ""))
}
