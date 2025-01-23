# GTAPSSP: Tools for Processing SSPs in the GTAP Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)  
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
devtools::install_github("your-username/gtapssp")
```

## 🛠️ Key Features

### 1. **Data Aggregation**
Aggregate raw SSP data with regional mappings using the `aggData()` function:
```R
agg_data <- gtapssp::aggData(
  iiasa_raw = gtapssp::iiasa_raw,
  corresp_reg = gtapssp::corresp_reg,
  group_cols = c("model", "scenario", "reg_iso3", "variable", "unit")
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

## 🏗️ Workflow Overview

The pipeline involves the following steps:

```mermaid
| label: workflow-pipeline
| fig-width: 8 
| fig-height: 6 
graph TD

subgraph s1["Step 1"]
    R4[IIASA raw data] --> D[Summarise Data]
    R5[Regional correspondences] --> D[Summarise Data: gtapssp::aggData]
    D([Summarise Data])
    D --> E1([Interpolate GDP data: gtapssp::interpolate_spline])
    D --> E2([Interpolate POP data: gtapssp::interpolate_beers])
end

subgraph s2["Step 2"]
    E1 --> F([Expand data])
    E2 --> F
end

subgraph s3["Step 3"]
    F --> G([Join labels])
end

subgraph s4["Step 4"]
    G --> H([Cleaning data])
end

subgraph s5["Step 5"]
    H --> I([Preparing final output to export])
end

I --> K([.har file for GTAP])
```

## 🌐 Data Source

This package relies on projections from the **Shared Socioeconomic Pathways (SSPs)** developed by **IIASA**. The default dataset (`gtapssp::iiasa_raw`) can be updated using the `updateData()` function to fetch newer versions from the [IIASA SSP database](https://data.ece.iiasa.ac.at/ssp).

## 📦 Example Usage

```R
# Process data and save as .har file
gtapssp::iiasa_gtap(outFile = "gtap_ssp.har")
```

## 📚 Documentation

- [Package Manual](https://github.com/your-username/gtapssp/raw/main/docs/gtapssp_manual.pdf)
- Explore function-specific documentation using `?function_name` in R.

## 🤝 Contributions

We welcome contributions to enhance **GTAPSSP**! Feel free to:
- Open an [issue](https://github.com/your-username/gtapssp/issues) to report bugs or suggest features.
- Fork the repository and submit a pull request.

## 📝 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
