# plot.precindex
# not sure how generic this process can be
plot.precindex <- function(index = NULL, index.name = NULL, index.units = NULL, x.label = NULL, spifactor = NULL, sub = "", times = "", metadata, outputFolders, pdf.dev, trend_file) {
  if (is.null(index)) stop("Need precip data to plot.")
  Encoding(sub) <- "UTF-8"

  plot.title <- paste0("Station: ", metadata$title.station)

  for (time in 1:4) {
    if (all(is.na(index[time, ]))) {
      warning(paste0("All NA values detected, not plotting ", times[time], " month ", index.name, "."))
      next
    }

    subtmp <- paste("Index: ", index.name, " ", times[time], " month. ", sub, sep = "")
    namp <- paste(outputFolders$outplotsdir, paste(metadata$stationName, "_", times[time], "month_", index.name, "_MON.jpg", sep = ""), sep = "/")
    jpeg(file = namp, width = 1024, height = 768)

    #mktrend <<- autotrend(index[time,],icor=1)
    x1   <- seq(1, length(index[time, ]), 1) #as.numeric(names(index))
    y1   <- unname(index[time, ])
    zsen <- zyp.sen(y1 ~ x1)
    ci   <- confint(zsen, level = 0.95)
    mktrend <<- list(stat = array(NA, 5))
    mktrend$stat[1] <<- unname(ci[2, 1])
    mktrend$stat[2] <<- unname(zsen[[1]][2]) # slope
    mktrend$stat[3] <<- unname(ci[2, 2])
    mktrend$stat[4] <<- unname(zsen[[1]][1]) # y-intercept

    dev0 <- dev.cur()
    plotx(unique(as.character(spifactor)), index[time,], main = paste(gsub('\\*', index.name, plot.title), sep = ""), ylab = index.units, xlab = x.label, index.name = index.name, sub = subtmp)

    dev.set(which = pdf.dev)
    plotx(unique(as.character(spifactor)), index[time,], main = paste(gsub('\\*', index.name, plot.title), sep = ""), ylab = index.units, xlab = x.label, index.name = index.name, sub = subtmp)    
    dev.off(dev0)

    # Seasonal trend code.
    y <- index[time, ]
    df <- data.frame(monthsGLOB, yearsGLOB, y)
    names(df) <- c("months", "years", "values")

    # if SPI/SPEI 3 month then calculate the trend and write out.
    if (times[time] == 3) {
      # extract every Feb, May, Aug and Nov month to represent DJF, MAM, JJA and SON respectively.
      DJF = df[seq(2, length(y), 12),]
      MAM = df[seq(5, length(y), 12),]
      JJA = df[seq(8, length(y), 12),]
      SON = df[seq(11, length(y), 12),]

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

      # DJFtrend<<-autotrend(DJF$values,icor=1)
      # MAMtrend<<-autotrend(MAM$values,icor=1)
      # JJAtrend<<-autotrend(JJA$values,icor=1)
      # SONtrend<<-autotrend(SON$values,icor=1)

      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "FEB", metadata$year.start, metadata$year.end, DJFtrend[[1]][1], DJFtrend[[1]][2], DJFtrend[[1]][3], sep = ","), fill = 180, append = T)
      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "MAY", metadata$year.start, metadata$year.end, MAMtrend[[1]][1], MAMtrend[[1]][2], MAMtrend[[1]][3], sep = ","), fill = 180, append = T)
      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "AUG", metadata$year.start, metadata$year.end, JJAtrend[[1]][1], JJAtrend[[1]][2], JJAtrend[[1]][3], sep = ","), fill = 180, append = T)
      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "NOV", metadata$year.start, metadata$year.end, SONtrend[[1]][1], SONtrend[[1]][2], SONtrend[[1]][3], sep = ","), fill = 180, append = T)
    } else if (times[time] == 6) {
      A = df[seq(4, length(y), 12),]
      O = df[seq(10, length(y), 12),]

      x1 = seq(1, length(A$values), 1) #as.numeric(names(index))
      y1 = unname(A$values)
      zsen = zyp.sen(y1 ~ x1)
      ci = confint(zsen, level = 0.95)
      Atrend <<- list(stat = array(NA, 5))
      Atrend$stat[1] <<- unname(ci[2, 1])
      Atrend$stat[2] <<- unname(zsen[[1]][2])
      Atrend$stat[3] <<- unname(ci[2, 2])

      x1 = seq(1, length(O$values), 1) #as.numeric(names(index))
      y1 = unname(O$values)
      zsen = zyp.sen(y1 ~ x1)
      ci = confint(zsen, level = 0.95)
      Otrend <<- list(stat = array(NA, 5))
      Otrend$stat[1] <<- unname(ci[2, 1])
      Otrend$stat[2] <<- unname(zsen[[1]][2])
      Otrend$stat[3] <<- unname(ci[2, 2])

      # Atrend = autotrend(A$values,icor=1)
      # Otrend = autotrend(O$values,icor=1)

      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "APR", metadata$year.start, metadata$year.end, Atrend[[1]][1], Atrend[[1]][2], Atrend[[1]][3], sep = ","), fill = 180, append = T)
      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "OCT", metadata$year.start, metadata$year.end, Otrend[[1]][1], Otrend[[1]][2], Otrend[[1]][3], sep = ","), fill = 180, append = T)

    } else if (times[time] == 12) {
      J = df[seq(6, length(y), 12),]
      D = df[seq(12, length(y), 12),]

      x1 = seq(1, length(D$values), 1) #as.numeric(names(index))
      y1 = unname(D$values)
      zsen = zyp.sen(y1 ~ x1)
      ci = confint(zsen, level = 0.95)
      Dtrend <<- list(stat = array(NA, 5))
      Dtrend$stat[1] <<- unname(ci[2, 1])
      Dtrend$stat[2] <<- unname(zsen[[1]][2])
      Dtrend$stat[3] <<- unname(ci[2, 2])

      x1 = seq(1, length(J$values), 1) #as.numeric(names(index))
      y1 = unname(J$values)
      zsen = zyp.sen(y1 ~ x1)
      ci = confint(zsen, level = 0.95)
      Jtrend <<- list(stat = array(NA, 5))
      Jtrend$stat[1] <<- unname(ci[2, 1])
      Jtrend$stat[2] <<- unname(zsen[[1]][2])
      Jtrend$stat[3] <<- unname(ci[2, 2])

      # Jtrend = autotrend(J$values,icor=1)
      # Dtrend = autotrend(D$values,icor=1)

      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "JUN", metadata$year.start, metadata$year.end, Jtrend[[1]][1], Jtrend[[1]][2], Jtrend[[1]][3], sep = ","), fill = 180, append = T)
      cat(file = trend_file, paste(paste(index.name, times[time], sep = ""), "DEC", metadata$year.start, metadata$year.end, Dtrend[[1]][1], Dtrend[[1]][2], Dtrend[[1]][3], sep = ","), fill = 180, append = T)
    }
    remove(mktrend, envir = .GlobalEnv)
  }
}
