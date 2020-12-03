# pplotts
# plots QC'ed data (TX, TN, PR) into pdf files.
pplotts <- function(var = "prcp", type = "h", tit = NULL, cio, metadata) {
  # set bounds for the plot based on available data. dtr and prcp have
  # floors of 0 by definition (assuming tmax and tmin have been qc'd)

  if (var == "dtr") {
    #  ymax <- max(data[, "tmax"] - data[, "tmin"], na.rm = TRUE)
    ymax <- max(cio@data$dtr, na.rm = TRUE)
    ymin <- 0
  } else if (var == "prcp") {
    ymax <- max(cio@data$prec, na.rm = TRUE)
    ymin <- 0
  } else {
    ymax <- max(cio@data[[var]], na.rm = TRUE) + 1
    ymin <- min(cio@data[[var]], na.rm = TRUE) - 1
  }
  if (var == "prcp") { var1 = "prec" } else { var1 = var }

  # set default y scales if proper ones can't be calculated
  # but do we really want to try to plot if there's no data available at all?
  if (is.na(ymax) | is.na(ymin) | (ymax == -Inf) | (ymin == -Inf)) {
    ymax <- 100
    ymin <- -100
    warning(paste("Warnings have been generated because there is no available data for one or more of tmax, tmin or precip. Check the plots in the /qc folder to confirm this."))
  }

  par(mfrow = c(4, 1))
  par(mar = c(3.1, 2.1, 3.1, 2.1),oma=c(2,2,2,2.5)) #c(3.1, 2.1, 2.1, 2.1))

  year.start = as.numeric(format(metadata$dates[1], format = "%Y"))
  year.end = as.numeric(format(metadata$dates[length(metadata$dates)], format = "%Y"))
  for (i in seq(year.start, year.end, 10)) {
    at <- rep(1, 10)
    # if (i > yeare)
    for (j in (i + 1):min(i + 9, year.end + 1)) {
      if (leapyear(j)) at[j - i + 1] <- at[j - i] + 366 else
        at[j - i + 1] <- at[j - i] + 365
    }

    tmp.dates <- format(cio@dates, format = "%Y")
    ttmp <- cio@data[[var1]][tmp.dates >= i & tmp.dates <= min(i + 9, year.end)]
    plot(1:length(ttmp), ttmp, type = type, col = "blue",
      xlab = "", ylab = "", xaxt = "n", xlim = c(1, 3660), ylim = c(ymin, ymax))
    abline(h = 0)
    tt <- seq(1, length(ttmp))
    if (!is.null(ttmp)) tt <- tt[is.na(ttmp) == TRUE]
    axis(side = 1, at = at, labels = c(i:(i + 9)))
    for (k in 1:10)
      abline(v = at[k], col = "yellow")
    lines(tt, rep(ymin, length(tt)), type = "p", col = "red")
    title(paste("Station: ", tit, ", ", i, "~", min(i + 9, year.end), ",  ", var1, sep = ""))
if(i==year.start) {   mtext(paste0("Time series for ",var), outer=TRUE, cex=1.5, line=-0.2) }
  }
}
