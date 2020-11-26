tmaxmin <- function(station, output, metadata) {
  filena = paste(output, '_tmaxmin.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  maxmin = subset(datos, (datos$tx - datos$tn) <= 0)
  date.tmp = paste(maxmin$year, maxmin$month, maxmin$day, sep = "-")
  write_header(filena, "Dates where TN>TX", metadata)
  write.table(cbind("Date", "Prec", "TX", "TN"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, maxmin$pc, maxmin$tx, maxmin$tn), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no data (i.e. no TN>TX) in variable print message
  if (length(maxmin) == 0) { write.table("NO TN > TX FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(datos)
}
