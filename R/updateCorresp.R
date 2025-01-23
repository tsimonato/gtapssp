#' Update Country Correspondence Data with IIASA Regions
#'
#' This function processes and updates a correspondence table between country names
#' and their ISO3 codes using data from the IIASA raw dataset and an existing correspondence
#' table. It cleans the region names, standardizes country names, and ensures alignment
#' with the ISO3 standard. The updated correspondence data can either be saved to a file
#' or returned directly.
#'
#' @param iiasa_raw A list containing IIASA raw data, typically the output of the `updateData` function.
#' Default is `gtapssp::iiasa_raw`.
#' @param corresp_reg A data frame containing the existing correspondence table, typically
#' `gtapssp::corresp_reg`. This table is merged with the processed IIASA region data.
#' @param outputFile Character. Optional. The file path where the updated correspondence data will be saved.
#' If `NULL`, the data will not be saved but returned instead. Default is `NULL`.
#'
#' @return If `outputFile` is `NULL`, returns a data frame with the updated correspondence data. 
#' Otherwise, saves the data to the specified file and invisibly returns `NULL`.
#'
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Extracts unique region names from the `iiasa_raw` dataset.
#'   \item Cleans and standardizes country names, removing invalid entries such as "World" and entries with parentheses.
#'   \item Handles specific name corrections, such as replacing "Micronesia" with "Federated States of Micronesia".
#'   \item Maps country names to their ISO3 codes using the `countrycode` package.
#'   \item Merges the cleaned IIASA region data with the existing correspondence table (`corresp_reg`).
#'   \item Optionally saves the final updated correspondence data to the specified file.
#' }
#'
#' @examples
#' \dontrun{
#' # Update correspondence data and save it to a file
#' updateCorresp(
#'   iiasa_raw = gtapssp::iiasa_raw,
#'   corresp_reg = gtapssp::corresp_reg,
#'   outputFile = "data/corresp_iiasa_updated.rda"
#' )
#'
#' # Update correspondence data and return it directly
#' updated_data <- updateCorresp(
#'   iiasa_raw = gtapssp::iiasa_raw,
#'   corresp_reg = gtapssp::corresp_reg
#' )
#' }
#'
#' @seealso \link[countrycode]{countrycode}, \link[dplyr]{filter}, \link[dplyr]{mutate}, \link[dplyr]{right_join}
#'
#' @importFrom dplyr filter mutate right_join
#' @importFrom countrycode countrycode
#' @export
updateCorresp <- function(iiasa_raw = gtapssp::iiasa_raw,
                          corresp_reg = gtapssp::corresp_reg,
                          outputFile = NULL) {
  
  # Extract and clean country names
  cty_names <- unique(iiasa_raw$data$region)
  cty_names <- cty_names[!grepl("\\(.*\\)", cty_names)]
  cty_names <- cty_names[cty_names != "World"]
  cty_names[cty_names == "Micronesia"] <- "Federated States of Micronesia"
  
  # Create a table with country names and ISO3 codes
  iiasa_iso3 <- data.frame(cty_names = cty_names)
  iiasa_iso3$reg_iso3 <- countrycode::countrycode(
    iiasa_iso3$cty_names,
    origin = "country.name",
    destination = "iso3c"
  )
  iiasa_iso3 <- unique(iiasa_iso3)
  
  # Alternatively, using pipes (%>%)
  iiasa_iso3 <- iiasa_raw$data$region |> 
    unique() |> 
    data.frame(cty_names = _) |> 
    dplyr::filter(!grepl("\\(.*\\)", cty_names), cty_names != "World") |> 
    dplyr::mutate(
      cty_names = ifelse(cty_names == "Micronesia", 
                         "Federated States of Micronesia", 
                         cty_names),
      reg_iso3 = countrycode::countrycode(
        cty_names, 
        origin = "country.name", 
        destination = "iso3c"
      )
    ) |> 
    unique()
  
  # Merge with the existing correspondence table
  corresp_reg <- corresp_reg |> 
    dplyr::right_join(iiasa_iso3)
  
  # Save the updated correspondence data if outputFile is provided
  if (!is.null(outputFile)) {
    save(corresp_reg, file = outputFile)
    message(paste("Data successfully saved to:", outputFile))
    return(invisible(NULL))
  }
  
  # Return the updated correspondence data
  return(corresp_reg)
}
