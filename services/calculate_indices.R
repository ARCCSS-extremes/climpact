# This function loops through all indices and calls the appropriate functions to calculate them.
# It contains functions for some indices that are not kept in climpact.etsci-functions.r. This is because they are specific to the GUI.
index.calc <- function(progress, metadata, outputFolders) {
  calculate.custom.index <- function(outputFolders) {
    print("calculating custom index", quote = FALSE)
    for (frequency in c("annual", "monthly")) {
      if (var.choice == "DTR") { var.choice2 = cio@data$dtr; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin * cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmax }
      else if (var.choice == "TX") { var.choice2 = cio@data$tmax; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmax }
      else if (var.choice == "TN") { var.choice2 = cio@data$tmin; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin }
      else if (var.choice == "TM") { var.choice2 = cio@data$tavg; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin }
      else if (var.choice == "PR") { var.choice2 = cio@data$prec; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$prec }

      if (op.choice == ">") { op.choice2 = "gt" }
      else if (op.choice == ">=") { op.choice2 = "ge" }
      else if (op.choice == "<") { op.choice2 = "lt" }
      else if (op.choice == "<=") { op.choice2 = "le" }

      if (is.null(var.choice2)) return()
      index.stored <- number.days.op.threshold(var.choice2, cio@date.factors[[match.arg(frequency, choices = c("annual", "monthly"))]], constant.choice, op.choice) * mask.choice
      write.index.csv(index.stored, index.name = paste(var.choice, op.choice2, constant.choice, sep = ""), freq = frequency, metadata)
      plot.call(index.stored, index.name = paste(var.choice, op.choice2, constant.choice, sep = ""), index.units = "days", x.label = "Years", sub = paste("Number of days where ", var.choice, " ", op.choice, " ", constant.choice, sep = ""), freq = frequency, outputFolders)

      if (exists("mktrend")) {
        cat(file = trend_file, paste(paste(var.choice, op.choice2, constant.choice, sep = ""), frequency, metadata$year.start, metadata$year.end, mktrend[[1]][1], mktrend[[1]][2], mktrend[[1]][3], sep = ","), fill = 180, append = T)

        if (frequency == "monthly") {
          print("monthly index")
          cat(file = trend_file, paste(paste(var.choice, op.choice2, constant.choice, sep = ""), "DJF", metadata$year.start, metadata$year.end, DJFtrend[[1]][1], DJFtrend[[1]][2], DJFtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(var.choice, op.choice2, constant.choice, sep = ""), "MAM", metadata$year.start, metadata$year.end, MAMtrend[[1]][1], MAMtrend[[1]][2], MAMtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(var.choice, op.choice2, constant.choice, sep = ""), "JJA", metadata$year.start, metadata$year.end, JJAtrend[[1]][1], JJAtrend[[1]][2], JJAtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(var.choice, op.choice2, constant.choice, sep = ""), "SON", metadata$year.start, metadata$year.end, SONtrend[[1]][1], SONtrend[[1]][2], SONtrend[[1]][3], sep = ","), fill = 180, append = T)
        }
        browser()
        # TODO remove globalvars, why is this even here?
        remove(mktrend, envir = .GlobalEnv)
      }
    }
  }

  if (!is.null(progress)) progress$inc(0.01)

  calculate.hw <- function(metadata, outputFolders) {
    # If heatwave previous percentiles have been read in by user then use these in heatwave calculations, otherwise let climdex.hw calculate percentiles using currently loaded data.
    # #{ tx90p <- hwlist$HW.TX90 ; tn90p <- hwlist$HW.TN90 ; tavg90p <- hwlist$HW.TAVG90 } else {
    tx90p <<- tn90p <<- tavg90p <<- tavg05p <<- tavg95p <<- NULL #}

    index.stored <- climdex.hw(cio) #,tavg90p=tavg90p,tn90p=tn90p,tx90p=tx90p)

    write.hw.csv(index.stored, index.name = as.character(index.list$Short.name[i]), header = "Heatwave definitions and aspects", metadata, outputFolders)
    plot.hw(index.stored, index.name = as.character(index.list$Short.name[i]), index.units = as.character(index.list$Units[i]), x.label = "Years", metadata = metadata, outputFolders)

  }

  calculate.spei <- function(metadata) {
    if (all(is.na(cio@data$tmin)) | all(is.na(cio@data$tmax)) | all(is.na(cio@data$prec))) { print("NO DATA FOR SPEI.", quote = FALSE); return() } else {
      # If SPEI/SPI thresholds have been read in by user then use these in SPEI/SPI calculations.
      if (exists("speiprec")) { tnraw <- speitmin; txraw <- speitmax; praw <- speiprec; btime <- speidates } else {
        tnraw <- txraw <- praw <- btime <- NULL
      }

      if (!is.null(btime)) computefuture = TRUE else computefuture = FALSE
      ts.start <- c(as.numeric(metadata$date.years[1]), 1)
      ts.end <- c(as.numeric(metadata$date.years[length(metadata$date.years)]), 12)

      # Code related to creating spi* variables aren't needed when relying on climpact2.r. However, due to ostensible issues with CRAN SPEI, this code needs to be rolled into this file in order to call our own SPEI code.
      if (computefuture) {
        # construct dates
        beg = as.Date(btime[1])
        end = dates[length(dates)] #as.Date(paste(base.year.end,"12","31",sep="-"))
        dat.seq = seq(beg, end, by = "1 day")
        spidates = dat.seq
        spitmin <- spitmax <- spiprec <- spifactor <- vector(mode = "numeric", length = length(spidates))
        spitmin[1:length(tnraw)] = tnraw
        spitmax[1:length(txraw)] = txraw
        spiprec[1:length(praw)] = praw

        spitmin[(length(spitmin) - length(cio@data$tmin) + 1):length(spitmin)] = cio@data$tmin
        spitmax[(length(spitmax) - length(cio@data$tmax) + 1):length(spitmax)] = cio@data$tmax
        spiprec[(length(spiprec) - length(cio@data$prec) + 1):length(spiprec)] = cio@data$prec
        spifactor = factor(format(spidates, format = "%Y-%m"))
        ts.start <- c(as.numeric(format(beg, format = "%Y")), 1)
      } else {
        spitmin = cio@data$tmin
        spitmax = cio@data$tmax
        spiprec = cio@data$prec
        spifactor = cio@date.factors$monthly
      }

      ######################################
      # Calculate SPEI via old climpact code

      # get monthly means of tmin and tmax. And monthly total precip.
      tmax_monthly <- as.numeric(tapply.fast(spitmax, spifactor, mean, na.rm = TRUE))
      tmin_monthly <- as.numeric(tapply.fast(spitmin, spifactor, mean, na.rm = TRUE))
      prec_sum <- as.numeric(tapply.fast(spiprec, spifactor, function(x) { if (all(is.na(x))) { return(NA) } else { return(sum(x, na.rm = TRUE)) }})) # Needed this function since summing a series of NA with na.rm = TRUE results in zero instead of NA.
      tmax_monthly[tmax_monthly == "NaN"] <- NA
      tmin_monthly[tmin_monthly == "NaN"] <- NA

      # Caclulate evapotranspiration estimate and create time-series object.
      pet = as.numeric(hargreaves(tmin_monthly, tmax_monthly, lat = latitude, Pre = prec_sum, na.rm = TRUE))
      dat = ts(prec_sum - pet, freq = 12, start = ts.start, end = ts.end)
      index.store <- array(c(cspei(dat, na.rm = T, scale = c(3), ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12), basetmin = tnraw, basetmax = txraw, baseprec = praw, basetime = btime)$fitted,
          cspei(dat, na.rm = T, scale = c(6), ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
          cspei(dat, na.rm = T, scale = c(12), ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
          cspei(dat, na.rm = T, scale = c(custom_SPEI), ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted),
          c(length((cspei(dat, na.rm = T, scale = c(3))$fitted)), 4))
      index.store <- aperm(index.store, c(2, 1))

      # End calculating SPEI via old climpact code
      ######################################

      ######################################
      # Calculate SPEI via CRAN SPEI package housed in climpact2.r
      #			index.store <- climdex.spei(cio,ref.start=c(base.year.start,1),ref.end=c(base.year.end,12),lat=latitude,basetmin=tnraw,basetmax=txraw,baseprec=praw,basetime=btime)

      # Temporary SPEI to mask out values that should be NA
      #			spiprec = cio@data$prec
      #        	        spitmin = cio@data$tmin
      #	                spitmax = cio@data$tmax
      #                        prec_sum <- as.numeric(tapply.fast(spiprec,cio@date.factors$monthly,function(x) { if(all(is.na(x))) { return(NA) } else { return(sum(x,na.rm=TRUE)) } } ))
      #        		tmax_monthly <- as.numeric(tapply.fast(spitmax,cio@date.factors$monthly,mean,na.rm=TRUE))
      #		        tmin_monthly <- as.numeric(tapply.fast(spitmin,cio@date.factors$monthly,mean,na.rm=TRUE))
      #			pet <- hargreaves(tmin_monthly,tmax_monthly,lat=latitude,Pre=prec_sum,na.rm=TRUE)
      #			tmpspei = spei(ts(prec_sum-pet,freq=12,start=ts.start,end=ts.end),scale=1,ref.start=c(base.year.start,1),ref.end=c(base.year.end,12),na.rm=TRUE)$fitted
      #			index.store[,which(is.na(tmpspei))] = NA

      # End calculating SPEI via CRAN SPEI package housed in climpact2.r
      ######################################

      index.store <- ifelse(index.store == "Inf" | index.store == "-Inf" | index.store == "NaN", NA, index.store)

      # - Strip back off all data not part of the original time series.
      # - Another kludge here relates to an ostensible bug in the SPEI function. When SPEI is fed a series of NA values followed by valid data, it returns values of SPEI/SPI for those NA values, when it shouldn't.
      #    The author has been alerted to this problem. But this means that when a synthetic time series has been made for scenarios using reference data from a different dataset, the initial SPEI/SPI values need
      #    to be manually removed. The first 2, 5 and 11 values for each final time series needs NA'ing, corresponding to 3, 6 and 12 month calculation periods.
      if (computefuture) {
        index.store <- index.store[, (length(index.store[1,]) - length(unique(cio@date.factors$monthly)) + 1):length(index.store[1,])]
        # remove spurious values that shouldn't exist (but exist anyway due to the synthetic time series we've fed the spei/spi function).
        index.store[1, 1:2] <- NA
        index.store[2, 1:5] <- NA
        index.store[3, 1:11] <- NA
        index.store[4, 1:(custom_SPEI - 1)] <- NA
        spifactor <- spifactor[(length(spifactor) - length((cio@date.factors$monthly)) + 1):length(spifactor)]
      }
      write.precindex.csv(index.store, index.name = index.list$Short.name[82], spifactor, header = "Standardised Precipitation-Evapotranspiration Index", metadata)
      plot.precindex(index.store, index.name = index.list$Short.name[82], index.units = index.list$Units[81], x.label = "Years", spifactor, sub = as.character(index.list$Definition[82]), times = c(3, 6, 12, custom_SPEI), metadata = metadata)
    }
  }

  calculate.spi <- function(metadata) {
    if (all(is.na(cio@data$prec))) { print("NO DATA FOR SPI.", quote = FALSE); return() } else {
      if (exists("speiprec")) { tnraw <- speitmin; txraw <- speitmax; praw <- speiprec; btime <- speidates } else {
        tnraw <- txraw <- praw <- btime <- NULL
      }

      if (!is.null(btime)) computefuture = TRUE else computefuture = FALSE
      ts.start <- c(as.numeric(metadata$date.years[1]), 1)
      ts.end <- c(as.numeric(metadata$date.years[length(metadata$date.years)]), 12)

      # Code related to creating spi* variables aren't needed when relying on climpact2.r. However, due to ostensible issues with CRAN SPEI, this code needs to be rolled into this file in order to call our own SPEI code.
      if (computefuture) {
        # construct dates
        beg = as.Date(btime[1])
        end = dates[length(dates)]
        dat.seq = seq(beg, end, by = "1 day")
        spidates = dat.seq

        spiprec <- spifactor <- array(NA, length(spidates))
        spiprec[1:length(praw)] = praw

        spiprec[(length(spiprec) - length(cio@data$prec) + 1):length(spiprec)] = cio@data$prec
        spifactor = factor(format(spidates, format = "%Y-%m"))

        ts.start <- c(as.numeric(format(beg, format = "%Y")), 1)
      } else {
        spiprec = cio@data$prec
        spifactor = cio@date.factors$monthly
      }

      ######################################
      # Calculate SPI via old climpact code

      # get monthly total precip.
      prec_sum <- as.numeric(tapply.fast(spiprec, spifactor, function(x) { if (all(is.na(x))) { return(NA) } else { return(sum(x, na.rm = TRUE)) }})) # Needed this function since summing a series of NA with na.rm = TRUE results in zero instead of NA.

      # Create time-series object.
      dat <- ts(prec_sum, freq = 12, start = ts.start, end = ts.end)
      index.store <- array(c(cspi(dat, na.rm = T, scale = 3, ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
          cspi(dat, na.rm = T, scale = 6, ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
          cspi(dat, na.rm = T, scale = 12, ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
          cspi(dat, na.rm = T, scale = custom_SPEI, ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted),
          c(length((cspi(prec_sum, na.rm = T, scale = c(3))$fitted)), 4))
      index.store <- aperm(index.store, c(2, 1))

      # End calculating SPI via old climpact code
      ######################################

      index.store <- ifelse(index.store == "Inf" | index.store == "-Inf" | index.store == "NaN", NA, index.store)

      # - Strip back off all data not part of the original time series.
      # - Another kludge here relates to an ostensible bug in the SPEI function. When SPEI is fed a series of NA values followed by valid data, it returns values of SPEI/SPI for those NA values, when it shouldn't.
      #    The author has been alerted to this problem. But this means that when a synthetic time series has been made for scenarios using reference data from a different dataset, the initial SPEI/SPI values need
      #    to be manually removed. The first 2, 5 and 11 values for each final time series needs NA'ing, corresponding to 3, 6 and 12 months calculation periods.
      if (computefuture) {
        index.store <- index.store[, (length(index.store[1,]) - length(unique(cio@date.factors$monthly)) + 1):length(index.store[1,])]
        # remove spurious values that shouldn't exist (but exist anyway due to the synthetic time series we've fed the spei/spi function).
        index.store[1, 1:2] <- NA
        index.store[2, 1:5] <- NA
        index.store[3, 1:11] <- NA
        index.store[4, 1:(custom_SPEI - 1)] <- NA
        spifactor <- spifactor[(length(spifactor) - length((cio@date.factors$monthly)) + 1):length(spifactor)]
      }
      write.precindex.csv(index.store, index.name = index.list$Short.name[83], spifactor, header = "Standardised Precipitation Index", metadata)
      plot.precindex(index.store, index.name = index.list$Short.name[83], index.units = index.list$Units[82], x.label = "Years", spifactor, sub = as.character(index.list$Definition[83]), times = c(3, 6, 12, custom_SPEI), metadata = metadata)
    }
  }

  # pdf file for all plots
  # Check 'all' PDF isn't open, then open.
  pdfname = paste0(outputFolders$stationName, "_all_plots.pdf")

  # ClimPACT has sole access to this file, should not encounter errors.
  pdf(file = file.path(outputFolders$outjpgdir, pdfname), height = 8, width = 11.5)
  pdf.dev = dev.cur()
  browser()
  # TODO remove globalvars, use session var if necessary
  assign('pdf.dev', pdf.dev, envir = .GlobalEnv)

  # trend file
  trend_file <- file.path(outputFolders$outtrddir, paste0(outputFolders$stationName, "_trend.csv"))
  browser()
  # TODO remove globalvars
  assign('trend_file', trend_file, envir = .GlobalEnv)
  write_header(trend_file, "Linear trend statistics", metadata)
  cat(file = trend_file, paste("Index", "Frequency", "StartYear", "EndYear", "Slope", "STD_of_Slope", "P_Value", sep = ","), fill = 180, append = T)

  # Read in index .csv file
  index.list <- read.csv("server/climate.indices.csv", header = T, sep = '\t')

  # create a list of indices that do not require a 'frequency' parameter
  no.freq.list = c("r95ptot", "r99ptot", "sdii", "hddheat", "cddcold", "gddgrow", "r95p", "r99p", "gsl", "spi", "spei", "hw", "wsdi", "wsdin", "csdi", "csdin", "ntxntn", "ntxbntnb")

  if (!is.null(progress)) progress$inc(0.01)

  #####################################
  # MEAT DONE HERE
  # Loop through and calculate and plot each index

  for (i in 1:length(index.list$Short.name)) {
    print(paste("calculating", index.list$Short.name[i]), quote = FALSE)
    tmp.index.name = as.character(index.list$Short.name[i])

    if (!is.null(progress)) progress$inc(0.01, detail = paste("Calculating", index.list$Short.name[i], "..."))
    tmp.index.def = as.character(index.list$Definition[i])
    # Set frequency if relevant to current index
    if (is.na(index.list$Annual.flag[i])) frequency = NA
    else {
      if (index.list$Annual.flag[i] == TRUE) frequency = "annual"
      else frequency = "monthly"
    }

    if (!as.character(index.list$Short.name[i]) %in% no.freq.list) index.parameter = paste("cio,freq=\"", frequency, "\"", sep = "")
    else index.parameter = paste("cio", sep = "")

    if (index.list$Short.name[i] == "hw") { calculate.hw(); next }
    else if (index.list$Short.name[i] == "spei") { calculate.spei(metadata); next }
    else if (index.list$Short.name[i] == "spi") { calculate.spi(metadata); next }
    else if (index.list$Short.name[i] == "rnnmm") {
      tmp.index.name = paste("r", rnnmm_ud, "mm", sep = "")
      index.parameter = paste(index.parameter, rnnmm_ud, sep = ",")
      tmp.index.def = paste("Number of days when precipitation >= ", rnnmm_ud, sep = "")
    }
    else if (index.list$Short.name[i] == "wsdid") {
      tmp.index.name = paste("wsdi", wsdi_ud, sep = "")
      index.parameter = paste("cio,n=", wsdi_ud, sep = "")
      tmp.index.def = paste("Annual number of days with at least ", wsdi_ud, " consecutive days when TX > 90th percentile", sep = "")
    }
    else if (index.list$Short.name[i] == "csdid") {
      tmp.index.name = paste("csdi", csdi_ud, sep = "")
      index.parameter = paste("cio,n=", csdi_ud, sep = "")
      tmp.index.def = paste("Annual number of days with at least ", csdi_ud, " consecutive days when TN < 10th percentile", sep = "")
    }
    else if (index.list$Short.name[i] == "txdtnd") {
      tmp.index.name = paste("tx", txtn_ud, "tn", txtn_ud, sep = "")
      index.parameter = paste("cio,n=", txtn_ud, sep = "")
      tmp.index.def = paste("Number of ", txtn_ud, " consecutive days where both TX > 95th percentile and TN > 95th percentile", sep = "")
    }
    else if (index.list$Short.name[i] == "txbdtnbd") {
      tmp.index.name = paste("txb", txtn_ud, "tnb", txtn_ud, sep = "")
      index.parameter = paste("cio,n=", txtn_ud, sep = "")
      tmp.index.def = paste("Number of ", txtn_ud, " consecutive days where both TX < 5th percentile and TN < 5th percentile", sep = "")
    }
    else if (index.list$Short.name[i] == "rxdday") {
      tmp.index.name = paste("rx", rx_ud, "day", sep = "")
      index.parameter = paste(index.parameter, ",n=", rx_ud, sep = "")
      tmp.index.def = paste("Maximum ", rx_ud, "-day precipitation total", sep = "")
    }
    else if (index.list$Short.name[i] == "hddheatn") {
      tmp.index.name = paste("hddheat", Tb_HDD, sep = "")
      index.parameter = paste("cio,Tb=", Tb_HDD, sep = "")
      tmp.index.def = paste("Annual sum of ", Tb_HDD, " - TM", sep = "")
    }
    else if (index.list$Short.name[i] == "cddcoldn") {
      tmp.index.name = paste("cddcold", Tb_CDD, sep = "")
      index.parameter = paste("cio,Tb=", Tb_CDD, sep = "")
      tmp.index.def = paste("Annual sum of TM - ", Tb_CDD, sep = "")
    }
    else if (index.list$Short.name[i] == "gddgrown") {
      tmp.index.name = paste("gddgrow", Tb_GDD, sep = "")
      index.parameter = paste("cio,Tb=", Tb_GDD, sep = "")
      tmp.index.def = paste("Annual sum of TM - ", Tb_GDD, sep = "")
    }

    index.stored <- eval(parse(text = paste("climdex.", as.character(index.list$Short.name[i]), "(", index.parameter, ")", sep = ""))) #index.function(cio)
    index.stored[index.stored == -Inf] = NA # Because climdex functions (called in above line) will still calculate even if all data are NA, resulting in -Inf values being inserted into index.stored. Climdex functions only check if cio data are NULL.
    write.index.csv(index.stored, index.name = tmp.index.name, freq = frequency, header = tmp.index.def, metadata)
    plot.call(index.stored, index.name = tmp.index.name, index.units = as.character(index.list$Units[i]), x.label = "Years", sub = tmp.index.def, freq = frequency, outputFolders)

    if (exists("mktrend")) {
      cat(file = trend_file, paste(tmp.index.name, frequency, metadata$year.start, metadata$year.end, mktrend[[1]][1], mktrend[[1]][2], mktrend[[1]][3], sep = ","), fill = 180, append = T)

      if (index.list$Short.name[i] != "tx95t" && frequency == "monthly") {
        print("monthly index")
        cat(file = trend_file, paste(tmp.index.name, "DJF", metadata$year.start, metadata$year.end, DJFtrend[[1]][1], DJFtrend[[1]][2], DJFtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "MAM", metadata$year.start, metadata$year.end, MAMtrend[[1]][1], MAMtrend[[1]][2], MAMtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "JJA", metadata$year.start, metadata$year.end, JJAtrend[[1]][1], JJAtrend[[1]][2], JJAtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "SON", metadata$year.start, metadata$year.end, SONtrend[[1]][1], SONtrend[[1]][2], SONtrend[[1]][3], sep = ","), fill = 180, append = T)
      }
    browser()
    # TODO remove globalvars
      remove(mktrend, envir = .GlobalEnv)
    }

    remove(index.parameter)

  }
  if (!is.null(progress)) progress$inc(0.05)

  if (length(op.choice) == 0 || length(var.choice) == 0) { print("no custom index to calculate", quote = FALSE) } else { calculate.custom.index() }
  dev.off(pdf.dev)

  if (!is.null(progress)) progress$inc(0.01)
}
# end of index.calc