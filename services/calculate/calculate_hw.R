  calculate.hw <- function(metadata, cio, outputFolders, pdf.dev, shortName, units) {
    # If heatwave previous percentiles have been read in by user then use these in heatwave calculations, 
    # otherwise let climdex.hw calculate percentiles using currently loaded data.
    # #{ tx90p <- hwlist$HW.TX90 ; tn90p <- hwlist$HW.TN90 ; tavg90p <- hwlist$HW.TAVG90 } else {
    tx90p <<- tn90p <<- tavg90p <<- tavg05p <<- tavg95p <<- NULL #}

    # TODO test for cio values here to ensure it's not NULL
    index.stored <- climdex.hw(cio) #,tavg90p=tavg90p,tn90p=tn90p,tx90p=tx90p)

    write.hw.csv(index.stored, index.name = as.character(shortName), header = "Heatwave definitions and aspects", metadata, outputFolders)
    plot.hw(index.stored, index.name = as.character(shortName), index.units = as.character(units), x.label = "Years", metadata = metadata, outputFolders, pdf.dev)

  }
