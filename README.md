# GTAPSSP: SSPs for GTAP Framework ☕

<!-- badges: start -->
[![R-CMD-check](https://github.com/tsimonato/gtapssp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tsimonato/gtapssp/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Website](https://img.shields.io/website-up-down-green-red/http/shields.io.svg)](https://tsimonato.github.io/gtapssp/)
<!-- badges: end -->


A comprehensive R package designed to preprocess, aggregate, interpolate, and expand **Shared Socioeconomic Pathways (SSPs)** data for seamless integration with the **Global Trade Analysis Project (GTAP)** framework.

## 📖 Overview

The **`gtapssp`** package simplifies the processing of SSP data by offering:

- Tools for **data aggregation** using regional mappings.
- Robust **interpolation methods**:
  - **Cubic Spline Interpolation** for GDP and related variables.
  - **Beers Interpolation** for population data, ideal for age-cohort structures.
- Utilities for **label standardization** and **variable expansion**.
- Support for generating outputs in `.har` format for GTAP or as `.csv`.

This package is tailored for researchers and policymakers working with GTAP and SSP data, providing a streamlined workflow from raw SSP data to GTAP-compatible outputs.

## 🚀 Installation

To install the development version of `gtapssp` from GitHub:

```R
# Install devtools if not already installed
install.packages("devtools")

# Install gtapssp from GitHub
devtools::install_github("tsimonato/gtapssp")
```

## 🛠️ Key Features

### 1. **Data Aggregation**
Aggregate raw SSP data with regional mappings using the `aggData()` function:
```R
agg_data <- gtapssp::aggData(
  iiasa_raw = gtapssp::iiasa_raw,
  corresp_reg = gtapssp::corresp_reg
)
```

### 2. **Interpolation**
#### Spline Interpolation
Smoothly fill gaps in GDP-related data:
```R
spline_out <- gtapssp::interpolate_spline(
  input_df = agg_data,
  groups = c("model", "scenario", "reg_iso3"),
  year = "year",
  values = "value"
)
```

#### Beers Interpolation
Interpolate population data using the Beers method:
```R
beers_out <- gtapssp::interpolate_beers(
  input_df = agg_data,
  groups = c("model", "scenario", "reg_iso3"),
  year = "year",
  values = "value"
)
```

### 3. **Output Preparation**
Combine interpolated datasets, expand scenarios, and prepare outputs:
```R
final_data <- gtapssp::iiasa_gtap(outFile = "gtap_ssp.har")
```

## 🌐 Data Source

This package relies on projections from the **Shared Socioeconomic Pathways (SSPs)** developed by **IIASA**. The default dataset (`gtapssp::iiasa_raw`) can be updated using the `updateData()` function to fetch newer versions from the [IIASA SSP database](https://data.ece.iiasa.ac.at/ssp).

## 📦 One-Line Workflow

The gtapssp::iiasa_gtap() function provides a one-liner to execute the entire SSP data processing pipeline. This includes data aggregation, interpolation, expansion, label standardization, and optional export to .har or .csv formats.

```R
gtapssp::iiasa_gtap(outFile = "gtap_ssp.har")
```

## 📚 Documentation

- [Package Manual](https://github.com/tsimonato/gtapssp/blob/master/docs/gtapssp_0.0.0.9000.pdf)
- [Tutorial and Examples](https://tsimonato.github.io/gtapssp/)

## 🤝 Contributions

We welcome contributions to enhance **GTAPSSP** and feel free to:
- Open an [issue](https://github.com/tsimonato/gtapssp/issues) to report bugs or suggest features.
- Fork the repository and submit a pull request.

## 📝 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
