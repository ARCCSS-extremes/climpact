# Global variables
version.climpact <<- software_id
temp.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95)
prec.quantiles <<- c(0.05, 0.1, 0.5, 0.9, 0.95, 0.99)
barplot_flag <<- TRUE
min_trend <<- 10		# minimum number of valid data points required to calculate a trend
min_trend_proportion <<- 0.7	# minimum fraction of valid data points in a time series required to calculate a trend

# list of column names which contain actual index data. For indices that return dates of occurrence as well (as of climdex.pcic v1.2-0)
exact_date_indices <<- list(tnn="val", tnx="val", txn="val", txx="val", rxdday="val", rx1day="val", rx5day="val", cdd="duration", cwd="duration", gsl="sl")
