calculate.custom.index <- function(cio, metadata, climdexInputParams, outputFolders, pdf.dev, trend_file) {
    print("calculating custom index", quote = FALSE)
    for (frequency in c("annual", "monthly")) {
      if (climdexInputParams$var.choice == "DTR") { climdexInputParams$var.choice2 = cio@data$dtr; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin * cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmax }
      else if (climdexInputParams$var.choice == "TX") { climdexInputParams$var.choice2 = cio@data$tmax; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmax }
      else if (climdexInputParams$var.choice == "TN") { climdexInputParams$var.choice2 = cio@data$tmin; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin }
      else if (climdexInputParams$var.choice == "TM") { climdexInputParams$var.choice2 = cio@data$tavg; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$tmin }
      else if (climdexInputParams$var.choice == "PR") { climdexInputParams$var.choice2 = cio@data$prec; mask.choice = cio@namasks[[match.arg(frequency, choices = c("annual", "monthly"))]]$prec }

      if (climdexInputParams$op.choice == ">") { op.choice2 = "gt" }
      else if (climdexInputParams$op.choice == ">=") { op.choice2 = "ge" }
      else if (climdexInputParams$op.choice == "<") { op.choice2 = "lt" }
      else if (climdexInputParams$op.choice == "<=") { op.choice2 = "le" }

      if (is.null(climdexInputParams$var.choice2)) return()
      indexName <- paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = "")
      header <- paste(climdexInputParams$var.choice, climdexInputParams$op.choice, climdexInputParams$constant.choice, sep = " ")
      index.stored <- number.days.op.threshold(climdexInputParams$var.choice2, cio@date.factors[[match.arg(frequency, choices = c("annual", "monthly"))]], climdexInputParams$constant.choice, climdexInputParams$op.choice) * mask.choice
      write.index.csv(index.stored, indexName, frequency, header, metadata, climdexInputParams, outputFolders)
      plot.call(index.stored, index.name = indexName, index.units = "days", x.label = "Years", sub = paste("Number of days where ", climdexInputParams$var.choice, " ", climdexInputParams$op.choice, " ", climdexInputParams$constant.choice, sep = ""), freq = frequency, metadata, outputFolders, pdf.dev)

      if (exists("mktrend")) {
        cat(file = trend_file, paste(paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = ""), frequency, metadata$year.start, metadata$year.end, mktrend[[1]][1], mktrend[[1]][2], mktrend[[1]][3], sep = ","), fill = 180, append = T)

        if (frequency == "monthly") {
          print("monthly index")
          cat(file = trend_file, paste(paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = ""), "DJF", metadata$year.start, metadata$year.end, DJFtrend[[1]][1], DJFtrend[[1]][2], DJFtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = ""), "MAM", metadata$year.start, metadata$year.end, MAMtrend[[1]][1], MAMtrend[[1]][2], MAMtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = ""), "JJA", metadata$year.start, metadata$year.end, JJAtrend[[1]][1], JJAtrend[[1]][2], JJAtrend[[1]][3], sep = ","), fill = 180, append = T)
          cat(file = trend_file, paste(paste(climdexInputParams$var.choice, op.choice2, climdexInputParams$constant.choice, sep = ""), "SON", metadata$year.start, metadata$year.end, SONtrend[[1]][1], SONtrend[[1]][2], SONtrend[[1]][3], sep = ","), fill = 180, append = T)
        }
        # TODO why is this even here?
        remove(mktrend, envir = .GlobalEnv)
      }
    }
  }
