library(nflfastR)
library(tidyverse)

season <- 2021
pbp <- load_pbp(season)

input_file <- "New NFL Workbook - This Week.csv"
this_week_input <- read.csv(file = input_file)
head(this_week_input)

calc_wp_func <- function(x) {
  data <- tibble::tibble(
    "receive_2h_ko" = 0,
    "home_team" = x[1],
    "posteam" = x[1],
    "score_differential" = 0,
    "half_seconds_remaining" = 1800,
    "game_seconds_remaining" = 3600,
    "spread_line" = c(as.numeric(x[2])),
    "down" = 1,
    "ydstogo" = 10,
    "yardline_100" = 75,
    "posteam_timeouts_remaining" = 3,
    "defteam_timeouts_remaining" = 3
  )

  rtn <- nflfastR::calculate_win_probability(data) %>% dplyr::select(home_team, wp, vegas_wp) %>% rename(home_nflstatR_wp = wp, home_vegas_wp = vegas_wp)
}

vegas_prbs <- apply(this_week_input[,c('home','home.team.line')], 1, calc_wp_func)
vegas_prb_df <- do.call(rbind.data.frame, vegas_prbs)

head(vegas_prb_df)
output_df <- merge(this_week_input, vegas_prb_df, by.x="home", by.y="home_team")

write.csv(output_df, "this_week_export.csv", row.names = FALSE)

