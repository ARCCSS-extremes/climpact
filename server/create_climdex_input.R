#' Prepare data and create the climdex.input object using the R package climdex.pcic
#' 
#' @param merge_data  data.frame
#' @param metadata    list()    
create_climdex_input <- function(merge_data, metadata) {
  days <- as.Date(as.character(merge_data[, 1], format = "%Y-%m-%d")) - as.Date("1850-01-01")
  seconds <- as.numeric(days * 24 * 60 * 60)
  ts.origin = "1850-01-01" # arbitarily chosen origin to create time-series object with. This needs to be made global
  pcict.dates <- as.PCICt(seconds, cal = "gregorian", origin = as.character(ts.origin))

  # create a climdex input object
  # The only quantiles object is the global var. Which is never assigned a value, so will be NULL.
  cio <- climdexInput.raw(tmin = merge_data[, 4], tmax = merge_data[, 3], prec = merge_data[, 2], 
                          tmin.dates = pcict.dates, tmax.dates = pcict.dates, prec.dates = pcict.dates, 
                          base.range = c(metadata$base.start, metadata$base.end), prec.qtiles = prec.quantiles,
                          temp.qtiles = temp.quantiles, quantiles = NULL)

  # add diurnal temperature range
  cio@data$dtr = cio@data$tmax - cio@data$tmin  
  return(cio)
}
