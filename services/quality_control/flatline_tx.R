flatline_tx <- function(station, output, metadata) {
  filena = paste(output, '_tx_flatline.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  diftx <- abs(round(diff(datos$tx, lag = 1, differences = 1), digits = 1))
  x <- data.frame(c.ndx = cumsum(rle(diftx)$lengths), c.size = rle(diftx)$lengths, c.type = rle(diftx)$values)
  x <- x[x$c.type == 0,]
  x <- na.omit(x)
  names(x) <- c("id", "dup", "val")
  z <- data.frame(id = row(datos), year = datos$year, month = datos$month, day = datos$day, day = datos$tx)
  z_1 <- z[, 6:10]
  names(z_1) <- c("id", "year", "month", "day", "tx")
  flat <- merge(z_1, x, by = "id", all.x = F, all.y = T)
  flat <- subset(flat, (flat$dup >= 3))
  flat <- flat[, 2:6]

  date.tmp = paste(flat$year, flat$month, flat$day, sep = "-")
  write_header(filena, "Dates where TX values have been repeated more than 4 times.", metadata)
  write.table(cbind("Date", "TX", "Number of duplicates"), sep = ",", append = TRUE, file = filena, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, flat$tx, flat$dup + 1), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no issues found in variable, print message
  if (length(flat$tx) == 0) { write.table("NO REPEATED TX FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(datos) # we don't want to delete everyting...
}
