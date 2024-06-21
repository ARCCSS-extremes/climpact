humongous <- function(station, output, metadata, prec_threshold, temp_threshold) {
  filena = paste(output, '_toolarge.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  grande <- subset(datos, (datos$tx > temp_threshold | datos$tx < -1*temp_threshold | datos$tn > temp_threshold | datos$tn < -1*temp_threshold | datos$pc > prec_threshold | datos$pc < 0))
  date.tmp = paste(grande$year, grande$month, grande$day, sep = "-")
  write_header(filena, paste0("Dates where precipitation > ",prec_threshold," mm or abs(temperature) > ", temp_threshold," degrees."), metadata)
  write.table(cbind("Date", "Prec", "TX", "TN"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, grande$pc, grande$tx, grande$tn), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no data (i.e. no large values) in variable print message
  if (length(grande) == 0) { write.table("NO EXCESSIVE VALUES FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(list = ls())
}
