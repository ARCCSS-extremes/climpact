calculate.hw_ehf <- function(metadata, cio, outputFolders, pdf.dev, shortName, units) {
    # If heatwave previous percentiles have been read in by user then use these in heatwave calculations, 
    # otherwise let climdex.hw calculate percentiles using currently loaded data.
    # #{ tx90p <- hwlist$HW.TX90 ; tn90p <- hwlist$HW.TN90 ; tavg90p <- hwlist$HW.TAVG90 } else {
    tx90p <<- tn90p <<- tavg90p <<- tavg05p <<- tavg95p <<- NULL

    index.stored <- climdex.hw_ehf(cio,ehfdef="NF13")

    write.hw_ehf.csv(index.stored, cio, index.name = as.character(shortName), header = "Heatwave severity, duration, number and days as per Nairn and Fawcett (2015)", metadata, outputFolders)
#    plot.hw(index.stored[['hw_indices']], index.name = as.character(shortName), index.units = as.character(units), x.label = "Years", metadata = metadata, outputFolders, pdf.dev)

}
