
# This function calls the major routines involved in reading the user's file, creating the climdex object and running quality control
load_data_qc <- function(progress, user.file, latitude, longitude, stationName, base.year.start, base.year.end, outputFolders) {
	if (!is.null(progress)) progress$inc(0.05, detail = "Reading data file...") 
  user.data <- read_user_file(user.file)  
  qcResult <- read_and_qc_check(progress, user.data, user.file, latitude, longitude, stationName, base.year.start, base.year.end, outputFolders)
  return(qcResult)
}

# extraQC code, taken from the "rclimdex_extraqc.r" package,
# Quality Control procedures programed by Enric Aguilar (C3, URV, Tarragona, Spain) and
# and Marc Prohom, (Servei Meteorologic de Catalunya). Edited by nherold to output to .csv (Jan 2016).
allqc <- function(progress, master, output, metadata, outrange = 4) {
  output <- file.path(output, metadata$stationName)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting outliers...")
  # fourboxes will produce boxplots for non-zero precip, tx, tn, dtr using the IQR entered previously
  # the plot will go to series.name_boxes.pdf
  # outliers will be also listed on a file (series.name_outliers.txt)
  fourboxes(master, output, save = 1, outrange, metadata)

  if (!is.null(progress)) progress$inc(0.1, detail = "Plotting rounding problems...")
  # Will plot a histogram of the decimal point to see rounding problems, for prec, tx, tn
  # The plot will go to series.name_rounding.pdf. Needs some formal arrangements (title, nice axis, etc)
  roundcheck(master, output, save = 1)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting tmax <= tmin...")
  # will list when tmax <= tmin. Output goes to series.name_tmaxmin.txt
  tmaxmin(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting excessively large values...")
  # will list values exceeding 200 mm or temperatures with absolute values over 50. Output goes to
  # series.name_toolarge.txt
  humongous(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Plotting annual time series...")
  # 'Annual Time series' constructed with boxplots. Helps to identify years with very bad values
  # Output goes to series.name_boxseries.pdf
  boxseries(master, output, save = 1)

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding duplicate dates...")
  # Lists duplicate dates. Output goes to series.name_duplicates.txt
  duplivals(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding large jumps...")
  # The next two functions (by Marc Prohom, Servei Meteorologic de Catalunya) identify consecutive tx and tn values with differences larger than 20
  # Output goes to series.name_tx_jumps.txt and series.name_tn_jumps.txt. The first date is listed.
  jumps_tx(master, output, metadata)
  jumps_tn(master, output, metadata)

  if (!is.null(progress)) progress$inc(0.05, detail = "Finding repeated values...")
  # The next two functions (by Marc Prohom, Servei Meteorologic de Catalunya)
  # identify series of 3 or more consecutive identical values. The first date is listed.
  # Output goes to series.name_tx_flatline.txt  and series.name_tx_flatline.txt
  flatline_tx(master, output, metadata)
  flatline_tn(master, output, metadata)

  return("")
}
