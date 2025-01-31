#' Combine CSV Files from ZIP Archives
#'
#' This function searches for ZIP files in a specified directory that match a given pattern.
#' It then extracts CSV files from these ZIP archives that match another specified pattern.
#' The function can either combine these CSV files vertically into a single data frame or return
#' them as separate data frames in a list. Each data frame in the list is named after its respective CSV file.
#'
#' @param zip_dir Directory containing the ZIP files.
#' @param zip_pattern Pattern to match the ZIP file names.
#' @param csv_pattern Pattern to match the CSV file names inside the ZIP archives.
#' @param combine_vertically Logical, if TRUE, the function combines all CSV files vertically into a single data frame.
#' If FALSE, returns a list of data frames, each named after its corresponding CSV file.
#' @return Either a single combined data frame or a list of data frames, depending on the value of `combine_vertically`.
#' @import data.table
#' @importFrom tools file_path_sans_ext
#' @export
read_csv_from_zip <- function(zip_dir, zip_pattern, csv_pattern, combine_vertically = TRUE) {
  # List all ZIP files matching the pattern in the given directory
  zip_files <- list.files(zip_dir, pattern = paste0(zip_pattern, ".*\\.zip$"), full.names = TRUE)

  # Initialize an empty list to store data tables
  data_list <- list()

  # Process each ZIP file
  for (zip_file in zip_files) {
    # List contents of the ZIP file
    files_in_zip <- unzip(zip_file, list = TRUE)$Name

    # Find CSV files matching the pattern
    csv_files <- files_in_zip[grep(paste0("^", csv_pattern, ".*\\.csv$"), files_in_zip)]

    # Extract and read each matching CSV file
    for (csv_file in csv_files) {
      temp_dir <- tempdir()
      unzip(zip_file, files = csv_file, exdir = temp_dir)
      temp_file_path <- file.path(temp_dir, csv_file)
      data_frame_name <- tools::file_path_sans_ext(basename(csv_file))
      data_list[[data_frame_name]] <- data.table::fread(temp_file_path, header = TRUE)
      unlink(temp_file_path)
    }
  }

  # Process the data based on the combine_vertically parameter
  if (combine_vertically) {
    # Combine all data tables vertically
    combined_data <- data.table::rbindlist(data_list, use.names = TRUE, fill = TRUE)
    return(combined_data)
  } else {
    # Return named list of data frames
    return(data_list)
  }
}
