# ------------------------------------------------
# Climpact
# University of New South Wales
# This package is available on github https://github.com/ARCCSS-extremes/climpact
# ------------------------------------------------
#
# This file constitutes the main user entry point into Climpact.
#
# BUGS
#   - Currently SPEI/SPI are calculated via the old Climpact code. This is because the CRAN package for SPEI/SPI does not
#     ostenisbly support large runs of NA values. When this occurs real numbers are included in the output where NA values
#     should occur.
#
# TECHNICAL NOTES
#   - See server/Climpact_developer_documentation.md for a technical document describing the major parts of this code. Refer
#     to this for insight when making changes such as adding indices.
#
# HISTORY
#   The Climpact code has evolved very heavily since it's original incarnation in the form of the single source file climpact.r.
#   The significant changes that have taken place include;
#   - the calculation of the indices is almost entirely taken care of by climdex.pcic (with several exceptions such as the
#     heatwave indices and SPEI/SPI).
#   - the user interface has been re-written with R Shiny
#   - the indices can now be calculated on netCDF files.
#
#   Several people contributed significantly to the development of the original Climpact software (which was originally derived
#   from RClimdex). For posterity and credit, below is a list of the key names and dates attributed to different changes.
#
#   Programmed by Yujun Ouyang,Mar,2004
#   rewritten by Yang Feng, July 2004
#   version 1.0, 2004-10-14
#   modified, 2006-01-24
#   modified, 2007-03-23
#   modified, 2007-11-26
#   modified, 2008-05-05
#   modified, 2008-05-06
#   modified, 2008-06-16
#   modified, 2012-05-30
#   Sandra add new indices
#   Hongang to check Sandra's code and add new indices - from 2012-11-05
#   modified 2013, James Goldie - overhaul of code
#   overhaul 2015-2017, Nicholas Herold and Nicholas Hannah (PCIC R package implementation, R Shiny interface, gridded indices, new indices).


# Load libraries
# Note, other libraries are sourced at different points in the program depending on what functions the user interacts with.
library(zoo)
library(zyp)
library(tcltk2)
library(parallel)
library(shinythemes)
library(shinyjs)
library(markdown)
library(servr)
library(dplyr)
library(corrplot)
library(ggplot2)
library(shinydashboard)
library(shinyBS)
library(slickR)
library(shinyWidgets)
library(qpdf)

# If Windows then use rbase file and directory chooser, if Unix use tcltk file and directory chooser. 
# Base functions do not provide a dialog box in Unix environments.
if (.Platform$OS.type == "windows") {
  fchoose <<- get("choose.files", mode = "function")
  dchoose <<- get("choose.dir", mode = "function")
} else if (.Platform$OS.type == "unix") {
  fchoose <<- get("tk_choose.files", mode = "function")
  dchoose <<- get("tk_choose.dir", mode = "function")
}

isLocal <<- FALSE
if (Sys.getenv("SHINY_PORT") == "") {
  isLocal <<- TRUE
}

# Source files
source("server/climpact.GUI-functions.r")
package.check()
source("server/climpact.etsci-functions.r")
source("server/sector_correlation.R")
source("models/errors.R")
source("models/climdexInputParams.R")
source("models/ncdfInputParams.R")
source("models/ncdfThresholdInputParams.R")
source("models/sectorInputParams.R")
source("models/weatherObservationsRequest.R")
source("models/weatherStation.R")
source("modules/singleStationStep1.R")
source("modules/singleStationStep1UI.R")
source("modules/singleStationStep2.R")
source("modules/singleStationStep2UI.R")
source("modules/singleStationStep3.R")
source("modules/singleStationStep3UI.R")
source("modules/singleStationStep4.R")
source("modules/singleStationStep4UI.R")
source("modules/batchStep1.R")
source("modules/batchStep1UI.R")
source("modules/griddedStep1.R")
source("modules/griddedStep1UI.R")
source("modules/griddedStep2.R")
source("modules/griddedStep2UI.R")
source("server/server.R")
source("services/zipFiles.R")
source("ui/uiSupport.R")
source("ui/ui.R")

# Global variables
version.climpact <<- software_id
temp.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95)
prec.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95, 0.99)
barplot_flag <<- TRUE
min_trend <<- 10

if (isLocal) {
    # When running locally, support NetCDF file uploads and gridded data calculations
  # Increase file upload limit to something extreme to account for large files.
  options(shiny.maxRequestSize = 1000000 * 1024 ^ 2)
  ncFilter <<- matrix(c("NetCDF", "*.nc"), 1, 2, byrow = TRUE)
}

shinyApp(ui, server)
