jumps_tn <- function(station, output, metadata) {
  filena = paste(output, '_tn_jumps.csv', sep = '')
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  diftn <- abs(round(diff(datos$tn, lag = 1, differences = 1), digits = 1))
  x <- data.frame(c.ndx = cumsum(rle(diftn)$lengths), c.type = rle(diftn)$values)
  x <- na.omit(x)
  names(x) <- c("id", "val")
  z <- data.frame(id = row(datos), year = datos$year, month = datos$month, day = datos$day, day = datos$tn)
  Z <- z[, 6:10]
  names(z) <- c("id", "year", "month", "day", "tn")
  jumps <- merge(z, x, by = "id", all.x = F, all.y = T)
  jumps <- subset(jumps, (jumps$val >= 20))
  jumps <- jumps[, 7:10]
  names(jumps) = c("year", "month", "day", "tn")
  date.tmp = paste(jumps$year, jumps$month, jumps$day, sep = "-")
  write_header(filena, "Dates where the change in TN is > 20 degrees.", metadata)
  write.table(cbind("Date", "TN"), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)
  write.table(cbind(date.tmp, jumps$tn), sep = ",", append = TRUE, file = filena, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # If no issues found in variable, print message
  if (length(jumps$tn) == 0) { write.table("NO LARGE TN JUMPS FOUND", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE) }

  rm(datos) # we don't want to delete everyting...
}