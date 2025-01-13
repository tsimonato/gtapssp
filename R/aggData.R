#' Aggregate IIASA Data Using Regional Mappings
#'
#' This function aggregates IIASA data based on a specified regional correspondence table.
#' Optionally, it can use additional regional mappings from a Gempack-style text file to 
#' refine the correspondence table. The aggregated data is grouped by specified columns and years.
#'
#' @param iiasa_raw A list containing IIASA raw data, typically the output of the `updateData` function. 
#' Default is `gtapssp::iiasa_raw`.
#' @param corresp_reg A data frame containing the correspondence table between regions and their codes. 
#' Default is `gtapssp::corresp_reg`.
#' @param aggTxtFile Character. The path to a Gempack-style text file containing additional 
#' regional mappings. If `NULL`, this step is skipped. Default is `NULL`.
#' @param group_cols Character vector. The column names to use for grouping the aggregated data. 
#' Default is `c("model", "scenario", "reg_gtap_code", "variable", "unit")`.
#'
#' @return A data frame containing the aggregated IIASA data grouped by the specified columns 
#' and years. The aggregation sums up the `value` column for each group.
#'
#' @examples
#' \dontrun{
#' # Example with an additional mapping file
#' agg_data <- aggData(
#'   iiasa_raw = gtapssp::iiasa_raw,
#'   corresp_reg = gtapssp::corresp_reg,
#'   aggTxtFile = "path/to/aggFile.agg"
#' )
#'
#' # Example without an additional mapping file
#' agg_data <- aggData(
#'   iiasa_raw = gtapssp::iiasa_raw,
#'   corresp_reg = gtapssp::corresp_reg
#' )
#' }
#'
#' @seealso \link[gtapssp]{updateData}, \link[dplyr]{group_by}, \link[tidyr]{drop_na}
#'
#' @export
aggData <- function(iiasa_raw = gtapssp::iiasa_raw,
                    corresp_reg = gtapssp::corresp_reg,
                    aggTxtFile = NULL,
                    group_cols = c("model", "scenario", "reg_gtap_code", "variable", "unit")) {
  
  # Conditionally execute only if aggTxtFile is not NULL
  if (!is.null(aggTxtFile)) {
    # Load regional mapping data from the Gempack-style text file
    data_list <- gtapssp::txtToData(aggTxtFile)
    
    # Select either "Section 4" or "MREG" depending on availability
    selected_df <- if ("Section 4" %in% names(data_list)) {
      data_list$`Section 4`
    } else if ("MREG" %in% names(data_list)) {
      data_list$MREG
    } else {
      stop("Neither 'Section 4' nor 'MREG' found in the data list.")
    }
    
    # Rename the columns in the selected DataFrame for consistency
    names(selected_df) <- c("reg_gtap_code", "aggTxtNames")
    # Convert region codes to uppercase for matching
    selected_df$reg_gtap_code <- toupper(selected_df$reg_gtap_code)
    
    # Join the selected mapping data with the correspondence table
    corresp_reg <- corresp_reg  |>
      dplyr::left_join(selected_df, by = "reg_gtap_code") |> 
      dplyr::mutate(reg_gtap_code = aggTxtNames)
  }
  
  # Aggregate IIASA data based on the updated or original correspondence table
  agg_iiasa <- iiasa_raw$data |>
    # Rename the region column to match correspondence table
    dplyr::rename(cty_names = region) |>
    # Join with the correspondence table to map regions
    dplyr::right_join(corresp_reg, by = "cty_names" ) |>
    # Group by specified columns and year
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols)), year) |>
    # Summarize the data by summing up the "value" column
    dplyr::summarize(value = sum(value, na.rm = TRUE), .groups = "drop") |>
    # Drop rows where the "model" column is NA
    tidyr::drop_na(model)
  
  # Return the aggregated data
  return(agg_iiasa)
}
