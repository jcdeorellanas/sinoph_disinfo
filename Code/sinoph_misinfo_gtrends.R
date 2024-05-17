# install.packages("tidyverse")
# install.packages("tidyr")
# install.packages("ggrepel")

library(tidyverse)
library(tidyr)
library(ggrepel)


# 1. This code opens .csv files containing data downloaded fro Google Trends, removes
# columns don't be used in the analysis, converts dates from UNIX to `Date` format,
# and changes that dataframe shape so it can be plotted with ggplot as time series.
# 2. In the next step, it plots 5 line charts that show the correlation between the dates
# in which the disinformation videos were released and peaks in searches related with
# the COVID-19 vaccine in Peru and its efficacy. It also plots a final graph that put
# searches in perspective showing big trendy topics and the search of for the COVID 
# vaccine (vacuna covid). 'vacuna covid' is used a the control variable across searches


df1 <- rio::import("data/google_trends/interest_over_time_df1.csv") |>
  select(-isPartial) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")

df2 <- rio::import("data/google_trends/interest_over_time_df2.csv") |>
  select(-isPartial) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d"))|>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")

df3 <- rio::import("data/google_trends/interest_over_time_df3.csv") |>
  select(-isPartial) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")

df4 <- rio::import("data/google_trends/interest_over_time_df4.csv") |>
  select(-isPartial) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")

df5 <- rio::import("data/google_trends/interest_over_time_df5.csv") |>
  select(-isPartial) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")

df_gen_trnds_pe <- rio::import("data/google_trends/trends_peru_2020-2022_multiTimeline.csv") |>
  rename(date = Week) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>
  mutate(across(-date, as.character)) |>
  mutate(across(-date, ~str_replace(., "<1", "0.5"))) |>
  mutate(across(-date, as.numeric)) |>
  pivot_longer(cols = -date, names_to = "search term", values_to = "interest")


# Plotting
df_gen_trnds_pe |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),  # Remove legend title
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%b %d", date_breaks = "2 month") 


# Plotting
df_gen_trnds_pe |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") 

df1 |> 
  ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom",  
    legend.title = element_blank(),
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(), 
    #panel.grid.minor.x = element_blank(),
    aspect.ratio = 1/3  
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month")  

df2 |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom",  
    legend.title = element_blank(),
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),
    #panel.grid.minor.x = element_blank(),
    aspect.ratio = 1/3  
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") 

df3 |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(),  
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  
    #panel.grid.minor.x = element_blank(),  
    aspect.ratio = 1/3  
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") 

df4 |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom",  
    legend.title = element_blank(),  
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),
    #panel.grid.minor.x = element_blank(),
    aspect.ratio = 1/3  
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") 

df5 |> ggplot(aes(x = date, y = interest, color = `search term`, group = `search term`)) +
  geom_line() +
  labs(title = "Interest Over Time", x = "Date", y = "Search Interest") +
  theme_minimal(base_size = 10) +
  theme(
    legend.position = "bottom",  
    legend.title = element_blank(),  
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  
    #panel.grid.minor.x = element_blank(),  
    aspect.ratio = 1/3  
  ) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") 
