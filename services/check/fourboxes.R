# Plots boxplots. Needs only station and save
# TODO refactor so that calling this function twice (once for PNG and once for PDF)
# will not write to csv files twice.
# combo of if (file.exists(filena)) and
# an eg 'overwrite' function parameter -
# to ensure we can update csv files on subsequent QC checks)
fourboxes <- function(station, output, save = 0, outrange, metadata, mediaType = "pdf") {
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
  par(mfrow = c(2, 2))

  # we open a file for writing outliers. First time is not append; rest is append
  filena <- paste(output, "_outliers.csv", sep = "")

  # for each of precip, tmax, tmin, dtr:
  #   produce boxplots: IQR for default is 3 for temp and 5 for precip
  #     can be entered as parameter when calling the function. Precip will always be 2 units more than temp
  #   write outliers out
  # if no data's available, 'no data available' is printed on a blank panel instead
  write_header(filena, "Outliers shown in *boxseries.pdf", metadata)
  write.table(cbind("Date", "Prec", "TX", "TN", "DTR"), sep = ",", file = filena, append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)

  if (any(!is.na(prec$pc))) {
    respc <- boxplot(prec$pc ~ prec$month, main = "NON ZERO PREC", col = "blue", range = outrange + 2)

    # write precip outliers
    write.table("Prec up", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in as.numeric(respc$names)) {
      ind.of.month <- match(respc$names[a], respc$names)
      prov <- subset(datos, datos$month == as.numeric(respc$names[a]) & datos$pc > respc$stats[5, ind.of.month]) #a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  if (any(!is.na(datos$tx))) {
    restx <- boxplot(datos$tx ~ datos$month, main = "TX", col = "red", range = outrange)

    # write tmax outliers
    write.table("TX up", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tx > restx$stats[5, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
    write.table("TX low", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tx < restx$stats[1, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  if (any(!is.na(datos$tn))) {
    restn <- boxplot(datos$tn ~ datos$month, main = "TN", col = "cyan", range = outrange)

    # write tmin outliers
    write.table("TN up", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tn > restn$stats[5, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
    write.table("TN low", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tn < restn$stats[1, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  if (any(!is.na(datos$tr))) {
    restr <- boxplot(datos$tr ~ datos$month, col = "yellow", main = "DTR", range = outrange)

    # write dtr outliers
    write.table("DTR up", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tr > restr$stats[5, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
    write.table("DTR low", sep = ",", file = filena, append = TRUE, row.names = FALSE, col.names = FALSE)
    for (a in 1:12) {
      prov <- subset(datos, datos$month == a & datos$tr < restr$stats[1, a])
      date.tmp <- paste(prov$year, prov$month, prov$day, sep = "-")
      write.table(cbind(date.tmp, prov$pc, prov$tx, prov$tn, prov$tr),
        sep = ",",
        file = filena,
        append = TRUE,
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE)
    }
  } else {
    plot.new()
    text(x = 0.5, y = 0.5, "NO DATA AVAILABLE", adj = c(0.5, NA))
  }

  if (save == 1) dev.off()

  rm(datos)
}
