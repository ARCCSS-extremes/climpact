

#				ClimPACT
			Last updated: November 2017


##  What is it?
  
ClimPACT is an R software package that calculates the [ET-SCI](http://www.wmo.int/pages/prog/wcp/ccl/opace/opace4/ET-SCI-4-1.php) indices. It can read 
data from text or netCDF files. It directly incorporates the R packages climdex.pcic 
and climdex.pcic.ncdf developed by the Pacific Climate Impacts Consortium (PCIC). It
runs on Windows, Linux and MacOS.
  
  
##  Where can I get it?
  
ClimPACT is available on github @ https://github.com/ARCCSS-extremes/climpact


How to install ClimPACT?

Software requirements:
    -R (version 3.3 or later or later). You will need administrator privileges 
     on your computer or the ability to install R packages.
    -Linux users require the PROJ4 development files (libproj-dev package on 
     Ubuntu) and the udunits development files (libudunits2-dev package 
     on Ubuntu).

1. Download and extract [this file](https://github.com/ARCCSS-extremes/climpact/archive/master.zip) to your computer.
   This will create a directory named "climpact-master".

2. Install the required R-packages.

   In Windows: open R and select "File->Change dir..." and select the
   climpact-master directory created in step 1. Then type
   *source('server/climpact.master.installer.r')*

   In Linux/MacOS: cd to the climpact-master directory created in
   step 1, then open R in a terminal window and type
   *source('server/climpact.master.installer.r')*.

   This process can take several minutes.

Video tutorial on how to install R in Windows
-> 

Video tutorial on how to install ClimPACT in Windows
-> 


##  How do I start ClimPACT?

* In Windows: open R and select "File->Change dir..." and select the 
climpact-master directory created when installing ClimPACT. Then run the 
following two commands;
*library(shiny)*
*runApp()*

* In Linux/MacOS: cd to the climpact-master directory created in
step 1, then open R in a terminal window and run the following two
commands;
*library(shiny)*
*runApp()*

Follow the on-screen instructions.

Video tutorial on calculating indices from a station text file.
-> 


##  Advanced: Calculate indices on netCDF data via command line

Modify the climpact.ncdf.wrapper.r file to suit your needs (see manual
for optional parameters to specify). Then execute this file by running 
"Rscript climpact.ncdf.wrapper.r" from the Linux command line. Depending
on the size of your data and the number of cores selected, this process
can take anywhere from one to twelve hours.

>          Notes on netCDF data format:
>          * Look at the sample netCDF file for guidance in formatting your
>            data.
>          * Files must be CF compliant.
>          * There must be no 'bounds' attributes in your latitude or 
>            longitude variables.
>          * Your precipitation variable must have units of "kg m-2 d-1",
>            not "mm/day". These are numerically equivalent.
>          * Your minimum and maximum temperature variables must be 
>            uniquely named.
>          * ncrename, ncatted and ncks from the NCO toolset can help 
>            you modify your netCDF files.
>            http://nco.sourceforge.net/

				
#  Advanced: Calculate thresholds on netCDF data via command line

Modify the climpact.ncdf.thresholds.wrapper.r file to suit your needs (see manual
for optional parameters to specify). Then execute this file by running 
"Rscript climpact.ncdf.thresholds.wrapper.r" from the Linux command line. Depending
on the size of your data and the number of cores selected, this process
can take anywhere from one to a few hours, but is quicker than calculating 
the indices.

>          Notes on netCDF data format:
>          * Look at the sample netCDF file for guidance in formatting your
>            data.
>          * Files must be CF compliant.
>          * There must be no 'bounds' attributes in your latitude or 
>            longitude variables.
>          * Your precipitation variable must have units of "kg m-2 d-1",
>            not "mm/day". These are numerically equivalent.
>          * Your minimum and maximum temperature variables must be 
>            uniquely named.
>          * ncrename, ncatted and ncks from the NCO toolset can help 
>            you modify your netCDF files.
>            http://nco.sourceforge.net/

				
#  Advanced: batch process multiple station files via command line

From the terminal run the following command, replacing the flags
with the folder where your station text files are kept, a metadata file
containing the file name of each station text file along with relevant 
station information (see the sample file), the beginning and end years of 
the base period, and the number of cores to use in processing, respectively. 
See the user guide for more information.
*Rscript climpact.batch.stations.r ./sample_data/ ./sample_data/climpact.sample.batch.metadata.txt 1971 2000 2*


##  Common problems

* Running the GUI on MacOS. Users may need to install XQuartz, ensure
  to restart your computer after installing. https://www.xquartz.org/

* If you experience trouble installing R packages in Windows, try to disable
  your antivirus software temporarily.


##  Documentation
  
Documentation exists in the form of this README file, the official ClimPACT
user guide (available with this software) as well as the source code.


##  Contact
  
Software issues contact Nicholas Herold : nicholas.herold@unsw.edu.au
 
All other issues contact Lisa Alexander : l.alexander@unsw.edu.au
