library(testthat)
library(dplyr)

# USAGE:
# > library(testthat)
# > test_file("test_output.R")


compare_csv_files <- function(file1, file2, n=0) {
  df1 <- read.csv(file1)
  df2 <- read.csv(file2)

  df1_subset <- df1[-(1:n), ]  # Exclude the first n rows
  df2_subset <- df2[-(1:n), ]  # Exclude the first n rows
  rownames(df1_subset) = NULL
  rownames(df2_subset) = NULL

  # Check if the data frames are identical
  if (identical(df1_subset, df2_subset)) {
    return(list(identical = TRUE, differences = NULL))
  } else {
    # Find differences
    diff_df1 <- anti_join(df1_subset, df2_subset)
    diff_df2 <- anti_join(df2_subset, df1_subset)
    return(list(identical = FALSE, differences = list(diff_df1, diff_df2)))
  }
}

test_that("CSV outputs are correct", {
  print_diffs = FALSE

  # Define the paths to your generated and correct files
  test_dir = "../../www/output/sydney_observatory_hill_1936-2015/"
  correct_dir = "./"
  generated_files <- c(list.files(paste0(test_dir,"/indices/"), full.names = FALSE),
                       list.files(paste0(test_dir,"/thres/"), full.names = FALSE),
                       list.files(paste0(test_dir,"/trend/"), full.names = FALSE))
  correct_files <- c(list.files(paste0(correct_dir,"/indices/"), full.names = FALSE),
                     list.files(paste0(correct_dir,"/thres/"), full.names = FALSE),
                     list.files(paste0(correct_dir,"/trend/"), full.names = FALSE))
  test_index_files = list.files(paste0(test_dir,"/indices/"), full.names = FALSE)
  expect_true(length(test_index_files) > 0, info = paste("No generated index CSV files found in", test_dir))
  compared_files <- 0L
  print(test_index_files)
  print(length(test_index_files))

  for (file in test_index_files) {
	correct_file <- sub("_NOBASE", "", file, fixed = TRUE)
	corr_file = paste0(correct_dir,"/indices/",correct_file)
    test_file = paste0(test_dir,"/indices/",file)

    if (!file.exists(test_file) || !file.exists(corr_file)) {
      missing_file <- if (!file.exists(test_file)) test_file else corr_file
      message("Skipping comparison; file not found: ", missing_file)
      next
    }

    compared_files <- compared_files + 1L
    result <- compare_csv_files(test_file, corr_file, n=7)

    expect_true(result$identical, info = paste("Files do not match:\n", test_file,"\n",corr_file))    

    if ((!result$identical) && (print_diffs)) {
      cat("Files do not match:", basename(corr_file), "\n")
      cat("Differences in", basename(test_file), "not in correct file:\n")
      print(result$differences[[1]])  # Differences in generated file
      cat("Differences in correct file not in", basename(test_file), ":\n")
      print(result$differences[[2]])  # Differences in correct file
    }
  }  
  expect_true(compared_files > 0, info = "No generated index CSV files had matching reference files")
})
