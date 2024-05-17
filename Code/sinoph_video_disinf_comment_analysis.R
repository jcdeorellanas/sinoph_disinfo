library(jsonlite)
library(tidyverse)
library(pacman)
library(lubridate)
library(scales)
library(gt)

file <- rio::import("data/willax_pbo_youtube_vids/wil_pbo_sinoph_comments.json")
View(file)

# View(file[[1]])
# colnames(file[[1]])
 
# video_comments <- (file[[1]]) |>
#   mutate(comment_publish_date = as_datetime(comment_publish_date, origin = "1970-01-01")) |>
#   mutate(comment_like_count = ifelse(!is.na(as.numeric(comment_like_count)), as.numeric(comment_like_count), 0)) |>
#   mutate(reply_count = as.numeric(reply_count)) |>
#   mutate(attitude = NA_character_) |>
#   mutate(comment_date = as_date(comment_publish_date),
#          comment_time = format(comment_publish_date, "%H:%M:%S")) |>
#   select(video_id,
#          comment_date,
#          comment_time,
#          comment_id,
#          comment = text,
#          attitude,
#          comment_likes = comment_like_count,
#          replies = reply_count,
#          commenter_channel_id,
#          commenter_channel_display_name,
#          commenter_rating,
#          comment_parent_id) |>
#   arrange(comment_date)

# str(video_comments)
# head(video_comments)
# summary(video_comments)

#write.csv(video_comments, "data/willax_pbo_youtube_vids/df_sinoph_comment_dis_code1.csv", row.names = FALSE)

# -----
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
  )

comm_table


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
    posts_count = "Posts",
    commenter_count = "Commenters"
  )

comm_freq_tbl


