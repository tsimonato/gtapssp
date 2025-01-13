#' Update Data from IIASA Using `pyam`
#'
#' This function reads and processes data from the IIASA database using the Python
#' `pyam` package. It validates the Python environment, configures the appropriate
#' Python executable or Conda environment, and ensures the required Python module
#' is available. The resulting data is saved as a `.rda` file.
#'
#' **Note:** Downloading the database from IIASA may take several minutes depending on
#' the size of the database and the speed of the connection.
#'
#' @param pythonExePath Character. Path to the Python executable. If `NULL`, the function
#' will attempt to use a Conda environment specified by `condaenv`. Default is `NULL`.
#' @param condaenv Logical. If `TRUE`, the function will use a Conda environment named
#' "base" if `pythonExePath` is not provided. Default is `TRUE`.
#' @param outputFile Character. Path where the processed data will be saved as a `.rda` file.
#' Default is `"data/iiasa_raw.rda"`.
#'
#' @return A list containing the processed IIASA data:
#' \describe{
#'   \item{index}{Indices of the IamDataFrame.}
#'   \item{data}{Time series data.}
#'   \item{meta}{Metadata.}
#'   \item{region}{Regions.}
#'   \item{variable}{Variables.}
#'   \item{unit}{Units.}
#'   \item{year}{Years.}
#' }
#' The data is also saved to the specified output file.
#'
#' @examples
#' \dontrun{
#' # Using a specific Python executable
#' updateData(pythonExePath = "C:/path/to/python.exe", outputFile = "data/iiasa_raw.rda")
#'
#' # Using the default Conda environment
#' updateData(condaenv = TRUE, outputFile = "data/iiasa_raw.rda")
#' }
#'
#' @details
#' This function requires the `pyam` Python package to be installed in the specified
#' Python or Conda environment. Ensure that the Python environment is correctly set up
#' before calling the function. Downloading the IIASA database may take several minutes.
#'
#' @seealso \link[reticulate]{use_python}, \link[reticulate]{use_condaenv}, \link[reticulate]{py_config}, \link[reticulate]{import}
#'
#' @import reticulate
#' @export
updateData <- function(pythonExePath = NULL, condaenv = TRUE, outputFile = "data/iiasa_raw.rda") {
  # Configurar o ambiente Python
  if (!is.null(pythonExePath)) {
    if (file.exists(pythonExePath)) {
      reticulate::use_python(pythonExePath, required = TRUE)
    } else {
      stop("The specified path to the Python executable does not exist. Check the 'pythonExePath' argument.")
    }
  } else if (condaenv) {
    reticulate::use_condaenv("base", required = TRUE) # Define o ambiente Conda padrão como "base"
  }
  
  # Verificar se o ambiente Python foi configurado corretamente
  tryCatch({
    reticulate::py_config()
  }, error = function(e) {
    stop("Failed to configure Python. Check the Python path or Conda environment setup.")
  })
  
  # Importar o módulo pyam
  tryCatch({
    pyam <- reticulate::import("pyam", convert = TRUE)
  }, error = function(e) {
    stop("Error importing the 'pyam' module. Ensure it is installed in the configured Python environment.")
  })
  
  # Aviso sobre o tempo de download
  message("Downloading data from IIASA. This may take several minutes, please be patient...")
  
  # Ler dados do IIASA usando pyam
  tryCatch({
    df_py <- pyam$read_iiasa("ssp")
  }, error = function(e) {
    stop("Error reading data from IIASA. Check the connection and the database format.")
  })
  
  # Estruturar os dados em uma lista
  iiasa_raw <- list(
    index = df_py$index,
    data = df_py$data,
    meta = df_py$meta,
    region = df_py$region,
    variable = df_py$variable,
    unit = df_py$unit,
    year = df_py$year
  )
  
  # Verificar e criar o diretório de destino, se necessário
  dir.create(dirname(outputFile), showWarnings = FALSE, recursive = TRUE)
  
  # Salvar os dados em um arquivo .rda
  tryCatch({
    save(iiasa_raw, file = outputFile, compress = "xz")
    message(paste("Data successfully saved to:", outputFile))
  }, error = function(e) {
    stop("Error saving the file. Check the path or write permissions.")
  })
  
  return(iiasa_raw)
}
