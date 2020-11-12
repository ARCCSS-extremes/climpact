# ------------------------------------------------
# This file contains functionality to batch process station files stored in "RClimdex format" (i.e. 6 column format, see www/sample_data/sydney_observatory_hill_1936-2015.txt for an example)
# ------------------------------------------------
#
# CALLING THIS FILE:
#    Rscript climpact.batch.stations.r /full/path/to/station/files/ /full/path/to/metadata.txt base_period_begin base_period_end cores_to_use
#    e.g. Rscript climpact.batch.stations.r ./www/sample_data/Renovados_hasta_2010 ./www/sample_data/climpact.sample.batch.metadata.txt 1971 2000 2
#
# NOTE: This file expects that all of your individual station files are kept in /directory/path/to/station/files/ and that each file name (excluding the path directory) is found in
#       column one of metadata.txt, with corresponding metadata in subsequent columns.
#
# COMMAND LINE FLAGS:
#     - /full/path/to/station/files/ : directory path to where files listed in column one of metadata.txt are kept.
#     - /full/path/to/metadata.txt : text file containing 12 columns; station file, latitude, longitude, wsdin, csdin, Tb_HDD, Tb_CDD, Tb_GDD, rx_ud, rnnmm_ud, txtn_ud, SPEI
#     - base_period_begin : beginning year of base period
#     - base_period_end : end year of base period
#     - cores_to_use : number of cores to use in parallel

# load and source and specify cores
library(foreach)
library(doSNOW)
library(climdex.pcic)
library(doParallel)
library(zoo)
library(zyp)

source("models/climdexInputParams.R")
source("server/climpact.GUI-functions.r")
source("server/climpact.etsci-functions.r")
source("server/batch_stations.R")
source("services/quality_control_checks.R")

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
batch <- function(input.directory,file.list.metadata,base.start,base.end) {
	batchMode <<- TRUE
	version.climpact <<- software_id
	temp.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95)
	prec.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95, 0.99)
	barplot_flag <<- TRUE
	min_trend <<- 10

	metadata <- read.file.list.metadata(file.list.metadata)
	
	if(exists("progress") && !is.null(progress)) { 
		prog_int <- 0.5/length(metadata$station_file) 
	}
	
	progressSNOW <- function(n) { 
		if(interactive()) { progress$inc(prog_int) }
	}
	opts <- list(progress = progressSNOW)

	# create batchFiles data frame, with cols name, datapath
	inputContents <- list.files(input.directory, full.names = TRUE)
	batchFiles <- data.frame(name = basename(inputContents), datapath = inputContents, stringsAsFactors = FALSE)
	batchOutputFolder <- strip_file_extension(file.list.metadata)
	print(paste0("Processing batch, to output folder: ", batchOutputFolder))
	processBatch(opts$progress(), file.list.metadata, batchFiles, base.start, base.end, batchOutputFolder)

	print("",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("*********************************************************************************************",quote=FALSE)
	print("*********************************************************************************************",quote=FALSE)
	print("*********************************************************************************************",quote=FALSE)
	print("PROCESSING COMPLETE.",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("",quote=FALSE)
	print("Any log files to do with errors encountered during processing are listed below. Examine these files carefully and correct any errors.",quote=FALSE)
	print("",quote=FALSE)
#	error.files <- suppressWarnings(list.files(path=batchOutputFolder,pattern="*error.txt|*missing_dates*",recursive = TRUE,full.names=TRUE))
        error.files <- suppressWarnings(list.files(path=file.path("www","output"),pattern="*error.txt|*missing_dates*",recursive = TRUE,full.names=TRUE))
	if(length(error.files)==0) { print("... no errors detected in processing your files. That doesn't mean there aren't any!",quote=FALSE) } 
	else {
		for (i in 1:length(error.files)) { #system(paste("ls ",input.directory,"*error.txt | wc -l",sep=""))) {
			print(paste0(error.files[i]),quote=FALSE)
		} 
	}
}

# set up variables and call main function if this is from the command line
if(!interactive()) {
  # Enable reading of command line arguments
  args<-commandArgs(TRUE)
  
  # where one or more station files are kept
  input.directory = toString(args[1])
  
  # metadata text file
  file.list.metadata = toString(args[2])
  
  # begin base period
  base.start = as.numeric(args[3])
  
  # end base period
  base.end = as.numeric(args[4])
  
  # establish multiple cores
  registerDoParallel(cores=as.numeric(args[5]))
  
  batch(input.directory,file.list.metadata,base.start,base.end)
}
