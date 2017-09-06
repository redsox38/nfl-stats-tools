
# read in original elo values if they exist
prv = read.csv("current_ratings.csv")

# create empty data frame for updates
updated_ratings = prv[FALSE,]

#for (pos in c("QUARTERBACK" ,"RUNNING_BACK" ,"WIDE_RECEIVER" ,"TIGHT_END" ,"DEFENSIVE_LINEMAN" ,"LINEBACKER" ,"DEFENSIVE_BACK" ,"KICK_RETURNER" ,"PUNT_RETURNER" ,"FIELD_GOAL_KICKER")) {
for (pos in c("QUARTERBACK")) {
  today = format(Sys.time(), "%Y-%m-%d")
  file = paste(pos, today, sep="_")
  file = paste(file, "csv", sep=".")
  mydata = read.csv(file)

  # merge in current ELO scores
  scored_pos_data <- merge(x = mydata, y = prv, by = "Player", all.x = TRUE)

  # calculate new ELO scores by position

  print(scored_pos_data)

  rm(mydata)
  rm(scored_pos_data)
}

write.csv(updated_ratings, file = "new_ratings.csv",row.names=FALSE)
