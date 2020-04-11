# Plots histograms showing rounding. Needs station and you can delimit the period with first and last year
roundcheck <- function(station, output, fyear = 1000, lyear = 3000, save = 0) {
  if (save == 1) {
    nombre <- paste(output, '_rounding.pdf', sep = "")
    check_open(nombre)
    pdf(file = nombre)
  }
  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = '-99.9')
  par(mfrow = c(1, 3))
  my <- subset(datos, datos$year >= fyear & datos$year <= lyear)
  ispc = subset(my$pc, my$pc > 0)
  hist(ispc %% 1, col = 'blue', main = 'NON ZERO PREC ROUNDING', breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")
  hist(my$tx %% 1, col = 'red', main = 'TX ROUNDING', breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")
  hist(my$tn %% 1, col = 'cyan', main = 'TN ROUNDING', breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")

  if (save == 1) { dev.off() }
  rm(datos)
}
