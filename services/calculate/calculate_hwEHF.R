# call the function to calculate EHF heatwaves, then write and plot all five heatwave characteristics.
calculate.hwEHF <- function(metadata, cio, outputFolders, pdf.dev, shortName, units) {
    index.stored <- climdex.hwEHF(cio,ehfdef="NF13")
    write.hwEHF.csv(index.stored, cio, index.name = as.character(shortName), header = "Heatwave severity, duration, number, frequency and intensity. Based on the Excess Heat Factor as described by Nairn and Fawcett (2015)", metadata, outputFolders)
	plot.call(index.stored$hwd,index.name = "EHF-HWD",index.units = "days", x.label = "Years",sub = "EHF-HWD (Heatwave Duration): Duration of the longest EHF heatwave.",freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwmd,index.name = "EHF-HWMD",index.units = "days", x.label = "Years",sub = "EHF-HWMD (Heatwave Mean Duration): Mean EHF heatwave duration.",freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwps,index.name = "EHF-HWPS",index.units = "unitless", x.label = "Years",sub = "EHF-HWPS (Heatwave Peak Severity): Mean of the maximum severity of each EHF heatwave.",
			  freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwpi,index.name = "EHF-HWPI",index.units = "°C^2", x.label = "Years",sub = "EHF-HWPI (Heatwave Peak Intensity): Mean of the maximum intensity of each EHF heatwave.",
			  freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwls,index.name = "EHF-HWLS",index.units = "unitless", x.label = "Years",sub = "EHF-HWLS (Heatwave Load Severity): Sum of EHF heatwave severities.",
              freq = "annual", metadata, outputFolders, pdf.dev)
    plot.call(index.stored$hwli,index.name = "EHF-HWLI",index.units = "°C^2", x.label = "Years",sub = "EHF-HWLI (Heatwave Load Intensity): Sum of EHF heatwave intensities.",
              freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwn,index.name = "EHF-HWN",index.units = "heatwaves", x.label = "Years",sub = "EHF-HWN (Heatwave Number): Number of EHF heatwaves.",freq = "annual", metadata, outputFolders, pdf.dev)
	plot.call(index.stored$hwf,index.name = "EHF-HWF",index.units = "days", x.label = "Years",sub = "EHF-HWF (Heatwave Frequency): Number of days contributing to EHF heatwaves.",freq = "annual", metadata, outputFolders, pdf.dev)
}
