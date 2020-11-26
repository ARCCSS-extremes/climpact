# ------------------------------------------------
# This script checks that the appropriate R packages are installed for running Climpact.
# November 2017
# ------------------------------------------------

 packages <- c("abind","bitops","Rcpp","caTools","PCICt","SPEI","climdex.pcic","ncdf4","snow","udunits2","functional","proj4","foreach","doParallel","doSNOW","zoo","zyp","tcltk2",
 			"shiny","shinythemes","markdown","servr","dplyr","corrplot","ggplot2","shinyjs",
			"shinydashboard","shinyBS","slickR","xml2","shinyWidgets","qpdf")

 # Print Unix-specific messages
 if(.Platform$OS.type == "unix") {
 	print("",quote=FALSE)
 	print("******************************",quote=FALSE)
 	print("",quote=FALSE)
 	cat("Calculating the Climpact indices on netCDF data requires that PROJ4 and UDUNITS2 be installed on your opreating system
 prior to running this script. If the following R packages fail to install ensure that these two packages are installed.\n\n")
 	readline(prompt="Press [enter] to continue")
 } 

 print("",quote=FALSE)
 print("Installing R packages.",quote=FALSE)
 print("******************************",quote=FALSE)
 for (package in 1:length(packages)) {
         if(packages[package] %in% installed.packages()[,"Package"]) { print(paste(packages[package],"... installed.",sep=""),quote=FALSE)
         } else { print(paste(packages[package],"... not installed. Installing...",sep=""),quote=FALSE)
         install.packages(packages[package]) }
 }
 if(!"ncdf4.helpers" %in% installed.packages()[,"Package"]) {
         print("ncdf4.helpers... not installed. Installing...",quote=FALSE)
         install.packages("./server/pcic_packages/ncdf4.helpers_0.3-3.tar.gz",repos=NULL,type="source")
 } else print("ncdf4.helpers... installed.",quote=FALSE)

 print("",quote=FALSE)

 cat("A modified version of climdex.pcic.ncdf needs to be installed. If a version is already installed it will be overwritten. 
 If you do not install this modified version you will not be able to calculate the indices on netCDF data (but will still
 be able to use the GUI).\n\n")
 readline(prompt="Press [enter] to continue")

 install.packages("./server/pcic_packages/climdex.pcic.ncdf.climpact.tar.gz",repos=NULL,type="source")

 print("",quote=FALSE)
 print("******************************",quote=FALSE)
 print(paste("R version ",as.character(getRversion())," detected.",sep=""),quote=FALSE)
 print("Checking complete.",quote=FALSE)
