boxseries <- function(station, output, save = 0) {
  if (save == 1) {
    nombre <- paste(output, "_boxseries.pdf", sep = "")
    check_open(nombre)
    pdf(file = nombre)
  }

  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = "-99.9")
  datos$tr <- datos$tx - datos$tn
  prec <- subset(datos, datos$pc > 0)
  par(mfrow = c(2, 2))

  if (any(!is.na(prec$pc))) respc <- boxplot(prec$pc ~ prec$year, main = "NON ZERO PREC", col = "blue", range = 4) else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }
  if (any(!is.na(datos$tx))) restx <- boxplot(datos$tx ~ datos$year, main = "TX", col = "red", range = 3) else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }
  if (any(!is.na(datos$tn))) restn <- boxplot(datos$tn ~ datos$year, main = "TN", col = "cyan", range = 3) else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }
  if (any(!is.na(datos$tr))) restr <- boxplot(datos$tr ~ datos$year, col = "yellow", main = "DTR", range = 3) else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  if (save == 1) dev.off()

  rm(datos) # we don't want to delete everyting...
}