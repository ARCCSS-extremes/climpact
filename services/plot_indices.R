# plot.hw
plot.hw <- function(index = NULL, index.name = NULL, index.units = NULL, x.label = NULL, metadata, outputFolders, pdf.dev) {
  if (is.null(index)) stop("Need heatwave data to plot.")

  definitions <- c("Tx90", "Tn90", "EHF", "ECF")
  aspects <- c("HWM", "HWA", "HWN", "HWD", "HWF")
  units <- c("°C", "°C", "heatwaves", "days", "days")
  Encoding(units) <- "UTF-8"
  for (def in 1:length(definitions)) {
  print(def)
    for (asp in 1:length(aspects)) {
      print(asp)
      if (all(is.na(index[def, asp, ]))) { warning(paste("All NA values detected, not plotting ", aspects[asp], ", ", definitions[def], ".", sep = "")); next }

      plot.title <- paste0("Station: ", metadata$title.station)
      if (definitions[def] == "ECF") { namp <- paste(outputFolders$outplotsdir, paste(metadata$stationName, "_", tolower(gsub("H", "C", aspects[asp])), "_", tolower(definitions[def]), "_ANN.png", sep = ""), sep = "/") }
      else { namp <- paste(outputFolders$outplotsdir, paste(metadata$stationName, "_", tolower(aspects[asp]), "_", tolower(definitions[def]), "_ANN.png", sep = ""), sep = "/") }
      png(file = namp, width = 800, height = 600)
      dev0 = dev.cur()

      if (aspects[asp] == "HWM" && !definitions[def] == "ECF") { sub = paste("Index: ", aspects[asp], "-", definitions[def], ". Heatwave Magnitude (mean temperature of all heatwave events)", sep = "") }
      else if (aspects[asp] == "HWA" && !definitions[def] == "ECF") { sub = paste("Index: ", aspects[asp], "-", definitions[def], ". Heatwave Amplitude (peak temperature of the hottest heatwave event)", sep = "") }
      else if (aspects[asp] == "HWD" && !definitions[def] == "ECF") { sub = paste("Index: ", aspects[asp], "-", definitions[def], ". Heatwave Duration (length of longest heatwave event)", sep = "") }
      else if (aspects[asp] == "HWF" && !definitions[def] == "ECF") { sub = paste("Index: ", aspects[asp], "-", definitions[def], ". Heatwave Frequency (number of days contributing to heatwave events)", sep = "") }
      else if (aspects[asp] == "HWN" && !definitions[def] == "ECF") { sub = paste("Index: ", aspects[asp], "-", definitions[def], ". Heatwave Number (number of discreet heatwave events)", sep = "") }

      if (aspects[asp] == "HWM" && definitions[def] == "ECF") { sub = paste("Index: ", gsub("H", "C", aspects[asp]), "-", definitions[def], ". Coldwave Magnitude (mean temperature of all coldwave events)", sep = "") }
      else if (aspects[asp] == "HWA" && definitions[def] == "ECF") { sub = paste("Index: ", gsub("H", "C", aspects[asp]), "-", definitions[def], ". Coldwave Amplitude (minimum temperature of the coldest coldwave event)", sep = "") }
      else if (aspects[asp] == "HWD" && definitions[def] == "ECF") { sub = paste("Index: ", gsub("H", "C", aspects[asp]), "-", definitions[def], ". Coldwave Duration (length of longest coldwave event)", sep = "") }
      else if (aspects[asp] == "HWF" && definitions[def] == "ECF") { sub = paste("Index: ", gsub("H", "C", aspects[asp]), "-", definitions[def], ". Coldwave Frequency (number of days contributing to coldwave events)", sep = "") }
      else if (aspects[asp] == "HWN" && definitions[def] == "ECF") { sub = paste("Index: ", gsub("H", "C", aspects[asp]), "-", definitions[def], ". Coldwave Number (number of discreet coldwave events)", sep = "") }

      if ((definitions[def] == "EHF" || definitions[def] == "ECF") && any(aspects[asp] == "HWM", aspects[asp] == "HWA")) { unit = "°C^2"; Encoding(unit) <- "UTF-8" } else unit = units[asp]

      #mktrend <<- autotrend(index[def,asp,],icor=1)
      x1 = seq(1, length(index[def, asp,]), 1) #as.numeric(names(index))
      y1 = unname(index[def, asp,])
      zsen = zyp.sen(y1 ~ x1)
      ci = confint(zsen, level = 0.95)
      mktrend <<- list(stat = array(NA, 5))
      mktrend$stat[1] <<- unname(ci[2, 1])
      mktrend$stat[2] <<- unname(zsen[[1]][2]) # slope
      mktrend$stat[3] <<- unname(ci[2, 2])
      mktrend$stat[4] <<- unname(zsen[[1]][1]) # y-intercept

      plotx((metadata$date.years), index[def, asp,], main = gsub('\\*', unit, plot.title), ylab = unit, xlab = x.label, index.name = index.name, sub = sub)

      dev.set(which = pdf.dev)
      plotx((metadata$date.years), index[def, asp,], main = gsub('\\*', unit, plot.title), ylab = unit, xlab = x.label, index.name = index.name, sub = sub)
      dev.off(dev0)

      # TODO resolve bug when climdex.pcic not available (dodgy package release): cat(file=trend_file,paste(paste(definitions[def],aspects[asp],sep="."),"ANN",metadata$year.start,metadata$year.end,round(as.numeric(out$coef.table[[1]][2, 1]), 3),round(as.numeric(out$coef.table[[1]][2, 2]), 3),round(as.numeric(out$summary[1, 6]),3),sep=","),fill=180,append=T)
  
      # TODO remove global vars
      remove(mktrend, envir = .GlobalEnv)
    }
  }
  
  graphics.off()
}

# plotx
# make plots, this is called twice to make image and pdf files.
plotx <- function(x, y, main = "", xlab = "", ylab = "", opt = 0, index.name = NULL, sub = "") {
  if (all(is.na(y))) { print("NO DATA TO PLOT", quote = FALSE); return() }
  Encoding(main) <- "UTF-8"
  Encoding(sub) <- "UTF-8"
  # take a copy of input, so we will not modify the input by mistake.
  # And only take index values from the first non-NA value onwards, to avoid plotting long series of NA values.
  nay <- which(!is.na(y))
  #	x <- x0#[nay[1]:nay[length(nay)]]
  #	y <- y0#[nay[1]:nay[length(nay)]]

  # james: i'm turning xpd off for barplots, so that i can clip the range w/o the bars
  # running off the page. is this required?
  par(oma = c(2, 1, 1, 1), xpd = FALSE, new = FALSE) #to enable things to be drawn outside the plot region
  #names(y) <- c(strtrim(x,4))

  # calculate range to limit the plots to (otherwise barplots are useless... they're in
  # any non-barplots for consistency). also to allow for overlays like marking na points
  # y.range <- range(y, na.rm = TRUE) #- 0.1 * (max(y, na.rm = TRUE) - min(y, na.rm = TRUE))
  # x.range <- min(x, na.rm = TRUE)      # should be no missing data in the x series

  if (index.name == "spei" | index.name == "spi") {
    bp <- barplot(y, main = main, cex.main = 2, ylim = range(y, na.rm = TRUE), xlab = NULL, ylab = ylab, cex.lab = 1.5, cex.axis = 1.5, xpd = FALSE, col = ifelse(y > 0, "blue", "red"), border = NA, space = c(0, 0))
    mtext(sub, cex = 1)
    # NA points
    na.x <- bp
    na.y <- rep(NA, length(na.x))
    na.y[is.na(y)] <- par("usr")[3]
    points(na.x, na.y, pch = 17, col = "blue", cex = 1.5)

    subx = as.numeric(substr(x, 1, 4))
    xind = which(subx %% 5 == 0)
    xind = xind[seq(1, length(xind), 12)]
    xtmp.int = unique(subx[xind])
    axis(1, at = xind, labels = c(xtmp.int))

    box()
    #			xy <- cbind(bp,y)
  } else {
    op <- par(mar = c(5, 4, 5, 2) + 0.1)
    plot(1:length(x), unname(y), cex.main = 2, ylim = range(unname(y), na.rm = TRUE), xaxt = "n", xlab = "", ylab = ylab, type = "b", cex.lab = 1.5, cex.axis = 1.5, col = "black")
    par(op)
    title(main, line = 2.5, cex.main = 2)

    subx = as.numeric(substr(x, 1, 4))
    xind = which(subx %% 5 == 0)
    if (nchar(x[1]) == 7) {
      xind = xind[seq(1, length(xind), 12)]
      xtmp.int = unique(subx[xind])
    } else {
      xtmp.int = subx[xind]
    }
    axis(1, at = xind, labels = c(xtmp.int))

    mtext(paste(strwrap(sub, width = 100), collapse = "\n"), cex = 1)

    # NA points
    na.x <- x
    na.y <- rep(NA, length(na.x))
    na.y[is.na(y)] <- min(y, na.rm = TRUE)

    points(1:length(na.x), na.y, pch = 17, col = "blue", cex = 1.5)
    #			xy <- cbind(x, y)
  }
  
  if (opt == 1) return() # no need to plot trend/fitting curve.
  if (opt == 2) {
    abline(h = 0.)
    return()
  }
  # for spei & spi only!
  # xtmp = x[!is.na(xy)]
  # xy <- na.omit(xy)
  tmp_seq = 1:length(x)



  # NOTE by nherold. The zyp.sen function in some cases returns an intercept of NA even though there is a valid slope. This seems erroneous and results in slopes being
  # printed but prevents a trend line from being plotted! Must fix. If this is a bug in the zyp package then need to try another package.
  if ((sum(is.na(y) == FALSE) >= min_trend) && (!is.null(mktrend$stat[2]))) # && (!is.na(mktrend$stat[4])))
  {
    subtit <- paste0("Sen's slope = ", round(mktrend$stat[2], 3), "   lower bound = ", round(mktrend$stat[1], 3), ",   upper bound = ", round(mktrend$stat[3], 3)) # least squares regression
    print(paste0(mktrend$stat[4], " : ", mktrend$stat[2]))
    #abline(mktrend$stat[4],mktrend$stat[2])
  } else {
    subtit <- paste0("No linear trend due to insufficient valid data points (", min_trend, ").")
  }

  #	tmp_lowess=lowess(tmp_seq[!is.na(y)], y[!is.na(y)])   #xy[,2])
  #	lines(tmp_lowess, lwd = 3, lty = 2, col = "red")  # add fitting curve

  # add mktrend line. nherold.
  #	if(!is.na(mktrend$stat[4]) && !is.na(mktrend$stat[2])) {
  print(paste0(mktrend$stat[4], " : ", mktrend$stat[2]))
  #		abline(mktrend$stat[4],mktrend$stat[2])
  #	}



  title(sub = subtit, cex.sub = 1.5)

  old.par = par() # store par settings to plot legend outside figure margins
  par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)
  plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
  #	legend("bottomleft","locally weighted scatterplot smoothing",col = "red", lty = 2, lwd = 3, bty = "n")
  legend("bottomright", paste("ClimPACT v ", version.climpact, sep = ""), col = "white", lty = 2, lwd = 0, bty = "n")
  suppressWarnings(par(old.par)) # restore previous par settings. Suppress warnings regarding parameters that cannot be set.
}
# end of plotx

# plot.index
plot.call <- function(index = NULL, index.name = NULL, index.units = NULL, x.label = NULL, sub = "", freq = "annual", metadata, outputFolders, pdf.dev = NULL) {
  print(index)
  if (is.null(index.name) | is.null(index) | is.null(index.units)) stop("Need index data, index.name, index units and an x label in order to plot data.")
  if (all(is.na(index))) { print(paste0("NO DATA FOR ", index.name, ". NOT PLOTTING."), quote = FALSE); return() }

  Encoding(sub) <- "UTF-8"
  Encoding(index.units) <- "UTF-8"
  #	plot.title <- paste(title.station,index.name,sep=", ")
  if (index.name == "wsdin") { tmp.name = paste("wsdi", wsdi_ud, sep = ""); sub = paste("Index: ", tmp.name, ". Annual number of days with at least ", wsdi_ud, " consecutive days when TX > 90th percentile", sep = "") }
  else if (index.name == "csdin") { tmp.name = paste("csdi", csdi_ud, sep = ""); sub = paste("Index: ", tmp.name, ". Annual number of days with at least ", csdi_ud, " consecutive days when TN < 10th percentile", sep = "") }
  else if (index.name == "rxnday") { tmp.name = paste("rx", rx_ud, "day", sep = ""); sub = paste("Index: ", tmp.name, ". Maximum ", freq, " ", rx_ud, "-day precipitation total", sep = "") }
  else if (index.name == "rnnmm") { tmp.name = paste("r", rnnmm_ud, "mm", sep = ""); sub = paste("Index: ", tmp.name, ". ", freq, " number of days when precipitation >= ", rnnmm_ud, "mm", sep = "") }
  else if (index.name == "ntxntn") { tmp.name = paste(txtn_ud, "tx", txtn_ud, "tn", sep = ""); sub = paste("Index: ", tmp.name, ". Annual number of ", txtn_ud, " consecutive days where both TX > 95th percentile and TN > 95th percentile", sep = "") }
  else if (index.name == "ntxbntnb") { tmp.name = paste(txtn_ud, "txb", txtn_ud, "tnb", sep = ""); sub = paste("Index: ", tmp.name, ". Annual number of ", txtn_ud, " consecutive days where both TX < 5th percentile and TN < 5th percentile", sep = "") }
  else if (index.name == "cddcold") { tmp.name = index.name; sub = paste("Index: ", tmp.name, ". Annual sum of TM - ", Tb_CDD, "°C (where ", Tb_CDD, "°C is a user-defined base temperature and should be smaller than TM)", sep = "") }
  else if (index.name == "hddheat") { tmp.name = index.name; sub = paste("Index: ", tmp.name, ". Annual sum of ", Tb_HDD, "°C - TM (where ", Tb_HDD, "°C is a user-defined base temperature and should be larger than TM)", sep = "") }
  else if (index.name == "gddgrow") { tmp.name = index.name; sub = paste("Index: ", tmp.name, ". Annual sum of TM - ", Tb_GDD, "°C (where ", Tb_GDD, "°C is a user-defined base temperature and should be smaller than TM)", sep = "") }
  else { tmp.name = index.name; sub = paste("Index: ", tmp.name, ". ", sub, sep = "") }

  if (index.name == "tx95t") { freq = "DAY" }
  else {
    if (freq == "monthly") { freq = "MON" }
    else if (freq == "annual") { freq = "ANN" }
  }

  x1 = seq(1, length(index), 1) #as.numeric(names(index))
  y1 = unname(index)
  zsen = zyp.sen(y1 ~ x1)
  print("zyp.sen")
  print(zsen)
  ci = confint(zsen, level = 0.95)
  mktrend <<- list(stat = array(NA, 5))
  mktrend$stat[1] <<- unname(ci[2, 1])
  mktrend$stat[2] <<- unname(zsen[[1]][2]) # slope
  mktrend$stat[3] <<- unname(ci[2, 2])
  mktrend$stat[4] <<- unname(zsen[[1]][1]) # y-intercept

  years = as.numeric(substr(names(index), 1, 4))
  firstyear = years[1]
  if (sum(years == firstyear) > 1) {
    monthsGLOB <<- as.numeric(substr(names(index), 6, 7))
    yearsGLOB <<- as.numeric(substr(names(index), 1, 4))
    months = monthsGLOB
    years = yearsGLOB

    df = data.frame(months, years, unname(index))
    names(df) = c("months", "years", "values")

    # assign function based on index
    if (index.name %in% c("txx", "tnx", "rx1day", "rx5day", "rxnday", "cwd", "cdd")) {
      f <- get("max", mode = "function")
    } else if (index.name %in% c("tnn", "txn")) {
      f <- get("min", mode = "function")
    } else if (index.name %in% c("su", "tr", "txge30", "txge35", "r10mm", "r20mm", "rnnmm", "prcptot")) {
      f <- get("sum", mode = "function")
    } else {
      f <- get("mean", mode = "function")
    }
    ym <- as.yearmon(paste(months, years), "%m %Y")
    yq <- as.yearqtr(head(ym + 1 / 12, -1))
    Ag <- aggregate(head(df$values, -1) ~ yq, head(df, -1), f)

    names(Ag) = c("yq", "values")
    DJF = Ag[seq(1, length(Ag$yq), 4),]
    MAM = Ag[seq(2, length(Ag$yq), 4),]
    JJA = Ag[seq(3, length(Ag$yq), 4),]
    SON = Ag[seq(4, length(Ag$yq), 4),]

    # remove first DJF value since it isn't complete (no December of preceeding year). The last DJF value is already excluded.
    DJF$values[1] = NA

    x1 = seq(1, length(DJF$values), 1) #as.numeric(names(index))
    y1 = unname(DJF$values)
    zsen = zyp.sen(y1 ~ x1)
    ci = confint(zsen, level = 0.95)
    DJFtrend <<- list(stat = array(NA, 5))
    DJFtrend$stat[1] <<- unname(ci[2, 1])
    DJFtrend$stat[2] <<- unname(zsen[[1]][2])
    DJFtrend$stat[3] <<- unname(ci[2, 2])

    x1 = seq(1, length(MAM$values), 1) #as.numeric(names(index))
    y1 = unname(MAM$values)
    zsen = zyp.sen(y1 ~ x1)
    ci = confint(zsen, level = 0.95)
    MAMtrend <<- list(stat = array(NA, 5))
    MAMtrend$stat[1] <<- unname(ci[2, 1])
    MAMtrend$stat[2] <<- unname(zsen[[1]][2])
    MAMtrend$stat[3] <<- unname(ci[2, 2])

    x1 = seq(1, length(JJA$values), 1) #as.numeric(names(index))
    y1 = unname(JJA$values)
    zsen = zyp.sen(y1 ~ x1)
    ci = confint(zsen, level = 0.95)
    JJAtrend <<- list(stat = array(NA, 5))
    JJAtrend$stat[1] <<- unname(ci[2, 1])
    JJAtrend$stat[2] <<- unname(zsen[[1]][2])
    JJAtrend$stat[3] <<- unname(ci[2, 2])

    x1 = seq(1, length(SON$values), 1) #as.numeric(names(index))
    y1 = unname(SON$values)
    zsen = zyp.sen(y1 ~ x1)
    ci = confint(zsen, level = 0.95)
    SONtrend <<- list(stat = array(NA, 5))
    SONtrend$stat[1] <<- unname(ci[2, 1])
    SONtrend$stat[2] <<- unname(zsen[[1]][2])
    SONtrend$stat[3] <<- unname(ci[2, 2])
  }

  namp <- file.path(outputFolders$outplotsdir, paste0(outputFolders$stationName, "_", tmp.name, "_", freq, ".png"))
  png(file = namp, width = 800, height = 600)

  dev0 = dev.cur()
  if (index.name == "tx95t") { xdata <- 1:length(index) }
  else xdata <- names(index)

  plot.title <- paste0("Station: ", metadata$title.station)
  plotx(xdata, index, main = gsub('\\*', tmp.name, plot.title),
    ylab = index.units, xlab = x.label, index.name = index.name, sub = sub)

  dev.set(which = pdf.dev)
  plotx(xdata, index, main = gsub('\\*', tmp.name, plot.title),
    ylab = index.units, xlab = x.label, index.name = index.name, sub = sub)
  #	dev.copy()
  dev.off(dev0)
}
