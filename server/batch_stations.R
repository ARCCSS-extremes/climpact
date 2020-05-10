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

# return a nice list of station metadata
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
batch <- function(progress, metadata_filepath, batchfiles, base.start, base.end, batchOutputFolder) {

  batch_metadata <- read.file.list.metadata(metadata_filepath)

  if (!is.null(progress)) {
    # 0.5 below as we have two operations quality control and index calculations
    prog_int <- 0.5 / length(batch_metadata$station_file) 
  }
  # progressSNOW <- function(n) {
  #   if (interactive()) {
  #     progress$inc(prog_int)
  #   }
  # }
  # opts <- list(progress = progressSNOW)
  # registerDoSNOW(cl) # needs cl variable (cluster intialised via cl <- makeCluster(numCores))

  # batchfiles %>% tidyverse::remove_rownames %>% tidyverse::column_torownames(var=1)
  # batchfiles <- data.frame(batchfiles[,-1], row.names=batchfiles[,1])
  # set each row name in batch file to station name for indexing
  row.names(batchfiles) <- batchfiles$name
  batchfiles[1] <- NULL
  numfiles <- length(batch_metadata$station_file)
  for (file.number in 1:numfiles) {
    msg <- paste("File", file.number, "of", numfiles, ":", batch_metadata$station_file[file.number])
    print(msg)
    if (!is.null(progress)) progress$inc(detail = msg)
    #fileName = batch_metadata$station_file[file.number]
    file <- batchfiles[file.number, "datapath"]
    batchResult <- qc_and_calculateIndices(progress, prog_int, batch_metadata, file.number, file, base.start, base.end, batchOutputFolder)
    if (batchResult$errors != "") {
      # we had an error with this file
      
    }
    # progress incremented in calculations if (!is.null(progress)) progress$inc(prog_int)
  }
  zipfilename <- zipFiles(batchOutputFolder, destinationFileName = paste0(basename(batchOutputFolder), ".zip"))
  return(zipfilename)
}

qc_and_calculateIndices <- function(progress, prog_int, batch_metadata, file.number, file, base.start, base.end, baseFolder) {
  fileName <- batch_metadata$station_file[file.number]
  cat(file = stderr(), "qc_and_calculateIndices(), working on :", fileName, "\n")
  print(fileName)
  print(file)
  lat <- as.numeric(batch_metadata$latitude[file.number])
  lon <- as.numeric(batch_metadata$longitude[file.number])
  stationName <- strip_file_extension(fileName)
  outputFolders <- outputFolders(baseFolder, stationName)

  qcResult <- load_data_qc(progress, prog_int, file, lat, lon, stationName, base.start, base.end, outputFolders)
  # qcResult now has $errors, $cio, $metadata
  if (qcResult$errors != "") {
    print(qcResult$errors)
    return(qcResult)
  }
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

  skip <- FALSE

  errorFilePath <- file.path(outputFolders$outputdir, paste0(stationName, ".error.txt"))
  if (file_test("-f", errorFilePath)) {
    file.remove(errorFilePath)
  }

  # calculate indices
  catchCalc <- tryCatch(index.calc(progress, prog_int, qcResult$metadata, qcResult$cio, outputFolders, params),
                        error = function(cond) {
                          fileConn <- file(errorFilePath)
                          writeLines(toString(cond$message), fileConn)
                          close(fileConn)
                          if (file_test("-f", paste0(file, ".temporary"))) {
                            file.remove(paste0(file, ".temporary"))
                          }
                        })

  if (skip) { return(NA) }

  # RJHD - NH addition for pdf error 2-aug-17
  graphics.off()
  print(paste(file, " done", sep = ""))
}
