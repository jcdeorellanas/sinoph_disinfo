# This code preprocess and cleans the data. It
# 1. Opens json files containing dictionaries with video metadata downloaded
#   from YouTube.
# 2. Converts dates in UNIX format into regular `Date` format and counts from 
#   `character` into numeric format.
# 3. Creates the Program column and fills it with the program titles extracted from
#   the video_title data downloaded from the API. If video_title does not contain 
#   the program name, it insters NA.
# 4. Standardizes the programs' names and cleans the titles by extracting the program 
#   name
# 5. Creates a dataframe to analyze and visualize the data using ggplot
# 6. Replaces NAs in the Program columns with the manually found show names 
# 7. Creates a .csv file with the dataframe.

# The code after takes the df created above and creates 3 scatter-plots. It 
# 8. Uses geom_jitter to counter point overlap. 
# 9. Create 3 separate plots to visualize the number of views, likes, and comments
#   that the anti-Sinopharm malinformation videos received
# 10. Selects video of March 5 2021 as a case study
# 11. Loads the comments and related metadata into a dataframe
# 12. Saves dataframe for hand-coding using a 0-3 scale (0 = Neurtral, 
#     1 = In-line politically, 2 = In-line w/Sinopharm disinfo, 3 = Against video)
# 13 Loads hand-coded file

# TO DO: 
# Keep parsing the vide_title metadata to extract the dates in which the 
# programs were aired and keep the title column only with the video titles

library(jsonlite)
library(tidyverse)
library(pacman)
library(lubridate)
library(scales)
library(gt) 


### Data frame and table selecting relevant columns and filtering videos by keywords
other_media <- rio::import("data/other_media/other_media_videos.csv") |>
  select(-c(channel_id, favorite_count),
         publish_date, 
         ID = video_id, 
         Title = video_title, 
         Description = video_description, 
         Views = view_count, 
         Likes = like_count, 
         Comments = comment_count) |>
  arrange(publish_date)

### Data frame and table organizing the videos by views 
views_df <- other_media |>
  rename(Publish_Date = publish_date) |>
  select(-c(ID, Description)) |>
  arrange(desc(Views))

# views_df_sliced <- views_df |>
#   slice(1:12)

views_table <- views_df |>
  mutate(Publish_Date = as.factor(Publish_Date)) |>
  gt() |>
  tab_header(
    title = "Total of views per video (descending)"
  )|>
  data_color(columns = c(Views),
             direction = "column",
             target_columns = NULL,
             method = "auto",
             bins = 5,
             quantiles = 5,
             ordered = FALSE,
             reverse = TRUE)
views_table

# views_table_tail <- tail(views_df, n=12) |>
#   mutate(publish_date = as.factor(publish_date)) |>
#   gt() |>
#   tab_header(
#     title = "Total of views per video (tail)"
#   )|>
#   data_color(columns = c(publish_date, views),
#              direction = "column",
#              target_columns = NULL,
#              method = "auto",
#              bins = 4,
#              quantiles = 4,
#              ordered = FALSE,
#              reverse = FALSE)
# views_table_tail

### Data frame and table organizing the videos by date, focusing on 2021
videos_2021 <- other_media |>
  filter(publish_date >= as_date("2021-01-01") & publish_date <= as_date("2021-12-31")) 
  
videos_2021_table <- videos_2021 |>
  mutate(publish_date = as_date(publish_date)) |>
  mutate(publish_date = as.character(publish_date)) |>
  gt() |>
  tab_header(
    title = "2021 Videos"
  )|>
  data_color(columns = everything(),
             rows = str_detect(publish_date, regex(
               "2021-03-09|2021-03-10|2021-05-04|2021-05-06|2021-07-23|2021-08-04|2021-08-05|2021-08-06"
               )),
             direction = "row",
             target_columns = NULL,
             method = "auto",
             palette = "lightgreen")
videos_2021_table

### Data frame and table with the statistics
summary(other_media)

stat_summ_df <- summary(other_media) |>
  as.data.frame.matrix() |>
  as_tibble()

colnames(stat_summ_df) <- gsub("^\\s+", "", colnames(stat_summ_df))

stat_summ_df <- stat_summ_df |>
  select(-c(Title, Description))

# gt_table <- stat_summ_df |>
#   gt() |>
#   tab_header(
#     title = "RPP Video Statistics Summary"
#   ) |>
#   cols_label(
#     publish_date = "Publish Date",
#     ID = "Videos",
#   ) |>
#   cols_move_to_start(
#     columns = c(ID)
#   )
# gt_table

### Plotting number of views by date and program
rpp_eff_df |> ggplot(aes(x = publish_date, y = Views)) + 
  geom_point(size=0.75) +
  labs(title = "Video View Count (Oct. '20 - Sep. '22)", x = "Date", y = "Views") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    #panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%m/%y", date_breaks = "1 month") +
  scale_y_continuous(labels = label_comma())


videos_2021 |> ggplot(aes(x = publish_date, y = Views)) + 
  geom_point(size=0.75) +
  labs(title = "Video View Count (2021)", x = "Date", y = "Views") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    #panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  scale_y_continuous(labels = label_comma())



### Plotting number of comments by date and program
rpp_eff_df |> ggplot(aes(x = publish_date, y = Comments)) + 
  geom_point(size=0.75) +
  labs(title = "Video Comment Count (Oct. '20 - Sep. '22)", x = "Date", y = "Comments") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%m/%y", date_breaks = "2 month") +
  scale_y_continuous(labels = label_comma())  


videos_2021 |> ggplot(aes(x = publish_date, y = Comments)) + 
  geom_point(size=0.75) +
  labs(title = "Video Comment Count (2021)", x = "Date", y = "Comments") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%m/%y", date_breaks = "1 month") +
  scale_y_continuous(labels = label_comma())  

### Plotting number of likes by date and program
rpp_eff_df |> ggplot(aes(x = publish_date, y = Likes)) + 
  geom_point(size=0.75) +
  labs(title = "Video Like Count (Oct. '20 - Sep. '22)", x = "Date", y = "Likes") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%m/%y", date_breaks = "2 month") +
  scale_y_continuous(labels = label_comma()) 


videos_2021 |> ggplot(aes(x = publish_date, y = Likes)) + 
  geom_point(size=0.75) +
  labs(title = "Video Like Count", x = "Date", y = "Likes") +
  theme_minimal(base_size = 10) +
  theme(
    title = element_text(size=15),
    axis.title = element_text(color = "darkgrey"),
    legend.position = "bottom",  
    legend.title = element_blank(),  # Remove legend title
    axis.text.x = element_text(size = 7),
    panel.grid.major.x = element_blank(),  # Remove vertical grid lines
    #panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
    aspect.ratio = 1/3  # Set aspect ratio for wider plot
  ) +
  scale_x_date(date_labels = "%m/%y", date_breaks = "1 month") +
  scale_y_continuous(labels = label_comma()) 



### ***Case Study*** ###

# Loads file to create dataframe for hand coding and selects desired column
file <- rio::import("data/willax_pbo_youtube_vids/wil_pbo_sinoph_comments.json")
View(file)

View(file[[1]]) # Check that video is the desired one
colnames(file[[1]]) # Check column names for 

video_comments <- (file[[1]]) |>
  mutate(comment_publish_date = as_datetime(comment_publish_date, origin = "1970-01-01")) |>
  mutate(comment_like_count = ifelse(!is.na(as.numeric(comment_like_count)), as.numeric(comment_like_count), 0)) |>
  mutate(reply_count = as.numeric(reply_count)) |>
  mutate(attitude = NA_character_) |>
  mutate(comment_date = as_date(comment_publish_date),
         comment_time = format(comment_publish_date, "%H:%M:%S")) |>
  select(video_id,
         comment_date,
         comment_time,
         comment_id,
         comment = text,
         attitude,
         comment_likes = comment_like_count,
         replies = reply_count,
         commenter_channel_id,
         commenter_channel_display_name,
         commenter_rating,
         comment_parent_id) |>
  arrange(comment_date)

# str(video_comments)
# head(video_comments)
summary(video_comments)

# Save dataframe into .csv
write.csv(video_comments, "data/FILENAME.csv", row.names = FALSE)

###  Loads file and translates numerica hand-code into qualitative values
## Creates summary for commenters and viewers in relation to data on columns "attitude" (hand code)
coded_file <- rio::import("data/willax_pbo_youtube_vids/df_sinoph_comment_dis_code1JC.csv")

video_comments_summary <- coded_file |>
  mutate(replies = as.numeric(replies)) |>
  mutate(attitude = as.numeric(attitude)) |>
  filter(!is.na(attitude)) |>
  mutate(attitude = case_when(
    attitude == 0 ~ "Neutral",
    attitude == 1 ~ "Favor (Politically)",
    attitude == 2 ~ "Favor (Sinopharm/Genocide)",
    attitude == 3 ~ "Against",
    TRUE ~ as.character(attitude)  # Safety catch to convert any other numbers to character
  )) |> 
  group_by(attitude) |>
  summarize(
    total_commenters = n(),
    unique_commenters = n_distinct(commenter_channel_display_name, na.rm = TRUE),
    non_unique_commenters = total_commenters - unique_commenters,
    total_likes = sum(comment_likes, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  arrange(attitude)

# Dataframe summarising the coded obsercations
attude_summ_df <-coded_file |>
  summarise(
    Coded_Observations = sum(!is.na(attitude)),
    Total_NAs = sum(is.na(attitude))
  )
# print(summary_df) #Check and debug

# Table for attitude summary
attude_summ_tab <- attude_summ_df |>
  gt() |>
  tab_header(
    title = "Attitude Totals"
  ) |>
  cols_label(
    Coded_Observations = "Coded Observations",
    Total_NAs = "NAs"
  )
attude_summ_tab

# Video Comments Table --------
comm_table <- video_comments_summary |>
  gt() |>
  tab_header(
    title = "Comments Summary"
  ) |>
  cols_label(
    attitude = "Attitude Toward Video",
    total_commenters = "Total Commenters",
    unique_commenters = "Unique Commenters",
    non_unique_commenters = "Recurrent Commenters",
    total_likes = "Total Likes",
  ) |>
  data_color(
    columns = c(unique_commenters, non_unique_commenters),
    direction = "row",
    method = "auto")
comm_table

# Unique and Recurrent Commenters ------
# Calculate non-unique commenters and their posting frequency
commenter_frequencies <- coded_file |>
  count(commenter_channel_display_name, sort = TRUE, name = "posts_count") |>
  filter(commenter_channel_display_name != "NA") |>
  count(posts_count, name = "commenter_count") 

comm_freq_tbl <- commenter_frequencies |>
  gt() |>
  tab_header(
    title = "Commenter Frequency"
  ) |>
  cols_label(
    commenter_count = "Commenters",
    posts_count = "Posts"
  ) |>
  data_color(columns = posts_count,
             direction = "column",
             target_columns = NULL,
             method = "auto",
             bins = 8,
             quantiles = 4,
             ordered = FALSE,
             reverse = TRUE)|>
  cols_move_to_start(
    columns = c(commenter_count)
  )
comm_freq_tbl

