# ------------------------------------------------
# This wrapper script calls the 'create.indices.from.files' function from the modified climdex.pcic.ncdf package
# to calculate ETCCDI, ET-SCI and other indices, using data and parameters provided by the user.
# Note even when using a threshold file, the base.range parameter must still be specified accurately.
# ------------------------------------------------

library(climdex.pcic.ncdf)
# list of one to three input files. e.g. c("a.nc","b.nc","c.nc")
infiles=c("/media/sf_mars/side-projects/WMO/workshops/Cambodia_NOV_2019/Cambodia_CORDEX-CCSM4/pr_CORDEX-DAILY_CSIRO-CCAM-CCSM-4_historical_19500101_20051231_lon_92_118_lat_0_24.nc",
	"/media/sf_mars/side-projects/WMO/workshops/Cambodia_NOV_2019/Cambodia_CORDEX-CCSM4/tasmax_CORDEX-DAILY_CSIRO-CCAM-CCSM-4_historical_19500101_20051231_lon_92_118_lat_0_24.nc",
	"/media/sf_mars/side-projects/WMO/workshops/Cambodia_NOV_2019/Cambodia_CORDEX-CCSM4/tasmin_CORDEX-DAILY_CSIRO-CCAM-CCSM-4_historical_19500101_20051231_lon_92_118_lat_0_24.nc")
#"./www/sample_data/climpact.sampledata.gridded.1991-2010.nc"

# list of variable names according to above file(s)
vars=c(prec="pr",tmax="tasmax", tmin="tasmin")

# output directory. Will be created if it does not exist.
outdir="./www/output/Cambodia/"

# Output filename format. Must use CMIP5 filename convention. i.e. "var_timeresolution_model_scenario_run_starttime-endtime.nc"
file.template="var_daily_Cambodia_historical_NA_1991-2010.nc"

# author data
author.data=list(institution="My University", institution_id="MU")

# reference period
base.range=c(1981,2000)

# number of cores to use, or FALSE for single core.
cores=2

# list of indices to calculate, or NULL to calculate all.
indices="txx" #NULL	#c("hw","tnn")

# input threshold file to use, or NULL for none.
thresholds.files=NULL#"thresholds.test.1991-1997.nc"

# Directory where ClimPACT is stored. Use full pathname. Leave as NULL if you are running this script from the ClimPACT directory (where this script was initially stored).
root.dir=NULL


#######################################################
# Esoterics below, do not modify without a good reason.

# definition used for Excess Heat Factor (EHF). "PA13" for Perkins and Alexander (2013), this is the default. "NF13" for Nairn and Fawcett (2013).
EHF_DEF = "PA13"

# axis to split data on. For chunking up of grid, leave this.
axis.name="Y"

# Number of data values to process at once. If you receive "Error: rows.per.slice >= 1 is not TRUE", try increasing this to 20. You might have a large grid.
maxvals=10

# output compatible with FCLIMDEX. Leave this.
fclimdex.compatible=FALSE

# Call the package.
create.indices.from.files(infiles,outdir,file.template,author.data,variable.name.map=vars,base.range=base.range,parallel=cores,axis.to.split.on=axis.name,climdex.vars.subset=indices,thresholds.files=thresholds.files,fclimdex.compatible=fclimdex.compatible,#root.dir=root.dir,
	cluster.type="SOCK",ehfdef=EHF_DEF,max.vals.millions=maxvals,
	thresholds.name.map=c(tx05thresh="tx05thresh",tx10thresh="tx10thresh", tx50thresh="tx50thresh", tx90thresh="tx90thresh",tx95thresh="tx95thresh", 
			tn05thresh="tn05thresh",tn10thresh="tn10thresh",tn50thresh="tn50thresh",tn90thresh="tn90thresh",tn95thresh="tn95thresh",
			tx90thresh_15days="tx90thresh_15days",tn90thresh_15days="tn90thresh_15days",tavg90thresh_15days="tavg90thresh_15days",
			tavg05thresh="tavg05thresh",tavg95thresh="tavg95thresh",
			txraw="txraw",tnraw="tnraw",precraw="precraw", 
			r95thresh="r95thresh", r99thresh="r99thresh"))
