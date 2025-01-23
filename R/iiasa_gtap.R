#' Process and Aggregate IIASA Data for GTAP SSP Integration
#'
#' This function executes the routine for processing and aggregating IIASA data for GTAP SSP integration. 
#' The routine includes data aggregation, interpolation (spline and beers methods), column expansion, 
#' filtering, and growth rate calculation. Optionally, the final dataset can be saved as a CSV file.
#'
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
#'     If `outFile` is provided, saves the final processed dataset to a .HAR or .CSV file
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
#' # Run the routine and save output to a HAR
#' final_data <- gtapssp::iiasa_gtap(
#'   outFile = "path/to/output.har"
#' )
#' 
#' # Run the routine and save output to a CSV
#' final_data <- gtapssp::iiasa_gtap(
#'   outFile = "path/to/output.csv"
#' )
#'
#' # Run the routine without saving
#' final_data <- gtapssp::iiasa_gtap()
#' }
#'
#' @importFrom dplyr bind_rows filter mutate case_when distinct anti_join left_join select rename
#' @importFrom tidyr separate_wider_delim drop_na expand_grid complete replace_na
#' @importFrom gtapssp aggData interpolate_spline interpolate_beers growth_rate
#' @importFrom data.table fwrite
#' @export
iiasa_gtap <- function(outFile = NULL, 
                       group_cols = c("model", "scenario", "reg_iso3", "variable", "unit")) {
  
  # Aggregate raw data
  agg_iiasa <- gtapssp::aggData(
    iiasa_raw = gtapssp::iiasa_raw,
    group_cols = group_cols
  )
  
  # Interpolate with spline method
  spline_out <- agg_iiasa |>
    tidyr::drop_na(model) |>
    dplyr::filter(model %in% c("IIASA GDP 2023", "OECD ENV-Growth 2023")) |>
    gtapssp::interpolate_spline(
      groups = group_cols,
      year = "year",
      values = "value"
    )
  
  # Interpolate with beers method
  beers_out <- agg_iiasa |>
    dplyr::filter(model %in% c("IIASA-WiC POP 2023")) |>
    dplyr::filter(!grepl("^Mean Years of Education", variable)) |>
    gtapssp::interpolate_beers(
      groups = group_cols,
      year = "year",
      values = "value"
    )
  
  beers_out <- beers_out |>
    tidyr::separate_wider_delim(
      cols = "variable", # <1> Specify the column to be split.
      names = c("variable", "gender_code", "cohort", "education_level"), # <2> Define the new column names.
      delim = "|", # <3> Use "|" as the delimiter to separate values in the "variable" column.
      too_few = "align_start" # <4> Align the resulting values from the split to the start of the new columns if there are fewer parts than columns.
    )
  
  # Combine the outputs of GDP and Population data
  gtap_ssp <- dplyr::bind_rows(beers_out, spline_out)
  
  # Expand scenarios
  exp_hist <- gtap_ssp |>
    dplyr::filter(scenario == "Historical Reference") |> 
    dplyr::select(-scenario) |>                   
    tidyr::expand_grid(scenario = unique(gtap_ssp$scenario))
  
  # Merge expanded scenarios
  gtap_ssp <- gtap_ssp |>
    dplyr::anti_join(dplyr::select(exp_hist, -value)) |>
    dplyr::bind_rows(exp_hist) |>
    dplyr::filter(scenario != "Historical Reference") 
  
  # Extract unique combinations of columns excluding 'scenario', 'reg_iso3', 'year', and 'value'.
  # These columns are assumed to represent unique group identifiers for the dataset.
  unique_groups <- gtap_ssp |>
    dplyr::select(-c(scenario, reg_iso3, year, value)) |>
    dplyr::distinct()  # Retain only distinct rows to define unique group combinations.
  
  # Expand the dataset to include all possible combinations of unique groups with regions, years, and scenarios.
  complete_data <- unique_groups |>
    tidyr::expand_grid(reg_iso3 = unique(gtapssp::corresp_reg$reg_iso3)) |> # Add all unique region ISO codes.
    tidyr::expand_grid(year = unique(gtap_ssp$year)) |># Add all unique years in the dataset.
    tidyr::expand_grid(scenario = unique(gtap_ssp$scenario))# Add all unique SSP scenarios.
  
  # Ensure that all combinations of groups, regions, years, and scenarios exist in the final dataset.
  # Any missing combinations will be filled with default values.
  gtap_ssp <- complete_data |>
    dplyr::left_join(
      gtap_ssp, 
      by = c(names(unique_groups), "scenario", "reg_iso3", "year")  # Merge by all relevant keys.
    ) |>
    dplyr::mutate(value = tidyr::replace_na(value, 0))  # Replace any missing values in the 'value' column with 0.
  
  # Merge the auxiliary datasets with the main dataset (gtap_ssp)
  gtap_ssp <- 
    gtap_ssp |>
    # Integrate educational level labels
    dplyr::left_join(gtapssp::educDict, by = dplyr::join_by(education_level)) |>
    # Integrate cohort labels
    dplyr::left_join(gtapssp::cohortDict, by = dplyr::join_by(cohort)) |>
    # Integrate gender labels
    dplyr::left_join(gtapssp::genderDict, by = dplyr::join_by(gender_code))
  
  
  gtap_ssp <- 
    gtap_ssp |>
    dplyr::mutate(
      MOD = model,                  # Rename 'model' to 'MOD'
      VAR = variable,               # Rename 'variable' to 'VAR'
      SCE = scenario,               # Rename 'scenario' to 'SCE'
      ISO = reg_iso3,               # Rename 'reg_iso3' to 'ISO'
      GND = gender,                 # Rename 'gender' to 'GND'
      AGE = age,                    # Rename 'age' to 'AGE'
      YRS = paste0("Y", year),      # Add "Y" prefix to 'year'
      POP = value,                  # Rename 'value' to 'POP'
      .keep = "none"                # Keep only the newly defined variables
    )
  
  gtap_ssp <- 
    gtap_ssp |>
    dplyr::mutate(
      GND = tidyr::replace_na(GND, "TOTL"), # Replace NA in gender with "TOTL" (Total)
      AGE = tidyr::replace_na(AGE, "TOTL") # Replace NA in age with "TOTL" (Total)
    )
  
  gtap_ssp <- gtap_ssp |>
    # Modify and transform existing variables using dplyr::mutate
    dplyr::mutate(
      # Reclassify the values of the 'variable' column into a new variable 'VAR'
      VAR = dplyr::case_when(
        VAR == "GDP|PPP" ~ "GDP_PPP",                # Replace "GDP|PPP" with "GDP_PPP"
        VAR == "GDP|PPP [per capita]" ~ "GDP_PER_CAPI",  # Replace "GDP|PPP [per capita]" with "GDP_PER_CAPI"
        TRUE ~ VAR                                    # Retain the original values for all other cases
      ),
      # Adjust the values in the 'value' column for GDP_PPP by multiplying by 1000
      POP = ifelse(
        VAR == "GDP_PPP",    # Check if the 'VAR' column equals "GDP_PPP"
        POP * 1000,        # Multiply the value by 1000 to adjust the unit for absolute values
        POP                # Keep the value unchanged for other cases
      )
    )

  # Step 7: Save to File (Optional)
  if (!is.null(outFile)) {
    
    if (grepl(".csv$", outFile)) {
      data.table::fwrite(gtap_ssp, outFile)
      
    } else if (grepl(".har$", outFile)) {
      # Prepare population (POP) dataset
      POP <- gtap_ssp |>
        dplyr::filter(MOD == "IIASA-WiC POP 2023") |> # Select population model
        dplyr::filter(GND != "TOTL") |> # Exclude total gender records
        dplyr::group_by(SCE, ISO, GND, YRS, AGE) |> # Group by scenario, ISO, gender, year, and age
        dplyr::summarise(POP = sum(POP, na.rm = T)) # Sum population values, handling missing data

      # Prepare GDP projections (GDPI)
      GDPI <- gtap_ssp |>
        tidyr::complete(MOD, VAR, SCE, ISO, YRS, fill = list(POP = 0)) |> # Ensure all combinations exist with default values
        dplyr::filter(MOD == "IIASA GDP 2023") |> # Select IIASA GDP projections model
        dplyr::filter(VAR != "Population") |> # Exclude population variables
        dplyr::group_by(VAR, SCE, ISO, YRS) |> # Group by variable, scenario, ISO, and year
        dplyr::summarise(GDPI = sum(POP, na.rm = T)) # Sum GDP values, handling missing data

      # Prepare GDP from OECD ENV-Growth dataset (GDPO)
      GDPO <- gtap_ssp |>
        dplyr::filter(MOD == "OECD ENV-Growth 2023") |> # Select GDP from OECD ENV-Growth dataset
        dplyr::group_by(VAR, SCE, ISO, YRS) |> # Group by variable, scenario, ISO, and year
        dplyr::summarise(GDPO = sum(POP, na.rm = T)) # Sum GDP values, handling missing data

      # Combine datasets into arrays
      data <- list(
        POP = array(
          POP |> dplyr::pull(POP), # Extract population values
          dim = rev(sapply(POP |> dplyr::select(-POP), function(x) length(unique(x)))), # Define dimensions
          dimnames = rev(lapply(POP |> dplyr::select(-POP), function(x) unique(x))) # Define dimension names
        ) |> aperm(rev(1:(length(POP) - 1))), # Adjust dimension order

        GDPI = array(
          GDPI |> dplyr::pull(GDPI), # Extract GDP values (IIASA)
          dim = rev(sapply(GDPI |> dplyr::select(-GDPI), function(x) length(unique(x)))), # Define dimensions
          dimnames = rev(lapply(GDPI |> dplyr::select(-GDPI), function(x) unique(x))) # Define dimension names
        ) |> aperm(rev(1:(length(GDPI) - 1))), # Adjust dimension order

        GDPO = array(
          GDPO |> dplyr::pull(GDPO), # Extract GDP values (OECD)
          dim = rev(sapply(GDPO |> dplyr::select(-GDPO), function(x) length(unique(x)))), # Define dimensions
          dimnames = rev(lapply(GDPO |> dplyr::select(-GDPO), function(x) unique(x))) # Define dimension names
        ) |> aperm(rev(1:(length(GDPO) - 1))) # Adjust dimension order
      )

      # Add descriptive metadata to arrays
      attr(data$POP, "description") <- "IIASA-WiC POP 2023 (million people)" # Population description
      attr(data$GDPI, "description") <- "IIASA GDP 2023 (USD_2017/yr)" # GDP projections description
      attr(data$GDPO, "description") <- "OECD ENV-Growth 2023 (USD_2017/yr)" # OECD GDP description

      # Export datasets to a .har file
      HARr::write_har(data, outFile)
      
    } else {
      stop("Unsupported outFile format. Please especify a .har or .csv extension.")
    }
    
  }
  
  # Return the final data frame
  return(gtap_ssp)
}
