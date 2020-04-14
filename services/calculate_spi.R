  calculate.spi <- function(metadata, cio, outputFolders, pdf.dev, custom_SPEI, index.list, trend_file) {
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
      spi_row_num <- 83
      write.precindex.csv(index.store, index.name = index.list$Short.name[spi_row_num], spifactor, header = "Standardised Precipitation Index", metadata, outputFolders, custom_SPEI)
      plot.precindex(index.store, index.name = index.list$Short.name[spi_row_num], index.units = index.list$Units[spi_row_num], x.label = "Years", spifactor, sub = as.character(index.list$Definition[spi_row_num]), times = c(3, 6, 12, custom_SPEI), metadata, outputFolders, pdf.dev, trend_file)
    }
  }
