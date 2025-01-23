#' Save CSV Files as RDA Objects
#'
#' This function reads all `.csv` files in a specified folder, converts each into
#' a data frame, and saves them as `.rda` files in the same folder. The name of
#' each saved object matches the name of its source `.csv` file (without the extension).
#'
#' @param data_folder A character string specifying the path to the folder containing `.csv` files. Defaults to "data/".
#' @return NULL. The function performs file operations and saves `.rda` files but does not return any value.
#' @examples
#' \dontrun{
#'   csvtorda("data/") # Save all .csv files in the "data/" folder as .rda
#' }
#' @export
csvtorda <- function(data_folder = "data/") {
  # List all .csv files in the specified folder
  csv_files <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
  
  # Check if there are any .csv files in the folder
  if (length(csv_files) == 0) {
    message("No .csv files found in the specified folder.")
    return(NULL)
  }
  
  # Ensure the output directory exists
  if (!dir.exists(data_folder)) {
    stop("The specified folder does not exist.")
  }
  
  # Process each .csv file
  for (csv_file in csv_files) {
    # Read the .csv file into a data frame
    data <- read.csv(csv_file, na.strings = "")
    
    # Extract the file name without extension
    object_name <- tools::file_path_sans_ext(basename(csv_file))
    
    # Assign the data frame to a variable with the same name as the file
    assign(object_name, data)
    
    # Save the object as an .rda file
    save(list = object_name, file = file.path(data_folder, paste0(object_name, ".rda")), compress = "xz")
    
    # Notify the user of the saved object
    message(paste("Saved:", object_name, "as .rda"))
  }
  
  # Completion message
  message("All .csv files have been processed and saved as .rda.")
}
