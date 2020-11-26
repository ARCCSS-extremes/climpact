jumps_tx <- function(station, output, metadata) {
  filena = paste(output, '_tx_jumps.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  diftx <- abs(round(diff(datos$tx, lag = 1, differences = 1), digits = 1))
  x <- data.frame(c.ndx = cumsum(rle(diftx)$lengths), c.type = rle(diftx)$values)
  x <- na.omit(x)
  names(x) <- c("id", "val")
  z <- data.frame(id = row(datos), year = datos$year, month = datos$month, day = datos$day, day = datos$tx)
  Z <- z[, 6:10]
  names(z) <- c("id", "year", "month", "day", "tx")
  jumps <- merge(z, x, by = "id", all.x = F, all.y = T)
  jumps <- subset(jumps, (jumps$val >= 20))
  jumps <- jumps[, 7:11]
  jumps <- jumps[, -4]
  names(jumps) = c("year", "month", "day", "tx")
  date.tmp = paste(jumps$year, jumps$month, jumps$day, sep = "-")
  write_header(filena, "Dates where the change in TX is > 20 degrees.", metadata)
  write.table(cbind("Date", "TX"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, jumps$tx), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no issues found in variable, print message
  if (length(jumps$tx) == 0) { write.table("NO LARGE TX JUMPS FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(datos) # we don't want to delete everyting...
}
