#' IIASA Raw Data
#'
#' A dataset containing raw projections of socioeconomic pathways (SSPs) provided by IIASA.
#'
#' @format A list containing multiple components:
#' \describe{
#'   \item{\code{index}}{A pointer or metadata structure (if applicable).}
#'   \item{\code{data}}{A data frame with projections and the following variables:
#'     \describe{
#'       \item{\code{model}}{The name of the model used for projections (e.g., "IIASA GDP 2023").}
#'       \item{\code{scenario}}{The scenario associated with the data (e.g., "SSP2").}
#'       \item{\code{region}}{The region or country associated with the data (e.g., "Africa (R10)").}
#'       \item{\code{variable}}{The variable being projected (e.g., "GDP|PPP").}
#'       \item{\code{unit}}{The unit of measurement for the variable (e.g., "billion USD_2017/yr").}
#'       \item{\code{year}}{The year of the projection.}
#'       \item{\code{value}}{The projected value for the variable.}
#'     }
#'   }
#'   \item{\code{meta}}{Metadata for the dataset, such as descriptions, references, and DOIs.}
#'   \item{\code{region}}{A vector of all regions covered in the dataset.}
#'   \item{\code{variable}}{A vector of all variables included in the projections.}
#'   \item{\code{unit}}{A vector of all units used in the dataset.}
#'   \item{\code{year}}{A vector of all years included in the projections.}
#' }
#' @source Data provided by IIASA. Refer to the original DOI: https://doi.org/10.5281/zenodo.10618931.
"iiasa_raw"

#' ISO Country List
#'
#' A dataset containing ISO country codes and their corresponding details.
#'
#' @format A data frame with 2 variables:
#' \describe{
#'   \item{\code{Region}}{The full name of the country or region.}
#'   \item{\code{iso}}{ISO 3-letter country code.}
#' }
#' @source Internal package data.
"isoList"

#' Education Level Dictionary
#'
#' A dataset providing codes and labels for education levels used in the package.
#'
#' @format A data frame with 7 rows and 2 variables:
#' \describe{
#'   \item{\code{education_level}}{The full label of the education level (e.g., "Primary Education", "No Education").}
#'   \item{\code{educ}}{The abbreviated code for the education level (e.g., "PRIM", "NONE").}
#' }
#' @source Internal package data.
"educDict"

#' Cohort Dictionary
#'
#' A dataset defining age cohorts and their corresponding metadata.
#'
#' @format A data frame with 3 variables:
#' \describe{
#'   \item{\code{cohort}}{Name of the cohort (e.g., "Age 0-4").}
#'   \item{\code{age}}{Broad age group for the cohort (e.g., "PLT14" or "P65UP").}
#'   \item{\code{age_disagg}}{Disaggregated age group code for the cohort (e.g., "P0004").}
#' }
#' @source Internal package data.
"cohortDict"

#' Gender Dictionary
#'
#' A dataset mapping gender codes to their respective descriptions.
#'
#' @format A data frame with 2 variables:
#' \describe{
#'   \item{\code{gender_code}}{Code representing gender (e.g., "MALE" for male, "FEML" for female).}
#'   \item{\code{gender}}{Description of the gender (e.g., "Male", "Female").}
#' }
#' @source Internal package data.
"genderDict"

#' Regional Correspondence (Predefined)
#'
#' A dataset mapping predefined regions to their corresponding metadata.
#'
#' @format A data frame with 5 variables:
#' \describe{
#'   \item{\code{reg_gtap_number}}{Numeric identifier for the GTAP region.}
#'   \item{\code{reg_iso3}}{ISO 3-letter code for the region.}
#'   \item{\code{reg_gtap_code}}{GTAP-specific code for the region.}
#'   \item{\code{reg_gtap_name}}{GTAP-specific name for the region.}
#'   \item{\code{country_gtap_name}}{Country name associated with the GTAP region.}
#' }
#' @source Internal package data.
"corresp_reg_pre"

#' Regional Correspondence
#'
#' A dataset mapping predefined regions to their corresponding metadata.
#'
#' @format A data frame with 6 variables:
#' \describe{
#'   \item{\code{reg_gtap_number}}{Numeric identifier for the GTAP region.}
#'   \item{\code{reg_iso3}}{ISO 3-letter code for the region.}
#'   \item{\code{reg_gtap_code}}{GTAP-specific code for the region.}
#'   \item{\code{reg_gtap_name}}{GTAP-specific name for the region.}
#'   \item{\code{country_gtap_name}}{Full country name as per GTAP conventions.}
#'   \item{\code{cty_names}}{Country names that are aggregated into the GTAP regions.}
#' }
#' @source Internal package data.
"corresp_reg"

