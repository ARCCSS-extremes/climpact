# Plots histograms showing rounding. Needs station and you can delimit the period with first and last year
roundcheck <- function(station, output, fyear = 1000, lyear = 3000, save = 0, mediaType = "pdf") {
  if (save == 1) {
    fileName <- paste0(output, "_rounding.", mediaType)
    if (mediaType == "pdf") {
      pdf(file = fileName)
    } else if (mediaType == "png") {
      png(file = fileName, width = 640, height = 640)
    }
  }

  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = "-99.9")
  par(mfrow = c(1, 3),mar=c(4,4,2,2.5), oma=c(2,2,2,2.5))
  my <- subset(datos, datos$year >= fyear & datos$year <= lyear)
  ispc <- subset(my$pc, my$pc > 0)
  hist(ispc %% 1, col = "blue", main = "NON ZERO PREC ROUNDING", breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")
  hist(my$tx %% 1, col = "red", main = "TX ROUNDING", breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")
  hist(my$tn %% 1, col = "cyan", main = "TN ROUNDING", breaks = c(seq(0, 1.0, 0.0999999)), xlab = "")

  mtext("Decimal value histograms", outer=TRUE, cex=1.5, line=-0.2)

  if (save == 1) { dev.off() }
  rm(datos)
}
