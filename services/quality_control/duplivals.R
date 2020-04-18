duplivals <- function(station, output, metadata) {
  filena = paste(output, '_duplicates.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  isdupli <- cbind(datos$year, datos$month, datos$day)
  duplicate.dates = subset(isdupli, duplicated(isdupli) == TRUE)
  date.tmp = paste(duplicate.dates[, 1], duplicate.dates[, 2], duplicate.dates[, 3], sep = "-")
  write_header(filena, "Dates that have been used more than once in your input file.", metadata)
  write.table(cbind("Dates_duplicated"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(date.tmp, sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no data (i.e. no large values) in variable print message
  if (length(date.tmp) == 0) { write.table("NO DUPLICATE DATES FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(datos) # we don't want to delete everyting...
}