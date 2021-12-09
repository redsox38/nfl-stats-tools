library(nflfastR)
library(tidyverse)

export_df = data.frame(matrix(ncol = 12, nrow = 0))
x <- c('posteam','home_team','pass_yards','pass_tds','pass_comp','pass_ints','pass_att','rush_yards','rush_tds','rush_att','total_score','game_id')
colnames(export_df) <- x

season <- 2021
pbp <- load_pbp(season)

all_games <- dplyr::select(pbp, game_id) %>% dplyr::distinct(game_id) 

for (g in all_games$game_id) {

  game_data <- dplyr::filter(pbp, game_id == g) 

  # pass stats
  # yds tds comp int att
  pass_data <- dplyr::filter(game_data, play_type == "pass") %>%
  dplyr::group_by(posteam) %>%
  dplyr::summarize(
      home_team = unique(home_team),
      pass_yards = sum(passing_yards, na.rm = T),
      pass_tds = sum(touchdown == 1),
      pass_comp = sum(complete_pass == 1),
      pass_ints = sum(interception),
      pass_att = dplyr::n()
  ) 

  # rushstats
  # yds tds att
  rush_data <- dplyr::filter(game_data, play_type == "run") %>%
  dplyr::group_by(posteam) %>%
  dplyr::summarize(
      rush_yards = sum(rushing_yards, na.rm = T),
      rush_tds = sum(touchdown == 1),
      rush_att = dplyr::n()
  ) 

  # total score
  totals <- dplyr::group_by(game_data, posteam) %>%
  dplyr::summarize(
      total_score = (sum(touchdown == 1, na.rm = T) * 6) + 
                    (sum(field_goal_result == "made", na.rm = T) * 3) + 
                    sum(extra_point_result == "good", na.rm = T) + 
                    (sum(two_point_conv_result == "success", na.rm = T) * 2) + 
                    (sum(safety == 1, na.rm = T) * 2)
  ) %>% drop_na()

  pass_df <- as.data.frame(pass_data)
  rush_df <- as.data.frame(rush_data)
  score_df <- as.data.frame(totals) %>%
              dplyr::mutate(win = case_when(
                  max(total_score) == total_score ~ 1,
                  TRUE ~ 0)
              )

  this_df <- merge(pass_df, rush_df) %>% merge(score_df)
  this_df$game_id <- g

  export_df <- rbind(export_df, this_df)
}

write.csv(export_df, "nfl_raw_export.csv", row.names = FALSE)
