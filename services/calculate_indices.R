source("services/plot_indices.R", local = TRUE)
source("services/plot_prec_index.R", local = TRUE)
source("services/write_indices.R", local = TRUE)
source("services/write_prec_index.R", local = TRUE)
source("services/calculate/calculate_hw.R", local = TRUE)
source("services/calculate/calculate_spei.R", local = TRUE)
source("services/calculate/calculate_spi.R", local = TRUE)
source("services/calculate/custom_cspei.R", local = TRUE)
source("services/calculate/custom_cspi.R", local = TRUE)
source("services/calculate/calculate_custom_index.R", local = TRUE)

# This function loops through all indices and calls the appropriate functions to calculate them.
# It contains functions for some indices that are not kept in climpact.etsci-functions.r. This is because they are specific to the GUI.
index.calc <- function(progress, prog_int, metadata, cio, outputFolders, climdexInputParams) {

  if (!is.null(progress)) progress$inc(0.01 * prog_int)

  # pdf file for all plots
  # Check 'all' PDF isn't open, then open.
  pdfname <- paste0(outputFolders$stationName, "_all_plots.pdf")

  # ClimPACT has sole access to this file, should not encounter errors.
  pdf(file = file.path(outputFolders$outplotsdir, pdfname), height = 8, width = 11.5)
  pdf.dev <- dev.cur()

  # trend file
  trend_file <- file.path(outputFolders$outtrddir, paste0(outputFolders$stationName, "_trend.csv"))
  write_header(trend_file, "Linear trend statistics", metadata)
  cat(file = trend_file, paste("Index", "Frequency", "StartYear", "EndYear", "Slope", "STD_of_Slope", "P_Value", sep = ","), fill = 180, append = T)

  # Read in index .csv file
  index.list <- read.csv("server/climate.indices.csv", header = T, sep = "\t")

  # create a list of indices that do not require a 'frequency' parameter
  no.freq.list <- c("r95ptot", "r99ptot", "sdii", "hddheat", "cddcold", "gddgrow",
    "r95p", "r99p", "gsl", "spi", "spei", "hw", "wsdi", "wsdin", "csdi", "csdin",
    "ntxntn", "ntxbntnb")

  if (!is.null(progress)) progress$inc(0.01 * prog_int)

  #####################################
  # Loop through and calculate and plot each index

  for (i in 1:length(index.list$Short.name)) {
    print(paste("calculating", index.list$Short.name[i]), quote = FALSE)
    tmp.index.name <- as.character(index.list$Short.name[i])

    if (!is.null(progress)) {
      progress$inc(0.01 * prog_int, detail = paste("Calculating", index.list$Short.name[i], "..."))
    }
    tmp.index.def <- as.character(index.list$Definition[i])
    # Set frequency if relevant to current index
    if (is.na(index.list$Annual.flag[i])) {
      frequency <- NA
    } else {
      if (index.list$Annual.flag[i] == TRUE) {
        frequency <- "annual"
      } else {
        frequency <- "monthly"
      }
    }

    if (!as.character(index.list$Short.name[i]) %in% no.freq.list) {
      index.parameter <- paste("cio,freq=\"", frequency, "\"", sep = "")
    } else {
      index.parameter <- paste("cio", sep = "")
    }

    if (index.list$Short.name[i] == "hw") {
      calculate.hw(metadata, cio, outputFolders, pdf.dev, index.list$Short.name[i], index.list$Units[i])
      next
    }
    else if (index.list$Short.name[i] == "spei") {
      calculate.spei(metadata, cio, outputFolders, pdf.dev, climdexInputParams$custom_SPEI, index.list, trend_file)
      next
    }
    else if (index.list$Short.name[i] == "spi") {
      calculate.spi(metadata, cio, outputFolders, pdf.dev, climdexInputParams$custom_SPEI, index.list, trend_file)
      next
    }
    else if (index.list$Short.name[i] == "rnnmm") {
      tmp.index.name <- paste0("r", climdexInputParams$rnnmm_ud, "mm")
      index.parameter <- paste(index.parameter, climdexInputParams$rnnmm_ud, sep = ",")
      tmp.index.def <- paste0("Number of days when precipitation >= ", climdexInputParams$rnnmm_ud)
    }
    else if (index.list$Short.name[i] == "wsdid") {
      tmp.index.name <- paste0("wsdi", climdexInputParams$wsdi_ud)
      index.parameter <- paste0("cio,n=", climdexInputParams$wsdi_ud)
      tmp.index.def <- paste0("Annual number of days with at least ", climdexInputParams$wsdi_ud, " consecutive days when TX > 90th percentile")
    }
    else if (index.list$Short.name[i] == "csdid") {
      tmp.index.name <- paste0("csdi", climdexInputParams$csdi_ud)
      index.parameter <- paste0("cio,n=", climdexInputParams$csdi_ud)
      tmp.index.def <- paste0("Annual number of days with at least ", climdexInputParams$csdi_ud, " consecutive days when TN < 10th percentile")
    }
    else if (index.list$Short.name[i] == "txdtnd") {
      tmp.index.name <- paste0("tx", climdexInputParams$txtn_ud, "tn", climdexInputParams$txtn_ud)
      index.parameter <- paste0("cio,n=", climdexInputParams$txtn_ud)
      tmp.index.def <- paste0("Number of ", climdexInputParams$txtn_ud, " consecutive days where both TX > 95th percentile and TN > 95th percentile")
    }
    else if (index.list$Short.name[i] == "txbdtnbd") {
      tmp.index.name <- paste0("txb", climdexInputParams$txtn_ud, "tnb", climdexInputParams$txtn_ud)
      index.parameter <- paste0("cio,n=", climdexInputParams$txtn_ud)
      tmp.index.def <- paste0("Number of ", climdexInputParams$txtn_ud, " consecutive days where both TX < 5th percentile and TN < 5th percentile")
    }
    else if (index.list$Short.name[i] == "rxdday") {
      tmp.index.name <- paste0("rx", climdexInputParams$rx_ud, "day")
      index.parameter <- paste0(index.parameter, ",n=", climdexInputParams$rx_ud)
      tmp.index.def <- paste0("Maximum ", climdexInputParams$rx_ud, "-day precipitation total")
    }
    else if (index.list$Short.name[i] == "hddheatn") {
      tmp.index.name <- paste0("hddheat", climdexInputParams$Tb_HDD)
      index.parameter <- paste0("cio,Tb=", climdexInputParams$Tb_HDD)
      tmp.index.def <- paste0("Annual sum of ", climdexInputParams$Tb_HDD, " - TM")
    }
    else if (index.list$Short.name[i] == "cddcoldn") {
      tmp.index.name <- paste0("cddcold", climdexInputParams$Tb_CDD)
      index.parameter <- paste0("cio,Tb=", climdexInputParams$Tb_CDD)
      tmp.index.def <- paste0("Annual sum of TM - ", climdexInputParams$Tb_CDD)
    }
    else if (index.list$Short.name[i] == "gddgrown") {
      tmp.index.name <- paste0("gddgrow", climdexInputParams$Tb_GDD)
      index.parameter <- paste0("cio,Tb=", climdexInputParams$Tb_GDD)
      tmp.index.def <- paste0("Annual sum of TM - ", climdexInputParams$Tb_GDD)
    }

    #index.function(cio)
    index.stored <- eval(parse(text = paste0("climdex.", as.character(index.list$Short.name[i]), "(", index.parameter, ")")))
    # Because climdex functions (called in above line) will still calculate
    # even if all data are NA, resulting in -Inf values being inserted into index.stored.
    # Climdex functions only check if cio data are NULL.
    index.stored[index.stored == -Inf] <- NA
    write.index.csv(index.stored, index.name = tmp.index.name, freq = frequency, header = tmp.index.def, metadata, climdexInputParams, outputFolders)
    plot.call(index.stored,
      index.name = tmp.index.name,
      index.units = as.character(index.list$Units[i]),
      x.label = "Years",
      sub = tmp.index.def,
      freq = frequency,
      metadata, outputFolders, pdf.dev)

    if (exists("mktrend")) {
      cat(file = trend_file, paste(tmp.index.name, frequency, metadata$year.start, metadata$year.end, mktrend[[1]][1], mktrend[[1]][2], mktrend[[1]][3], sep = ","), fill = 180, append = T)

      if (index.list$Short.name[i] != "tx95t" && frequency == "monthly") {
        print("monthly index")
        cat(file = trend_file, paste(tmp.index.name, "DJF", metadata$year.start, metadata$year.end, DJFtrend[[1]][1], DJFtrend[[1]][2], DJFtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "MAM", metadata$year.start, metadata$year.end, MAMtrend[[1]][1], MAMtrend[[1]][2], MAMtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "JJA", metadata$year.start, metadata$year.end, JJAtrend[[1]][1], JJAtrend[[1]][2], JJAtrend[[1]][3], sep = ","), fill = 180, append = T)
        cat(file = trend_file, paste(tmp.index.name, "SON", metadata$year.start, metadata$year.end, SONtrend[[1]][1], SONtrend[[1]][2], SONtrend[[1]][3], sep = ","), fill = 180, append = T)
      }
    # TODO remove globalvars
      remove(mktrend, envir = .GlobalEnv)
    }

    remove(index.parameter)

  }
  if (!is.null(progress)) progress$inc(0.05 * prog_int)

  if (length(climdexInputParams$op.choice) == 0 || length(climdexInputParams$var.choice) == 0) {
    print("no custom index to calculate", quote = FALSE)
  } else {
    calculate.custom.index(cio, metadata, climdexInputParams, outputFolders, pdf.dev, trend_file)
  }
  dev.off(pdf.dev)

  if (!is.null(progress)) progress$inc(0.01 * prog_int)
}
