
default_elo = "1500"

# weight for regular season games
kval = 20

# read in original elo values if they exist
prv = read.csv("current_ratings.csv")

# read in win expectancy weighting table
wt = read.csv("winning_expectancy.csv")

#for (pos in c("QUARTERBACK" ,"RUNNING_BACK" ,"WIDE_RECEIVER" ,"TIGHT_END" ,"DEFENSIVE_LINEMAN" ,"LINEBACKER" ,"DEFENSIVE_BACK" ,"KICK_RETURNER" ,"PUNT_RETURNER" ,"FIELD_GOAL_KICKER")) {
for (pos in c("QUARTERBACK")) {
  today = format(Sys.time(), "%Y-%m-%d")
  file = paste(pos, today, sep="_")
  file = paste(file, "csv", sep=".")
  outfile = paste("new", pos, "ratings", sep="_")
  outfile = paste(outfile, "csv", sep=".")

  mydata = read.csv(file)

  # merge in current ELO scores
  scored_pos_data <- merge(x = mydata, y = prv, by = "Player", all.x = TRUE)
  rm(mydata)

  # calculate new ELO scores by position
  switch(pos,
  QUARTERBACK={
    print(pos)
  },
  RUNNING_BACK={
    print(pos)
  })
  
  write.csv(scored_pos_data[,c("Player","ELO")], file = outfile, na=default_elo, row.names=FALSE)

  rm(scored_pos_data)
}

