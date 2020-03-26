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

# return a nice list of station metadata
read.file.list.metadata <- function(file.list.metadata)
{
	file.list.metadata <- read.table(file.list.metadata,header=T,col.names=c("station_file","latitude","longitude","wsdin","csdin","Tb_HDD","Tb_CDD","Tb_GDD","rxnday","rnnmm","txtn","SPEI"),
					colClasses=c("character","real","real","integer","integer","real","real","integer","real","real","integer"))

	return(file.list.metadata)
}

strip.file.extension <- function(file.name)
{
	file_parts <- strsplit(file.name,"\\.")[[1]]
	stripped <- substr(file.name,start=1,stop=nchar(file.name)-nchar(file_parts[length(file_parts)])-1)
	print (paste0("input: ", file.name, " output: ", stripped))
	return(stripped)
}

# call QC and index calculation functionality for each file specified in metadata.txt
batch <<- function(metadatafilepath, metadatafilename,batchfiles,base.start,base.end) {

	metadata <- read.file.list.metadata(metadatafilepath)
	
	if(exists("progress") && !is.null(progress)) {
		prog_int <- 0.9/length(metadata$station_file)
	}
	progressSNOW <- function(n) {
		if(interactive()) { progress$inc(prog_int) }
	}
	opts <- list(progress = progressSNOW)
	registerDoSNOW(cl)

	# foreach does not support 'next'. This code is removed from the dopar loop in order to provide 'next' like functionality, in the form of return(NA) calls.
	func = function(file.number, batchfiles) {
		
		file.name = metadata$station_file[file.number]
		cat(file=stderr(), "in func, working on :", file.name, "\n")
		print(file.name)

		file <- batchfiles[file.name,'datapath']
		print(file)
		user.data <- read.user.file(file)
		user.data <- check.and.create.dates(user.data)

		station.name <- strip.file.extension(file.name)

		get.file.path(file, station.name)
		create.dir(file, outdirtmp)

		# define variables for indices
		lat <- as.numeric(metadata$latitude[file.number])
		lon <- as.numeric(metadata$longitude[file.number])
		wsdi_ud <<- metadata$wsdin[file.number]
		csdi_ud <<- metadata$csdin[file.number]
		Tb_HDD <<- metadata$Tb_HDD[file.number]
		Tb_CDD <<- metadata$Tb_CDD[file.number]
		Tb_GDD <<- metadata$Tb_GDD[file.number]
		rx_ud <<- metadata$rxnday[file.number]
		rnnmm_ud <<- metadata$rnnmm[file.number]
		txtn_ud <<- metadata$txtn[file.number]
		custom_SPEI <<- metadata$SPEI[file.number]

		# global variables needed for calling climpact2.GUI.r functionality
		station.metadata <- create.metadata(lat,lon,base.start,base.end,user.data$dates,"ofile_filler")
		assign("metadata",station.metadata,envir=.GlobalEnv)
		version.climpact <<- software_id
		quantiles <<- NULL
		if(lat<0) lat_text = "°S" else lat_text = "°N"
		if(lon<0) lon_text = "°W" else lon_text = "°E"
		Encoding(lon_text) <- "UTF-8"   # to ensure proper plotting of degree symbol in Windows (which uses Latin encoding by default)
		Encoding(lat_text) <- "UTF-8"
		title.station <- paste(ofilename, " [", lat,lat_text, ", ", lon,lon_text, "]", sep = "")
		assign("title.station", title.station, envir = .GlobalEnv)
		plot.title<-gsub('\\#',title.station,"Station: #"); assign('plot.title',plot.title,envir=.GlobalEnv)
		barplot_flag <<- TRUE
		min_trend <<- 10
		temp.quantiles <<- c(0.05,0.1,0.5,0.9,0.95)
		prec.quantiles <<- c(0.05,0.1,0.5,0.9,0.95,0.99)
		op.choice <<- NULL
		skip <<- FALSE

		if(file_test("-f",paste(file,".error.txt",sep=""))) { file.remove(paste(file,".error.txt",sep="")) }
		# run quality control and create climdex input object
		catch1 <- tryCatch(QC.wrapper(NULL,station.metadata,user.data,file),
				error=function(msg) {
					fileConn<-file(paste(file,".error.txt",sep=""))
					writeLines(toString(msg), fileConn)
					close(fileConn)
					if(file_test("-f",paste0(file,".temporary"))) { file.remove(paste0(file,".temporary")) }
				})
		if(skip) { return(NA) }

		# calculate indices
		catch2 <- tryCatch(index.calc(NULL,station.metadata),
				error=function(msg) {
					fileConn<-file(paste(file,".error.txt",sep=""))
					writeLines(toString(msg), fileConn)
					close(fileConn)
					if(file_test("-f",paste0(file,".temporary"))) { file.remove(paste0(file,".temporary")) }
				})
		if(skip) { return(NA) }

		# Create a zip file containing all of the results.
		# in format '{station_name}.zip'
		# curwd <- getwd()
		# setwd(paste(outdirtmp, '..', sep="/"))
		# files2zip <- dir(basename(outdirtmp), full.names = TRUE)
		# #files2zip <- dir(c(get.thresh.dir(),get.trends.dir(),get.plots.dir(),get.indices.dir()), full.names = TRUE)
		# zip(zipfile = basename(outdirtmp), files = files2zip)
		# setwd(curwd)

		# RJHD - NH addition for pdf error 2-aug-17
		graphics.off()
		print(paste(file," done",sep=""))
	}


	# batchfiles %>% tidyverse::remove_rownames %>% tidyverse::column_torownames(var=1)
	# batchfiles <- data.frame(batchfiles[,-1], row.names=batchfiles[,1])
	# set each row name in batch file to station name for indexing
	row.names(batchfiles) <- batchfiles$name
	batchfiles[1] <- NULL

	assign('outputFolder',dirname(batchfiles[1,'datapath']),envir=.GlobalEnv)
	cat(file=stderr(), "outputFolder global:", outputFolder, "\n")

	numfiles <- length(metadata$station_file)
	for (file.number in 1:numfiles)
	{
		msg <- paste("File", file.number, "of", numfiles, ":", metadata$station_file[file.number])
	  	print(msg)
		progress$inc(detail = msg)
		func(file.number, batchfiles)

	  if(!is.null(progress)) progress$inc(prog_int)
	}


    file.rename(batchfiles$datapath, row.names(batchfiles))
	zipfilename <-paste0(strip.file.extension(metadatafilename),"-results.zip")	
	workingDir <- outputFolder #JMC variable assignment unnecessary here if method below not extracted
	destinationFolder <- "/www/output/"
	# JMC extract method to create zip file at path
    curwd <- getwd()
    setwd(workingDir)
    files2zip <- dir(workingDir)
    zip(zipfile = zipfilename, files = files2zip)
	outputzipfilepath <- paste0(curwd,destinationFolder, zipfilename)
	file.copy(zipfilename, outputzipfilepath)
    setwd(curwd)

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
	print("Any errors encountered during processing are listed below by input file. Assess these files carefully and correct any errors.",quote=FALSE)
	print("",quote=FALSE)
	error.files <- suppressWarnings(list.files(path=outputFolder,pattern=paste("*error.txt",sep="")))
	if(length(error.files)==0) { 
		print("... no errors detected in processing your files. That doesn't mean there aren't any!",quote=FALSE) 
	}
	else {
		for (i in 1:length(error.files)) { #system(paste("ls ",input.directory,"*error.txt | wc -l",sep=""))) {
			print(error.files[i],quote=FALSE)
			#system(paste("cat ",input.directory,"/",error.files[i],sep=""))
		}
	}
	#return (paste0(outputFolder,.Platform$file.sep,zipfilename))

	return(paste0("output/", zipfilename))
}

# JMC - following non-interactive code runs on shinyapps.io and breaks app
# set up variables and call main function if this is from the command line
# if(!interactive()) {
#   # Enable reading of command line arguments
#   args<-commandArgs(TRUE)

#   # where one or more station files are kept
#   input.directory = toString(args[1])

#   # metadata text file
#   file.list.metadata = toString(args[2])

#   # begin base period
#   base.start = as.numeric(args[3])

#   # end base period
#   base.end = as.numeric(args[4])

#   # establish multiple cores
#   registerDoParallel(cores=as.numeric(args[5]))

#   batch(input.directory,file.list.metadata,base.start,base.end)
# }
