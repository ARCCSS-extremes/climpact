# ------------------------------------------------
# ClimPACT
# University of New South Wales
# This package is available on github https://github.com/ARCCSS-extremes/climpact2.
# ------------------------------------------------
#    
# This file constitutes the main user entry point into ClimPACT. 
#
# BUGS
#   - Currently SPEI/SPI are calculated via the old ClimPACT code. This is because the CRAN package for SPEI/SPI does not
#     ostenisbly support large runs of NA values. When this occurs real numbers are included in the output where NA values
#     should occur.
#
# TECHNICAL NOTES
#   - See server/ClimPACT_developer_documentation.md for a technical document describing the major parts of this code. Refer 
#	  to this for insight when making changes such as adding indices.
#
# HISTORY
#   The ClimPACT code has evolved very heavily since it's original incarnation in the form of the single source file climpact.r.
#   The significant changes that have taken place include;
#   - the calculation of the indices is almost entirely taken care of by climdex.pcic (with several exceptions such as the 
#     heatwave indices and SPEI/SPI).
#   - the user interface has been re-written with R Shiny
#   - the indices can now be calculated on netCDF files.
#
#   Several people contributed significantly to the development of the original ClimPACT software (which was originally derived
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

# Source files and load libraries. Note, other libraries are sourced at different points in the program depending on what functions the user interacts with.
source("server/climpact.GUI-functions.r")
source("server/server.R")
source("server/sector_correlation.R")
source("server/climpact.etsci-functions.r")
package.check()

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

# If Windows then use rbase file and directory chooser, if Unix use tcltk file and directory chooser. Base functions do not provide a dialog box in Unix environments.
if(.Platform$OS.type == "windows") {
  fchoose <<- get("choose.files", mode="function")
  dchoose <<- get("choose.dir", mode="function")
} else if(.Platform$OS.type == "unix") {
  fchoose <<- get("tk_choose.files", mode="function")
  dchoose <<- get("tk_choose.dir", mode="function")
}

ncFilter <<- matrix(c("NetCDF", "*.nc"),1, 2, byrow = TRUE)
gridNcFiles <<- gridOutDir <<- gridNcFilesThresh <<- gridOutDirThresh <<- batchOutDir <<- NULL

ui <- tagList(
    useShinyjs(),
    navbarPage(title=paste0("v.",software_id),id="mainNavbar", theme = shinytheme("cerulean"),selected="frontPage",
      source(file.path("ui", "front_page_tab.R"), local=TRUE)$value,
      source(file.path("ui", "load_and_check.R"), local=TRUE)$value,
      source(file.path("ui", "calculate_indices.R"),local=TRUE)$value,
      source(file.path("ui", "sector_data_correlation.R"),local=TRUE)$value,
      navbarMenu("EXPERIMENTAL",
            source(file.path("ui", "gridded_data_calculate.R"), local=TRUE)$value,
            source(file.path("ui", "gridded_data_thresholds.R"),local=TRUE)$value,
            source(file.path("ui", "batch_processing.R"), local = TRUE)$value,
            menuName="advmenu")
  #    source(file.path("ui", "close_tab.R"), local=TRUE)$value
  )
)

shinyApp(ui, climpact.server)
