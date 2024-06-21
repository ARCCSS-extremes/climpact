# write_table: Appends outliers to CSV file
# variable [striong]: column name in dataframe 'datos' to reference
# boxplot [boxplot]: the boxplot object to retrieve outlier information from
# var_tag [string]: subtitle to use in CSV file
# filename [string]: file to append to
# datos [df]: dataframe with the data
# operator [string]: Should be ">" or "<" depending on whether we want to find outliers above or below threshold
# stat_index [numeric]: Should probably be 1 or 5, refers to the specific statistic stored in boxplot$stats
write_table <- function(variable,boxplot,var_tag,filename,datos,operator,stat_index) {
  write.table(var_tag, sep = ",", file = filename, append = TRUE, row.names = FALSE, col.names = FALSE)
  for (a in 1:12) {
    BoxError = tryCatch({
      mon_name = as.numeric(boxplot$names[a])
      prov <- subset(datos, datos$month == mon_name & get(operator)(datos[variable],boxplot$stats[stat_index, a]))
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filename,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
      },
      error=function(e) e
    )
    if(inherits(BoxError, "error")) {
      next
    }
  }
}

# Plots boxplots. Needs only station and save
# TODO refactor so that calling this function twice (once for PNG and once for PDF)
# will not write to csv files twice.
# combo of if (file.exists(filena)) and
# an eg 'overwrite' function parameter -
# to ensure we can update csv files on subsequent QC checks)
fourboxes <- function(station, output, save = 0, iqr_threshold_temp, iqr_threshold_prec, metadata, mediaType = "pdf") {
  if (save == 1) {
    fileName <- paste0(output, "_boxes.", mediaType)
    if (mediaType == "pdf") {
      pdf(file = fileName)
    } else if (mediaType == "png") {
      png(file = fileName, width = 640, height = 640)
    }
  }

  datos <- read.table(station, col.names = c("year", "month", "day", "pc", "tx", "tn"), na.strings = "-99.9")
  datos$tr <- datos$tx - datos$tn
  prec <- subset(datos, datos$pc > 0)
  par(mfrow = c(2, 2),mar=c(4,4,2,2.5), oma=c(2,2,2,2.5))

  # we open a file for writing outliers. First time is not append; rest is append
  filena <- paste(output, "_outliers.csv", sep = "")

  # for each of precip, tmax, tmin, dtr:
  #   produce boxplots: IQR for default is 3 for temp and 5 for precip
  #     can be entered as parameter when calling the function. Precip will always be 2 units more than temp
  #   write outliers out
  # if no data's available, 'no data available' is printed on a blank panel instead
  write_header(filena, paste0("Outliers shown in *boxes.png. IQR thresholds of ",iqr_threshold_prec," and ",iqr_threshold_temp," were used for precipitation and temperature variables, respectively."), metadata)
  write.table(cbind("Date", "Prec", "TX", "TN", "DTR"), sep = ",", file = filena, append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)

  # Precipitation boxplot and outliers table
  if (any(!is.na(prec$pc))) {
    respc <- boxplot(prec$pc ~ prec$month, main = "NON ZERO PREC", col = "blue", range = iqr_threshold_prec,xlab="Month",ylab="mm")

    write_table(variable="pc",boxplot=respc,var_tag="Prec up",filename=filena,datos=datos,operator=">",stat_index=5)
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  # TX boxplot and outliers table
  if (any(!is.na(datos$tx))) {
    restx <- boxplot(datos$tx ~ datos$month, main = "TX", col = "red", range = iqr_threshold_temp,xlab="Month",ylab="\u00B0C")

    write_table(variable="tx",boxplot=restx,var_tag="TX up",filename=filena,datos=datos,operator=">",stat_index=5)
    write_table(variable="tx",boxplot=restx,var_tag="TX low",filename=filena,datos=datos,operator="<",stat_index=1)
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  # TN boxplot and outliers table
  if (any(!is.na(datos$tn))) {
    restn <- boxplot(datos$tn ~ datos$month, main = "TN", col = "cyan", range = iqr_threshold_temp,xlab="Month",ylab="\u00B0C")

    write_table(variable="tn",boxplot=restn,var_tag="TN up",filename=filena,datos=datos,operator=">",stat_index=5)
    write_table(variable="tn",boxplot=restn,var_tag="TN low",filename=filena,datos=datos,operator="<",stat_index=1)
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  # DTR boxplot and outliers table
  if (any(!is.na(datos$tr))) {
    restr <- boxplot(datos$tr ~ datos$month, col = "yellow", main = "DTR", range = iqr_threshold_temp,xlab="Month",ylab="\u00B0C")

    write_table(variable="tr",boxplot=restr,var_tag="DTR up",filename=filena,datos=datos,operator=">",stat_index=5)
    write_table(variable="tr",boxplot=restr,var_tag="DTR low",filename=filena,datos=datos,operator="<",stat_index=1)
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  mtext("Outliers per calendar month", outer=TRUE, cex=1.5, line=-0.2)

  if (save == 1) dev.off()

  rm(datos)
}
