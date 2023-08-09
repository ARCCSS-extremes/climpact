calculate.spei <- function(metadata, cio, outputFolders, pdf.dev, custom_SPEI, index.list, trend_file) {
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

      # Calculate evapotranspiration estimate and create time-series object.
      pet = as.numeric(hargreaves(tmin_monthly, tmax_monthly, lat = metadata$lat, Pre = prec_sum, na.rm = TRUE))
      dat = ts(prec_sum - pet, freq = 12, start = ts.start, end = ts.end)
      index.store <- array(c(cspei(dat, na.rm = T, scale = c(3), ref.start = c(metadata$base.start, 1), ref.end = c(metadata$base.end, 12))$fitted,
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
      spei_row_num <- match("spei",index.list$Short.name)
      write.precindex.csv(index.store, index.name = index.list$Short.name[spei_row_num], spifactor, header = "Standardised Precipitation-Evapotranspiration Index", metadata, outputFolders, custom_SPEI)
      plot.precindex(index.store, index.name = index.list$Short.name[spei_row_num], index.units = index.list$Units[spei_row_num], x.label = "Years", spifactor, sub = as.character(index.list$Definition[spei_row_num]), times = c(3, 6, 12, custom_SPEI), metadata, outputFolders, pdf.dev, trend_file)
    }
  }
