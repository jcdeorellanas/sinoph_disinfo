Mode <- function(x, digits = 2){
  values <- unique(na.omit(x))
  result <- values[match(x, values) |> tabulate() |> which.max()]
  
  if (is.numeric(result)) {result <- round(result, digits = digits)}
  
  return(result)
}

num_x <- function(x){
  
  if (is.numeric(x)) {
    y <- na.omit(x)
    if (length(y) == 0) { y <- NA }
  } else {
    y <- NA
  }
  
  return(y)
  
}

data_summary <- function(df, out = "view", digits = 2){
  
  summary_df <- tibble::tibble(
      Variable    = iconv(names(df)),
      Description = purrr::map_chr(df, ~ifelse(!is.null(attr(.x, "label")), iconv(attr(.x, "label")), "")),
      Obs.        = purrr::map_dbl(df, ~sum(!is.na(.x))),
      Missing     = purrr::map_dbl(df, ~sum( is.na(.x))),
      Type        = purrr::map_chr(df, ~first(class(.x))),
      Mean        = purrr::map_dbl(df, ~mean    (num_x(.x))),
      Median      = purrr::map_dbl(df, ~median  (num_x(.x))),
      Mode        = purrr::map_chr(df, ~as.character(Mode(.x, digits))),
      Std.Dev.    = purrr::map_dbl(df, ~sd      (num_x(.x))),
      Min         = purrr::map_dbl(df, ~min     (num_x(.x))),
      Max         = purrr::map_dbl(df, ~max     (num_x(.x))),
      Skewness    = purrr::map_dbl(df, ~moments::skewness(num_x(.x))),
      Kurtosis    = purrr::map_dbl(df, ~moments::kurtosis(num_x(.x)))
    ) %>%
      dplyr::mutate_if(is.numeric, ~round(.x, digits))
    
  if (out == "view"){
    summary_df %>%
        reactable::reactable(
          searchable = TRUE,
          showSortable = TRUE,
          showSortIcon = TRUE,
          rownames = FALSE,
          pagination = TRUE,
          resizable = TRUE,
          showPageSizeOptions = TRUE,
          compact = TRUE
        )
  } else {
    return(summary_df)
  }
  
}


