## Correlation between climate and sector data

# draw the correlation between temperature and industry data
draw.correlation <- function(progress, user.file, sector.file, stationName, plot.title, detrendCheck){

  # Change directory where output should be stored
  curwd <- getwd()
  setwd(corrdir)

  error <- create.correlation.plots(progress, user.file, sector.file, stationName, plot.title, detrendCheck, curwd)

  setwd(curwd)
  return(error)
}

# create the correlation plots and save them to disk
create.correlation.plots <- function(progress, user.file, sector.file, stationName, plot.title, detrendCheck, curwd){

  climate.data <- read_user_file(user.file)
  # assume the sector data is a csv file for now
  sector.data <- read.csv(sector.file)

  # Increment progress bar.
  progress$inc(0.1)

  # match on common data, if not throw error!
  temp_per_year <-  climate.data %>% group_by(year) %>% summarise(avg_tmax = mean(tmax, na.rm = TRUE), avg_tmin = mean(tmin, na.rm = TRUE), avg_t = mean(c(tmax,tmin), na.rm = TRUE), above30 = sum(tmax > 30, na.rm = TRUE))
  common_years <- intersect(temp_per_year$year, sector.data$Year)
  
  # need at least 10 common years
  if (length(common_years) < 10){
    return("Error: not able to make a correlation, since there is no data in common!")
  }

  # Get sector column name..assume it is the 2nd column!
  sectorColumnName <- colnames(sector.data)[2]

  # add detrend column
  sector.data[,getDetrendedColumnName(sectorColumnName)] <- calculateDeTrendValues(sector.data, 1, 2)
  sector.data.fileparts <- tolower(gsub("\\.{2}.*$", "", colnames(sector.data)))[2:3]

  # selection
  sector.data <- sector.data %>% filter(Year %in% common_years)
  temp_per_year <- temp_per_year %>% filter(year %in% common_years)
  temp_per_year_sector <- cbind(temp_per_year, sector.data[,2], sector.data[,3])
  colnames(temp_per_year_sector) <- c("year", "avg_tmax", "avg_tmin", "avg_t", "above30", sectorColumnName, getDetrendedColumnName(sectorColumnName))

  # depending on detrend, select column
  sectorCol <- ifelse(detrendCheck, getDetrendedColumnName(sectorColumnName), sectorColumnName)
  sectorColumnFilePart <- sectorColumnToFileName(sectorCol, sector.data.fileparts)

  # JMC when do we overwrite this with user's sector specific label?
  # Answer: Never... TODO fix this
  wheat_plot_y_label <- "Wheat Yield (t/ha)"

  # plot tmin vs wheat
  create_save_scatter_plot(paste0(stationName, "_corr_tmin_",sectorColumnFilePart), temp_per_year_sector, "avg_tmin", sectorCol, plot.title, "Average min temperature", wheat_plot_y_label)
  progress$inc(0.2)

  # plot tmax vs wheat
  create_save_scatter_plot(paste0(stationName, "_corr_tmax_",sectorColumnFilePart), temp_per_year_sector, "avg_tmax", sectorCol, plot.title, "Average max temperature", wheat_plot_y_label)
  progress$inc(0.2)

  # plot t vs wheat
  create_save_scatter_plot(paste0(stationName, "_corr_t_",sectorColumnFilePart), temp_per_year_sector, "avg_t", sectorCol, plot.title, "Average temperature", wheat_plot_y_label)
  progress$inc(0.2)

  # plot above30 vs wheat
  create_save_scatter_plot(paste0(stationName, "_corr_above30_",sectorColumnFilePart), temp_per_year_sector, "above30", sectorCol, plot.title, "Days above 30°C", wheat_plot_y_label)
  progress$inc(0.2)

  #JMC add scatter plot for each index
  #JMC two overview bar plots, one with precip and one with temp related indices

  # create barplot of indice value (not normalized) vs sector data
  indices <- c("wsdi", "wsdi1", "fd", "tnlt2", "rx1day", "rx3day", "cdd", "sdii")
  filenames <- file.path(curwd, outinddir, paste0(stationName, "_", indices, "_ANN.csv"))
  indices.count <- length(indices)
  # init dataframe
  df <- data.frame(indice = character(indices.count), cor = double(indices.count), category = character(indices.count), stringsAsFactors = FALSE)

  # loop over files and add row to dataframe for each file
  found.indices <- c()
  for(i in 1:indices.count){
    indice.file <- filenames[i]

    if(file.exists(indice.file)){
      indice.data <- read.csv(indice.file, skip = 8, header = FALSE) # skip first 8 lines since they contain some header text
      colnames(indice.data) <- c("year", "value", "value.norm")
      common_years <- intersect(indice.data$year, sector.data$Year)
      if (length(common_years) == 0){
        return("Error: not able to make a correlation, since there is no data in common!")
      }
      # selection
      sector.common <- sector.data %>% filter(Year %in% common_years)
      indice.data <- indice.data %>% filter(year %in% common_years)
      sector_indices <- cbind(sector.common, indice.data$value, indice.data$value.norm)
      #JMC use Spearman in preference to Pearson
      correlation <- round(cor(sector_indices[,-1]),2) # skip year and round correlation value by 2 decimals

      # add data
      df[i,"indice"] <- indices[i]
      df[i,"cor"] <-  ifelse(grepl("Detrended", sectorCol), correlation[7], correlation[3])
      df[i, "category"] <- ifelse(indices[i] %in% indices[1:4], "temperature", "precipitation")
      found.indices <- append(found.indices, indices[i])
    } else{
      print(paste("File does not exist:", indice.file))
    }
  }
  df <- df[df$indice != "",]
  df$indice <- factor(df$indice, levels = found.indices)
  create_bar_plot(paste0(stationName, "_indice_",sectorColumnFilePart), df, "indice", "cor", "category", plot.title, "", "")

  progress$inc(0.1)
  # all ok
  return("")
}

# get detrended column name given the sector column name
getDetrendedColumnName <- function(sectorColumnName){
  return(paste("Detrended", sectorColumnName, sep = "."))
}

# get part of the filename that is related to the sector column
sectorColumnToFileName <- function(sectorColumnName, fileparts){
  ifelse(grepl("Detrended", sectorColumnName), fileparts[2], fileparts[1])
}

# calculate detrend values based on given dataframe and sector and year column
calculateDeTrendValues <- function(df, yearColumn, sectorColumn){
  result <- c()
  lineair_model <- lm(df[,sectorColumn] ~ df[,yearColumn])
  regressionCoefficient <- lineair_model[[1]][2]
  totalRows <- nrow(df)
  for(i in 1:nrow(df)){
    currentValue <- df[i,sectorColumn]
    averageRow <- ifelse(nrow(df) %% 2 == 1, mean((seq(1:nrow(df)))), mean((seq(1:(nrow(df) +1)))))
    value <- currentValue - (i-averageRow) * regressionCoefficient
    result <- append(result, value)
  }
  return(result)
}

# default font size in plots
FONT_BASE_SIZE <- 12

# create scatter plot with trend line, and save the plot to jpg file
create_save_scatter_plot <- function(filename, df, x, y, plot.title, x.label, y.label){
  annotateX <- min(df[,x]) + (max(df[,x]) - min(df[,x])) / 8
  annotateY <- max(df[,y])
  lm.sector <- lm(data = df, paste(y, "~", x, sep = ""))
  rsquared <- round(summary(lm.sector)$r.squared, 2)
  coefficients <- round(summary(lm.sector)$coefficients, 2)
  annotateText <- paste("Y=", coefficients[2], "X", ifelse(coefficients[1] >= 0, "+", "-"), abs(coefficients[1]), "\nR2:", as.character(rsquared))

  p <- ggplot(df, aes_string(x, y)) +
    geom_point(colour ='red') +                                                    # points with red color
    geom_smooth(method=lm, se = FALSE, colour = "black") +                         # draw lineair regression line without confidence interval
    ggtitle(plot.title) + xlab(x.label) + ylab(y.label) +
    annotate("text", label = annotateText, x = annotateX, y = annotateY) +
    theme_grey(base_size = FONT_BASE_SIZE) +                                       # increase font size
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())  # remove the white gridlines

  ggsave(paste0(filename, ".jpg"), plot=p, width = 8, height = 6)

  # save csv file of data
  df_csv <- df[, c("year", x, y)]
  write.csv(df_csv, file = paste0(filename, ".csv"), row.names = FALSE)
}

# create bar plot of given dataframe. Variable z is the feature to be used to fill the bar.
create_bar_plot <- function(filename, df, x, y, z, plot.title, x.label, y.label){
  text_position <- 0.5 * df[,"cor"]
  p <- ggplot(df, aes_string(x, y, fill=z)) +
    geom_bar(stat="identity") +
    scale_fill_manual(values=c("#2fa4e7","red")) +                                 # custom colors (first one is the same blue as in the app)
    ggtitle(plot.title) + xlab(x.label) + ylab(y.label) +                          # title, labels
    geom_text(aes_string(label=y, y=text_position)) +                              # text halfway in bar
    theme_grey(base_size = FONT_BASE_SIZE) +                                       # increase font size
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())  # remove the white gridlines

  ggsave(paste0(filename, ".jpg"), plot=p, width = 8, height = 6)

  # save csv file of data
  write.csv(df, file = paste0(filename, ".csv"), row.names = FALSE)
}
