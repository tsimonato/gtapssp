#' Calculate Growth Rate by Year for Specified Groups
#'
#' This function calculates the growth rate of a specified value column grouped by specified columns 
#' in the data. The growth rate is computed as the percentage change between consecutive years 
#' within each group. Missing growth rates (`NA`) are replaced with a user-defined value.
#'
#' @param data A data frame containing the input data for which growth rates are to be calculated.
#' @param group_cols A character vector specifying the columns to group by before calculating the growth rate.
#' Default is `c("model", "scenario", "reg_gtap_code", "variable", "unit")`.
#' @param year_col A string specifying the column representing the year. Default is `"year"`.
#' @param value_col A string specifying the column containing the values for which growth rates are calculated.
#' Default is `"value"`.
#' @param growth_rate_col A string specifying the name of the new column where the calculated growth rates will be stored.
#' Default is `"growth_rate"`.
#' @param na_replace A numeric value used to replace missing growth rates (`NA`). Default is `0`.
#'
#' @return A data frame containing the original data with an additional column, representing 
#' the calculated growth rates as percentage changes.
#'
#' @importFrom dplyr group_by across arrange mutate ungroup lag
#' @importFrom rlang sym
#'
#' @examples
#' \dontrun{
#' # Example usage
#' growth_rates <- growth_rate(
#'   data = my_data,
#'   group_cols = c("model", "scenario", "reg_gtap_code", "variable", "unit"),
#'   year_col = "year",
#'   value_col = "value",
#'   growth_rate_col = "annual_growth_rate"
#' )
#' }
#'
#' @seealso \link[dplyr]{mutate}, \link[dplyr]{group_by}, \link[dplyr]{arrange}
#'
#' @export
growth_rate <- function(data, 
                        group_cols = c("model", "scenario", "reg_gtap_code", "variable", "unit"), 
                        year_col = "year", 
                        value_col = "value",
                        growth_rate_col = "growth_rate",
                        na_replace = 0) {
  # Group by the specified columns
  data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) |>
    
    # Arrange the data by year within each group
    dplyr::arrange(.by_group = TRUE) |>
    
    # Calculate the growth rate as percentage change between consecutive years
    dplyr::mutate(
      {{ growth_rate_col }} := 
        100 * ((!!rlang::sym(value_col) - dplyr::lag(!!rlang::sym(value_col))) /
                 dplyr::lag(!!rlang::sym(value_col)))
    ) |>
    
    # Replace missing growth rates (NA) with the specified replacement value
    dplyr::mutate({{ growth_rate_col }} := ifelse(is.na(!!rlang::sym(growth_rate_col)), 0 , !!rlang::sym(growth_rate_col))) |> 
    
    # Ungroup the data to remove grouping structure after calculations
    dplyr::ungroup()
}
