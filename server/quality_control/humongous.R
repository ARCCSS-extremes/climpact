humongous <- function(station, output, metadata) {
  filena = paste(output, '_toolarge.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  grande <- subset(datos, (datos$tx > 50 | datos$tx < -50 | datos$tn > 50 | datos$tn < -50 | datos$pc > 200 | datos$pc < 0))
  date.tmp = paste(grande$year, grande$month, grande$day, sep = "-")
  write_header(filena, "Dates where precipitation > 200 mm or abs(temperature) > 50 degrees.", metadata)
  write.table(cbind("Date", "Prec", "TX", "TN"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, grande$pc, grande$tx, grande$tn), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no data (i.e. no large values) in variable print message
  if (length(grande) == 0) { write.table("NO EXCESSIVE VALUES FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(list = ls())
}