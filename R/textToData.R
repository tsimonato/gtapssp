#' Convert Gempack Text Files into a List of DataFrames
#'
#' This function reads a Gempack-style text file and converts its sections into a list of DataFrames.
#' Each section in the file is represented as a DataFrame, with rows and columns extracted based on the file's structure.
#'
#' @param file_path Character. The path to the Gempack text file to be processed.
#'
#' @return A named list of DataFrames. Each DataFrame corresponds to a section in the text file.
#' The names of the list elements represent the sections, and the DataFrames contain the rows and columns of data extracted from those sections.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' file_path <- "path_to_gempack_file.txt"  # Replace with the actual file path
#' section_dfs <- txtToData(file_path)
#'
#' # Accessing a specific section
#' head(section_dfs[["Section 3"]])  # Preview the DataFrame for a specific section
#' }
#'
#' @seealso \link[base]{readLines}, \link[base]{data.frame}
#'
#' @export
txtToData <- function(file_path) {
  # Read the file
  lines <- readLines(file_path)
  
  # Filter lines: Keep non-comment lines or lines starting with "! Section"
  lines <- lines[!grepl("^= = = = = =", lines) & !grepl("^!", lines) | grepl("^! Section ", lines)]
  
  # Initialize variables
  section_data <- list()  # List to store data for each section
  current_section <- NULL  # Track the current section
  section_lines <- character()  # Lines for the current section
  
  # Iterate through each line
  for (line in lines) {
    line <- trimws(line)  # Remove leading/trailing whitespace
    
    # Detect section markers
    if (grepl("^! Section", line)) {
      # If moving to a new section, save the previous section's lines
      if (!is.null(current_section)) {
        section_data[[current_section]] <- section_lines
      }
      
      # Start a new section
      current_section <- sub("^! ", "", line)  # Extract the section name
      section_lines <- character()  # Reset the lines for the new section
    } else {
      # Collect lines for the current section
      if (!is.null(current_section)) {
        section_lines <- c(section_lines, line)
      }
    }
  }
  
  # Save the last section's lines
  if (!is.null(current_section)) {
    section_data[[current_section]] <- section_lines
  }
  
  # Convert each section's lines into a DataFrame, splitting columns by "&"
  dfs <- lapply(section_data, function(lines) {
    if (length(lines) > 0) {
      # Split lines into columns using "&" as a delimiter
      lines_split <- strsplit(lines, "\\s*&\\s*")  # Split by " & ", trimming spaces
      max_cols <- max(lengths(lines_split))  # Get the maximum number of columns
      df <- do.call(rbind, lapply(lines_split, function(x) {
        length(x) <- max_cols  # Pad missing columns with NA
        x
      }))
      df <- as.data.frame(df, stringsAsFactors = FALSE)
      colnames(df) <- paste0("Column", seq_len(ncol(df)))  # Name columns as "Column1", "Column2", ...
      return(df)
    } else {
      return(data.frame())  # Return an empty DataFrame if no lines
    }
  })
  
  return(dfs)
}
