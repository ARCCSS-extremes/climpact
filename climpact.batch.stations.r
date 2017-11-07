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
source("server/climpact.GUI-functions.r")
source("server/climpact.etsci-functions.r")

# return a nice list of station metadata
read.file.list.metadata <- function(file.list.metadata) 
{
	file.list.metadata <- read.table(file.list.metadata,header=T,col.names=c("station","latitude","longitude","wsdin","csdin","Tb_HDD","Tb_CDD","Tb_GDD","rxnday","rnnmm","txtn","SPEI"),
					colClasses=c("character","real","real","integer","integer","real","real","integer","real","real","integer"))
	return(file.list.metadata) 
}

# call QC and index calculation functionality for each file specified in metadata.txt
batch <- function(input.directory,file.list.metadata,base.start,base.end) {
	batchMode <<- TRUE
	metadata <- read.file.list.metadata(file.list.metadata)
	
	if(exists("progress") && !is.null(progress)) { 
		prog_int <- 1/length(metadata$station) 
	}
	
	progressSNOW <- function(n) { 
		if(interactive()) { progress$inc(prog_int) }
	}
	opts <- list(progress = progressSNOW)
	registerDoSNOW(cl)
	
	try(foreach(file.number=1:length(metadata$station),.options.snow = opts) %dopar%
	{
		library(zoo)
		library(zyp)

		source("server/climpact.GUI-functions.r")
		source("server/climpact.etsci-functions.r")
		assign("base.year.start",base.start,envir=.GlobalEnv)
		assign("base.year.end",base.end,envir=.GlobalEnv)
	  
		file=paste(input.directory,"/",metadata$station[file.number],sep="")
		file.remove(paste(file,".error.txt",sep=""))
		print(file)
		
		user.data <- read.user.file(file)
		
		if(grepl("error",class(user.data),ignore.case=TRUE)) { 
		  print("Outer batch error caught") 
		  fileConn<-file(paste(file,".error.txt",sep="")) 
		  writeLines(user.data$message, fileConn) 
		  close(fileConn) 
		}

		user.data <- check.and.create.dates(user.data)
		get.file.path(file)
		create.dir(file)

		# define variables for indices
		lat <- as.numeric(metadata$latitude[file.number])
		lon <- as.numeric(metadata$longitude[file.number])
		wsdi_ud <<- metadata$wsdin[file.number]
		csdi_ud <<- metadata$csdin[file.number]
		Tb_HDD <<- metadata$Tb_HDD[file.number]
		Tb_CDD <<- metadata$Tb_CDD[file.number]
		Tb_GDD <<- metadata$Tb_GDD[file.number]
		rx_ud <<- metadata$rx_ud[file.number]
		rnnmm_ud <<- metadata$rnnmm_ud[file.number]
		txtn_ud <<- metadata$txtn_ud[file.number]
		custom_SPEI <<- metadata$SPEI[file.number]

		# global variables needed for calling climpact.GUI.r functionality
		station.metadata <- create.metadata(lat,lon,base.start,base.end,user.data$dates,"ofile_filler")
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

		# run quality control and create climdex input object
		catch1 <- tryCatch(QC.wrapper(NULL,station.metadata,user.data,file),
				error=function(msg) {
					fileConn<-file(paste(file,".error.txt",sep=""))
					writeLines(toString(msg), fileConn)
					close(fileConn)
					skip <<- TRUE
				})

		# calculate indices
		catch2 <- tryCatch(index.calc(NULL,station.metadata),
				error=function(msg) {
					fileConn<-file(paste(file,".error.txt",sep=""))
					writeLines(toString(msg), fileConn)
					close(fileConn)
					skip <<- TRUE
				})
		
		# close graphics devices. Good practice.
		graphics.off()
		
		if(exists("progress") && !is.null(progress)) { progress$inc(prog_int) }
	})

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
	print("",quote=FALSE)
	error.files <- suppressWarnings(list.files(path=input.directory,pattern="*error.txt"))		#system(paste("ls ",input.directory,"/*error.txt",sep=""),ignore.stderr=TRUE,intern=TRUE))
	if(length(error.files)==0) { print("... no errors detected in processing your files. That doesn't mean there aren't any!",quote=FALSE) } 
	else {
	  print("Errors were encountered during processing. These were recorded in *error.txt files created in your input directory. These files are listed below along with their error messages.",quote=FALSE)
		for (i in 1:length(error.files)) { #system(paste("ls ",input.directory,"*error.txt | wc -l",sep=""))) {
			print(error.files[i],quote=FALSE)
			cat(readLines(paste0(input.directory,.Platform$file.sep,error.files[i])), sep="\n")	#system(paste("cat ",error.files[i],sep=""))
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
