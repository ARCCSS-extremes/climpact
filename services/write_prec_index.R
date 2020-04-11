# write.precindex.csv
write.precindex.csv <- function(index = NULL, index.name = NULL, spifactor = NULL, header = "", metadata) {
  if (is.null(index)) stop("Need SPEI data to write CSV file.")
  colnames <- list("time", index.name)

  # write 3 month data
  nam1 <- paste(outinddir, paste(ofilename, "_3month_", index.name, "_MON.csv", sep = ""), sep = "/")
  write_header(nam1, header, metadata)
  write.table(colnames, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind(unique(as.character(spifactor)), index[1,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write 6 month data
  nam1 <- paste(outinddir, paste(ofilename, "_6month_", index.name, "_MON.csv", sep = ""), sep = "/")
  write_header(nam1, header, metadata)
  write.table(colnames, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind(unique(as.character(spifactor)), index[2,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write 12 month data
  nam1 <- paste(outinddir, paste(ofilename, "_12month_", index.name, "_MON.csv", sep = ""), sep = "/")
  write_header(nam1, header, metadata)
  write.table(colnames, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind(unique(as.character(spifactor)), index[3,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)

  # write custom-period data
  nam1 <- paste(outinddir, paste(ofilename, "_", custom_SPEI, "month_", index.name, "_MON.csv", sep = ""), sep = "/")
  write_header(nam1, header, metadata)
  write.table(colnames, file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
  write.table(cbind(unique(as.character(spifactor)), index[4,]), file = nam1, append = TRUE, quote = FALSE, sep = ", ", na = "-99.9", row.names = FALSE, col.names = FALSE)
}
