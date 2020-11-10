# ------------------------------------------------
# This wrapper script calls the 'create.thresholds.from.file' function from the modified climdex.pcic.ncdf package
# to create thresholds, using data and parameters provided by the user.
# ------------------------------------------------

library(climdex.pcic.ncdf)
# list of one to three input files. e.g. c("a.nc","b.nc","c.nc")
input.files=c("./www/sample_data/climpact.sampledata.gridded.1991-2010.nc")

# list of variable names according to above file(s)
vars=c(tmax="tmax", tmin="tmin", prec="precip")

# output file name
output.file="./www/output/thresholds.1991-1997.nc"

# author data
author.data=list(institution="My University", institution_id="MU")

# reference period
base.range=c(1991,2010)

# number of cores to use (or FALSE)
cores=FALSE

# print messages?
verbose=TRUE

# Directory where Climpact is stored. Use full pathname. Leave as NULL if you are running this script from the Climpact directory (where this script was initially stored).
root.dir=NULL



######################################
# Do not modify without a good reason.

fclimdex.compatible=FALSE

create.thresholds.from.file(input.files,output.file,author.data,variable.name.map=vars,base.range=base.range,parallel=cores,verbose=verbose,fclimdex.compatible=fclimdex.compatible,root.dir=root.dir)
