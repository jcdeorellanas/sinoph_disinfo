
#' Split data into training and testing data sets
#'
#' @param data a tibble or data.frame
#' @param y (optional) a target variable to be included in both data sets without missing data
#' @param p the fraction of the data to be included in the training set (default is 0.8)
#'
#' @return a list of two data.frames, with the names "train" and "test".
#' @export
#'
#' @examples
#' data_list <- data_split(mtcars)
#' data_list <- data_split(mtcars, mpg)
#'
data_split <- function(data, y, p = 0.8){
  
  if (!missing(y)){ data <- data |> drop_na({{ y }}) }
  
  x    <- 1:nrow(data)
  size <- p*nrow(data)
  
  index <- sample(x, size)
  
  df <- list()
  df$train = data[ index,] # Create the training data
  df$test  = data[-index,] # Create the test data
  
  return(df)
}


#' Create a list of sample data sets
#'
#' @param data the initial data frame or tibble
#' @param y (optional) a target variable to be included in all samples without missing data
#' @param samples how many samples to create. Default is 5.
#' @param p a percent telling how much smaller the samples should be relative to the initial data.
#'        Default is 0.8.
#' @param replace whether to sample with replacement when creating each sample. Default is FALSE.
#'
#' @return a list of data frames
#' @export
#'
#' @examples
#' data_list <- data_samples(mtcars)
#' data_list <- data_samples(mtcars, mpg)
#' data_list <- data_samples(mtcars, mpg, samples = 10)
#' data_list <- data_samples(mtcars, mpg, p = 0.5)
#'
data_samples <- function(data, y, samples = 5, p = 0.8, replace = FALSE){
  
  if (!missing(y)){ data <- data |> tidyr::drop_na({{ y }}) }
  
  x    <- 1:nrow(data)
  size <- p*nrow(data)
  
  df <- purrr::map(1:samples, 
                   ~data[sample(x, size, replace = replace),])
  names(df) <- paste0("sample", 1:samples)
  
  return(df)
}

