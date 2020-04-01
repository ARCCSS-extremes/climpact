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
source("custom_errors.r")

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
library(shinydashboard)
library(shinyBS)

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

jscode <- "
disableTab = function(name) {
  var tab = $('.nav li a[data-value=' + name + ']');
  tab.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  tab.addClass('disabled');
}

Shiny.addCustomMessageHandler('enableTab', function(name) {
    var tab = $('.nav li a[data-value=' + name + ']');
    tab.unbind('click.tab');
    tab.removeClass('disabled');
  }
);
"

ui <- tagList(
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="styles.css"),
      tags$script(HTML(jscode))
    ),
    useShinyjs(),
    #inlineCSS(css),
    dashboardPage(
      header = dashboardHeader(title = "ClimPACT"),
      sidebar = dashboardSidebar(
        sidebarMenu(
          menuItem("Home", tabName = "home", icon = icon("sun")),
          menuItem("Process single station", tabName = "single", icon = icon("table")),
          menuItem("Batch process stations", tabName = "batch", icon = icon("layer-group")),
          menuItemOutput("griddedMenuItem"),
          menuItem("Documentation", icon = icon("book"), href = "user_guide/ClimPACT_user_guide.htm")
        )
      ),
      body = dashboardBody(
        tabItems(
          tabItem(tabName = "home",
            source(file.path("ui", "landing_page.R"), local=TRUE)$value
          ),
          tabItem(tabName = "single",
            source(file.path("ui", "single_station.R"), local=TRUE)$value
          ),
          tabItem(tabName = "batch",
            source(file.path("ui", "batch_processing.R"), local = TRUE)$value
          ),
          tabItem(tabName = "gridded-indices",
            source(file.path("ui", "gridded_data_calculate.R"), local=TRUE)$value
          ),
          tabItem(tabName = "gridded-thresholds",
            source(file.path("ui", "gridded_data_thresholds.R"), local=TRUE)$value
          )
      )
    )
  ),
  tags$footer(
    div(id="footer-content",
      div(id="sitemap", 
        h4("Climpact 2.0.0"),
        p("Copyright © 2012–2020"),
        p("Climpact."),
        p("All Rights Reserved.")
      ),
      div(id="logos",
        HTML("<a href=\"https://www.unsw.edu.au\"><img src=\"assets/logo-unsw-small.png\" alt=\"UNSW Sydney\"></a>"),
        HTML("<a href=\"https://www.climateextremes.org.au/\"><img src=\"assets/logo-clex-small.png\" alt=\"ARC Centre of Excellence for Climate Extremes\"></a>"),
        HTML("<a href=\"https://public.wmo.int/\"><img src=\"assets/logo-wmo.png\" alt=\"World Meteorological Organization\"></a>"),
        HTML("<a href=\"https://www.greenclimate.fund\"><img src=\"assets/logo-gcf.png\" alt=\"Green Climate Fund\"></a>")
      )
    )
  ),
  # tags$script(HTML("disableTab('process_single_station_step_2')")),
  # tags$script(HTML("disableTab('process_single_station_step_3')")),
  # tags$script(HTML("disableTab('process_single_station_step_4')"))
)

shinyApp(ui, climpact.server)

