#' Process and Aggregate IIASA Data for GTAP SSP Integration
#'
#' This function executes the routine for processing and aggregating IIASA data for GTAP SSP integration. 
#' The routine includes data aggregation, interpolation (spline and beers methods), column expansion, 
#' filtering, and growth rate calculation. Optionally, the final dataset can be saved as a CSV file.
#'
#' @param aggTxtFile Character. Path to a Gempack-style text file used in GtapAgg2 for additional 
#' regional mappings. This file specifies the regional aggregation structure and is typically 
#' formatted as a GEMPACK text file. If `NULL`, no additional mapping is applied. Default is `NULL`.
#' @param outFile Character. Optional path to save the final dataset as a CSV file. If `NULL`, the 
#' file is not saved. Default is `NULL`.
#' @param group_cols Character vector. Columns to group by during aggregation. 
#' Default is `c("model", "scenario", "reg_gtap_code", "variable", "unit")`.
#'
#' @return A processed data frame containing the summarized and processed IIASA database.
#'
#' @details
#' **Steps in the Routine**:
#' \itemize{
#'   \item **Step 1: Data Aggregation**:
#'     Aggregates the IIASA raw data using the [gtapssp::aggData()] function, which allows for 
#'     regional mappings based on `aggTxtFile`. The aggregation groups the data by columns specified 
#'     in `group_cols` and combines regional data accordingly.
#'
#'   \item **Step 2: Spline Interpolation**:
#'     Applies the [gtapssp::interpolate_spline()] function to interpolate missing values in the 
#'     `value` column for the specified models (`"IIASA GDP 2023"`, `"OECD ENV-Growth 2023"`). 
#'     The cubic spline method creates a smooth curve that passes through the available data points, 
#'     ensuring continuity in derivatives and producing realistic interpolations.
#'
#'   \item **Step 3: Beers Interpolation**:
#'     Applies the [gtapssp::interpolate_beers()] function to interpolate missing population data 
#'     (`model = "IIASA-WiC POP 2023"`) using Beers interpolation. This method is specifically 
#'     designed for demographic data, providing age-structured estimates that align with population 
#'     distribution and totals. It preserves consistency between age groups while interpolating.
#'
#'   \item **Step 4: Combine Outputs**:
#'     Combines the results of the spline and beers interpolations. 
#'     This step stacks the interpolated data vertically to produce a unified dataset.
#'
#'   \item **Step 5: Expand Variables**:
#'     Splits the `variable` column into multiple columns (e.g., `variable`, `gender`, `cohort`, 
#'     and `education_level`). This expansion helps isolate 
#'     specific attributes encoded in the `variable` column.
#'
#'   \item **Step 6: Filter Data**:
#'     Filters rows based on several conditions:
#'     \itemize{
#'       \item Removes total rows (`education_level` is `NA`) unless the scenario is 
#'       `"Historical Reference"` or the cohort is among `Age 0-4`, `Age 5-9`, or `Age 10-14`.
#'     }
#'
#'   \item **Step 7: Calculate Growth Rates**:
#'     Uses [gtapssp::growth_rate()] to calculate annual growth rates for the `value` column. 
#'     Growth rates are computed as percentage changes between consecutive years within each group 
#'     specified in `group_cols`.
#'
#'   \item **Step 8: Save to File (Optional)**:
#'     If `outFile` is provided, saves the final processed dataset to a CSV file using.
#' }
#'
#' @seealso 
#' \link[gtapssp]{aggData}, 
#' \link[gtapssp]{interpolate_spline}, 
#' \link[gtapssp]{interpolate_beers}, 
#' \link[gtapssp]{growth_rate}
#'
#' @examples
#' \dontrun{
#' # Run the routine and save output to a CSV
#' final_data <- iiasa_gtap(
#'   aggTxtFile = "path/to/aggFile.agg",
#'   outFile = "path/to/output.csv"
#' )
#'
#' # Run the routine without saving
#' final_data <- iiasa_gtap(
#'   aggTxtFile = "path/to/aggFile.agg"
#' )
#' }
#'
#' @importFrom dplyr bind_rows filter mutate
#' @importFrom tidyr separate_wider_delim drop_na
#' @importFrom gtapssp aggData interpolate_spline interpolate_beers growth_rate
#' @importFrom data.table fwrite
#' @export
iiasa_gtap <- function(aggTxtFile = NULL, 
                       outFile = NULL, 
                       group_cols = c("model", "scenario", "reg_gtap_code", "variable", "unit")) {
  # Step 1: Data Aggregation
  agg_iiasa <- gtapssp::aggData(aggTxtFile = aggTxtFile, group_cols = group_cols)
  
  # Step 2: Spline Interpolation
  spline_out <- agg_iiasa |>
    tidyr::drop_na(model) |>
    dplyr::filter(model %in% c("IIASA GDP 2023", "OECD ENV-Growth 2023")) |>
    gtapssp::interpolate_spline(
      groups = group_cols,
      year = "year",
      values = "value"
    )
  
  # Step 3: Beers Interpolation
  beers_out <- agg_iiasa |>
    dplyr::filter(model %in% c("IIASA-WiC POP 2023")) |>
    gtapssp::interpolate_beers(
      groups = group_cols,
      year = "year",
      values = "value"
    )
  
  # Step 4: Combine Outputs
  gtap_ssp <- dplyr::bind_rows(beers_out, spline_out) |>
    tidyr::separate_wider_delim(
      cols = "variable",
      names = c("variable", "gender", "cohort", "education_level"),
      delim = "|",
      too_few = "align_start"
    )
  
  # Step 5: Filter Data
  gtap_ssp <- gtap_ssp |>
    dplyr::filter(
      model != "IIASA-WiC POP 2023" |
        !is.na(education_level) |
        scenario == "Historical Reference" |
        cohort %in% c("Age 0-4", "Age 5-9", "Age 10-14")
    )
  
  # Step 6: Calculate Growth Rates
  gtap_ssp <- gtapssp::growth_rate(data = gtap_ssp, group_cols = group_cols)
  
  # Step 7: Save to File (Optional)
  if (!is.null(outFile)) {
    data.table::fwrite(gtap_ssp, outFile)
  }
  
  # Return the final data frame
  return(gtap_ssp)
}
